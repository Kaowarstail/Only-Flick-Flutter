import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final double? width;
  final double? height;

  const CachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder?.call(context, imageUrl) ?? 
               Container(
                 color: AppColors.backgroundSecondary,
                 child: Center(
                   child: CircularProgressIndicator(
                     value: loadingProgress.expectedTotalBytes != null
                         ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                         : null,
                     color: AppColors.primary,
                   ),
                 ),
               );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget?.call(context, imageUrl, error) ?? 
               Container(
                 color: AppColors.backgroundSecondary,
                 child: Center(
                   child: Icon(
                     Icons.error_outline,
                     color: AppColors.error,
                     size: 24,
                   ),
                 ),
               );
      },
    );
  }
}
