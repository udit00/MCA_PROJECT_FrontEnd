import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zymm/utils/image_picker_helper.dart';

/// A reusable widget for picking and displaying profile images
class ProfileImagePicker extends StatelessWidget {
  final String? base64Image;
  final String? networkImageUrl;
  final Function(String base64Image) onImageSelected;
  final double size;
  final bool showEditIcon;

  const ProfileImagePicker({
    super.key,
    this.base64Image,
    this.networkImageUrl,
    required this.onImageSelected,
    this.size = 120,
    this.showEditIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Profile Image Circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildImageWidget(),
            ),
          ),
          
          // Edit/Add Icon Button
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () => _showImagePicker(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    base64Image == null && networkImageUrl == null
                        ? Icons.add_a_photo
                        : Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    // Priority: base64Image > networkImageUrl > placeholder
    if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        final bytes = base64Decode(base64Image!);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return _buildPlaceholder();
      }
    }

    if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      return Image.network(
        networkImageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.grey.shade400,
      ),
    );
  }

  Future<void> _showImagePicker(BuildContext context) async {
    final base64Image = await ImagePickerHelper.showImageSourceDialogBase64(context);
    if (base64Image != null && base64Image.isNotEmpty) {
      onImageSelected(base64Image);
    }
  }
}

