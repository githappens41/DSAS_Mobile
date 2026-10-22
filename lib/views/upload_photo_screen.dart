import 'dart:io';
import 'dart:typed_data';
import 'package:dsas_app/views/view_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPhotoScreen extends StatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final _picker = ImagePicker();

  XFile? _photo;
  File? _proofPdf;
  String? _proofPdfName;
  bool _isLoading = false;

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
      if (picked == null || !mounted) return;
      setState(() => _photo = picked);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not open the camera or gallery.');
    }
  }

  Future<void> _pickPdf() async {
    try {
      final picked = await _picker.pickMedia();

      if (picked != null) {
        if (picked.name.toLowerCase().endsWith('.pdf')) {
          setState(() {
            _proofPdf = File(picked.path);
            _proofPdfName = picked.name;
          });
        } else {
          _showMessage('Please select a PDF file only.');
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error picking file: $e');
    }
  }

  Future<String> _uploadFile(
    String userId,
    String name,
    String extension,
    List<int> bytes,
  ) async {
    final path = '$userId/$name.$extension';

    String contentType = 'application/octet-stream';
    if (extension == 'jpg' || extension == 'jpeg') contentType = 'image/jpeg';
    if (extension == 'png') contentType = 'image/png';
    if (extension == 'pdf') contentType = 'application/pdf';

    await Supabase.instance.client.storage
        .from('student-uploads')
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return path;
  }

  Future<void> _submit() async {
    if (_photo == null) {
      _showMessage('Please add your photo.');
      return;
    }
    if (_proofPdf == null) {
      _showMessage('Please add your proof of registration (PDF).');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showMessage('You are not logged in. Please log in again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final photoBytes = await _photo!.readAsBytes();
      var photoExt = _photo!.name.contains('.')
          ? _photo!.name.split('.').last.toLowerCase()
          : 'jpg';
      if (photoExt == 'jpeg') photoExt = 'jpg';
      final photoPath = await _uploadFile(
        user.id,
        'photo',
        photoExt,
        photoBytes,
      );

      final proofBytes = await _proofPdf!.readAsBytes();
      final proofPath = await _uploadFile(user.id, 'proof', 'pdf', proofBytes);

      await Supabase.instance.client
          .from('student_cards')
          .update({
            'photo_url': photoPath,
            'proof_url': proofPath,
            'status': 'pending',
          })
          .eq('user_id', user.id);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewStatusScreen()),
      );
    } on StorageException catch (e) {
      if (!mounted) return;
      _showMessage('Upload failed: ${e.message}');
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Register",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                        "Upload Photo",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Capture or upload a clear, front-facing photo for\nyour student card and proof of registration",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildPhotoBox("+Take/upload photo", _photo, _pickPhoto),

                    const SizedBox(height: 24),
                    const Text(
                      "Proof of registration",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildPdfBox(),
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
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Submit registration",
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

  Widget _buildPhotoBox(String text, XFile? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2029),
          borderRadius: BorderRadius.circular(10),
        ),
        child: file == null
            ? Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder(
                    future: file.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      }
                      return Image.memory(snapshot.data!, fit: BoxFit.cover);
                    },
                  ),
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

  Widget _buildPdfBox() {
    return GestureDetector(
      onTap: _isLoading ? null : _pickPdf,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2029),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _proofPdf == null
            ? const Center(
                child: Text(
                  "+ Upload PDF Document",
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
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _proofPdfName ?? 'Document.pdf',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to change',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
      ),
    );
  }
}
