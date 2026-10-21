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
  XFile? _proof;
  bool _isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pick({required bool isPhoto}) async {
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
        preferredCameraDevice:
            isPhoto ? CameraDevice.front : CameraDevice.rear,
      );
      if (picked == null || !mounted) return;
      setState(() {
        if (isPhoto) {
          _photo = picked;
        } else {
          _proof = picked;
        }
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not open the camera or gallery.');
    }
  }

  Future<String> _upload(XFile file, String userId, String name) async {
    final bytes = await file.readAsBytes();

    var ext = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : 'jpg';
    if (ext == 'jpeg') ext = 'jpg';

    final path = '$userId/$name.$ext';
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

    await Supabase.instance.client.storage
        .from('student-uploads')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return path;
  }

  Future<void> _submit() async {
    if (_photo == null) {
      _showMessage('Please add your photo.');
      return;
    }
    if (_proof == null) {
      _showMessage('Please add your proof of registration.');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showMessage('You are not logged in. Please log in again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final photoPath = await _upload(_photo!, user.id, 'photo');
      final proofPath = await _upload(_proof!, user.id, 'proof');

      await Supabase.instance.client.from('student_cards').update({
        'photo_url': photoPath,
        'proof_url': proofPath,
        'status': 'pending',
      }).eq('user_id', user.id);

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
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Check your connection.');
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    _buildUploadBox(
                      "+Take/upload photo",
                      _photo,
                      () => _pick(isPhoto: true),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Proof of registration",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildUploadBox(
                      "+Take/upload photo",
                      _proof,
                      () => _pick(isPhoto: false),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
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
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(String text, XFile? file, VoidCallback onTap) {
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
}