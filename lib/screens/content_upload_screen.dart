import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../services/auth_service.dart';

class ContentUploadScreen extends StatefulWidget {
  const ContentUploadScreen({super.key});

  @override
  State<ContentUploadScreen> createState() => _ContentUploadScreenState();
}

class _ContentUploadScreenState extends State<ContentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  bool _isPremium = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _uploadResult;

  late CloudinaryService _cloudinaryService;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCloudinaryService();
  }

  Future<void> _initializeCloudinaryService() async {
    // Récupérer le token depuis AuthService
    final authService = AuthService();
    final token = await authService.getToken();
    if (token == null) {
      setState(() {
        _errorMessage = 'Vous devez être connecté pour uploader du contenu';
      });
      return;
    }

    _cloudinaryService = CloudinaryService(
      baseUrl: 'http://localhost:8080', // Remplacez par l'URL de votre API
      authToken: token,
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadContent() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        setState(() {
          _errorMessage = 'Veuillez sélectionner une image';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final result = await _cloudinaryService.createContentWithImage(
          title: _titleController.text,
          description: _descriptionController.text,
          type: 'image',
          isPremium: _isPremium,
          imageFile: _imageFile!,
        );

        setState(() {
          _uploadResult = result;
          _isLoading = false;
        });

        // Afficher un message de succès
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contenu uploadé avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Erreur lors de l\'upload: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un nouveau contenu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ de titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ de description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Option premium
              SwitchListTile(
                title: const Text('Contenu premium'),
                value: _isPremium,
                onChanged: (value) {
                  setState(() {
                    _isPremium = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Sélection d'image
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Sélectionner une image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),

              // Aperçu de l'image
              if (_imageFile != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Message d'erreur
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[100],
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              const SizedBox(height: 16),

              // Bouton d'upload
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadContent,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('PUBLIER'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // Résultat de l'upload
              if (_uploadResult != null)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Publication réussie !',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Titre: ${_uploadResult!['content']['title']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'URL média: ${_uploadResult!['upload_result']['media_url']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        _uploadResult!['upload_result']['media_url'],
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
