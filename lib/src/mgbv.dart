// lib/src/gallery_button.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// NEW: Using an enum for button type is safer and more readable than a string.
enum GBT { icon, filled }

/// A button that allows the user to pick an image from the gallery
/// and analyze it for barcodes.
class MGBV extends StatefulWidget {
  final void Function(String?)? onImagePick;
  final void Function(BarcodeCapture)? onDetect;
  final bool Function(BarcodeCapture)? validator;
  final MobileScannerController controller;
  final ValueNotifier<bool?> isSuccess;
  final String text;
  final IconData? icon;

  const MGBV({
    super.key,
    this.onImagePick,
    this.onDetect,
    this.validator,
    required this.controller,
    required this.isSuccess,
    this.text = 'Upload from gallery',
    this.icon,
  });

  @override
  State<MGBV> createState() => _MGBVState();
}

class _MGBVState extends State<MGBV> {
  /// REFACTORED: The logic for picking and analyzing the image is now cleaner.
  Future<void> _pickAndAnalyzeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    widget.onImagePick?.call(image?.path);

    if (image == null) return;

    final BarcodeCapture? barcodes =
        await widget.controller.analyzeImage(image.path);

    if (barcodes != null) {
      bool isValid = true;
      if (widget.validator != null) {
        isValid = widget.validator!(barcodes);
      }

      widget.isSuccess.value = isValid;
      HapticFeedback.lightImpact();

      if (isValid) {
        widget.onDetect?.call(barcodes);
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    } else {
      widget.isSuccess.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _pickAndAnalyzeImage();
      },
      child: Icon(
        widget.icon,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
