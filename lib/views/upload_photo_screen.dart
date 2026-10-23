import 'dart:typed_data';
import 'package:dsas_app/viewmodels/register_student_card_view_model.dart';
import 'package:dsas_app/views/view_status_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UploadPhotoScreen extends StatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final _picker = ImagePicker();

  Uint8List? _photoBytes;
  String _photoExt = 'jpg';
  Uint8List? _proofBytes;
  String? _proofName;

  static const Color _primaryBlue = Color(0xFF0D47A1);

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoExt = picked.name.contains('.')
            ? picked.name.split('.').last.toLowerCase()
            : 'jpg';
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not open the camera or gallery.');
    }
  }

  Future<void> _pickPdf() async {
    try {
      final dynamic result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null) return;

      final dynamic file = result is List
          ? (result.isEmpty ? null : result.first)
          : (result.files.isEmpty ? null : result.files.first);
      if (file == null) return;

      Uint8List? bytes;
      try {
        bytes = file.bytes as Uint8List?;
      } catch (_) {
        bytes = null;
      }
      if (bytes == null) {
        try {
          bytes = await file.readAsBytes() as Uint8List;
        } catch (_) {
          bytes = null;
        }
      }

      if (bytes == null) {
        if (!mounted) return;
        _showMessage('Could not read the selected file.');
        return;
      }

      final String name = file.name as String;

      if (!mounted) return;
      setState(() {
        _proofBytes = bytes;
        _proofName = name;
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not select the file.');
    }
  }

  Future<void> _submit() async {
    if (_photoBytes == null) {
      _showMessage('Please add your photo.');
      return;
    }
    if (_proofBytes == null) {
      _showMessage('Please add your proof of registration (PDF).');
      return;
    }

    final vm = context.read<RegisterStudentCardViewModel>();
    final ok = await vm.submit(
      photoBytes: _photoBytes!,
      photoExtension: _photoExt,
      proofBytes: _proofBytes!,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ViewStatusScreen()),
        (route) => route.isFirst,
      );
    } else {
      _showMessage(vm.errorMessage ?? 'Submission failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<RegisterStudentCardViewModel, bool>(
      (vm) => vm.isSubmitting,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Upload Photo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Capture or upload a clear, front-facing photo for\nyour student card and proof of registration',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildPhotoBox(isSubmitting),
                    const SizedBox(height: 24),
                    const Text(
                      'Proof of registration',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPdfBox(isSubmitting),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit registration',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoBox(bool disabled) {
    return GestureDetector(
      onTap: disabled ? null : _pickPhoto,
      child: Container(
        height: 140,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.blue[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: _photoBytes == null
            ? const Center(
                child: Text(
                  '+ Take/upload photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(_photoBytes!, fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Tap to change',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPdfBox(bool disabled) {
    return GestureDetector(
      onTap: disabled ? null : _pickPdf,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: _proofBytes == null
            ? const Center(
                child: Text(
                  '+ Upload PDF Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _proofName ?? 'Document.pdf',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to change',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
      ),
    );
  }
}