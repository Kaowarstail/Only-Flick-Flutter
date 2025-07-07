import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../services/content_upload_service.dart';

class ContentUploadWidget extends StatefulWidget {
  final String authToken;
  final String baseUrl;
  final VoidCallback? onUploadSuccess;

  const ContentUploadWidget({
    Key? key,
    required this.authToken,
    required this.baseUrl,
    this.onUploadSuccess,
  }) : super(key: key);

  @override
  _ContentUploadWidgetState createState() => _ContentUploadWidgetState();
}

class _ContentUploadWidgetState extends State<ContentUploadWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _errorMessage;
  String? _uploadedContentUrl;
  late ContentUploadService _contentUploadService;
  
  // Controllers pour les champs de texte
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _contentType = 'image'; // 'image' ou 'video'
  bool _isPremium = false;
  bool _isPublished = true;

  @override
  void initState() {
    super.initState();
    _contentUploadService = ContentUploadService(baseUrl: widget.baseUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Sélectionner une image depuis la galerie
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _errorMessage = null;
        _uploadedContentUrl = null;
      });
    }
  }

  // Prendre une photo avec la caméra
  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _errorMessage = null;
        _uploadedContentUrl = null;
      });
    }
  }

  // Uploader le contenu avec l'image
  Future<void> _uploadContent() async {
    // Validations
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Le titre est requis";
      });
      return;
    }

    if (_selectedImage == null) {
      setState(() {
        _errorMessage = "Veuillez sélectionner une image";
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Créer FormData pour l'upload multipart
      FormData formData = FormData.fromMap({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _contentType,
        'is_premium': _isPremium.toString(),
        'is_published': _isPublished.toString(),
        'media': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: path.basename(_selectedImage!.path),
        ),
      });

      // Configuration Dio
      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer ${widget.authToken}';
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);

      // Upload vers l'API
      Response response = await dio.post(
        '${widget.baseUrl}/api/v1/contents/upload',
        data: formData,
        onSendProgress: (sent, total) {
          // Optionnel: afficher le progrès d'upload
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        
        setState(() {
          _uploadedContentUrl = responseData['content']['media_url'];
          _isUploading = false;
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contenu uploadé avec succès!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Voir',
              onPressed: () {
                // Optionnel: naviguer vers le contenu créé
              },
            ),
          ),
        );

        // Callback de succès
        if (widget.onUploadSuccess != null) {
          widget.onUploadSuccess!();
        }

        // Réinitialiser le formulaire
        _resetForm();

      } else {
        setState(() {
          _errorMessage = "Erreur lors de l'upload: ${response.statusCode}";
          _isUploading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _isUploading = false;
        if (e.response != null) {
          _errorMessage = "Erreur serveur: ${e.response?.statusCode} - ${e.response?.data}";
        } else {
          _errorMessage = "Erreur de connexion: ${e.message}";
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur inattendue: $e";
        _isUploading = false;
      });
    }
  }

  // Réinitialiser le formulaire
  void _resetForm() {
    setState(() {
      _selectedImage = null;
      _titleController.clear();
      _descriptionController.clear();
      _contentType = 'image';
      _isPremium = false;
      _isPublished = true;
      _uploadedContentUrl = null;
      _errorMessage = null;
    });
  }

  // Afficher les options de sélection d'image
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Appareil photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Annuler'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau contenu'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champ titre
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titre *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: 100,
            ),
            SizedBox(height: 16),

            // Champ description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            SizedBox(height: 16),

            // Options
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Contenu premium'),
                    value: _isPremium,
                    onChanged: (value) {
                      setState(() {
                        _isPremium = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Publier maintenant'),
                    value: _isPublished,
                    onChanged: (value) {
                      setState(() {
                        _isPublished = value ?? true;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Sélection d'image
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: _showImageSourceOptions,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Ajouter une image',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 20),

            // Bouton d'upload
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isUploading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Upload en cours...'),
                      ],
                    )
                  : Text(
                      'Publier le contenu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),

            // Message d'erreur
            if (_errorMessage != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Message de succès
            if (_uploadedContentUrl != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Contenu publié avec succès!',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'URL: $_uploadedContentUrl',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget simple pour les cases à cocher
class SimpleCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const SimpleCheckbox({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label),
      ],
    );
  }
}
