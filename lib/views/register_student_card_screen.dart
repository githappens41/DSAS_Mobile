import 'package:dsas_app/views/upload_photo_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterStudentCardScreen extends StatefulWidget {
  const RegisterStudentCardScreen({super.key});

  @override
  State<RegisterStudentCardScreen> createState() =>
      _RegisterStudentCardScreenState();
}

class _RegisterStudentCardScreenState extends State<RegisterStudentCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _programmeController = TextEditingController();
  bool _showErrors = false;
  bool _isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _validateAndContinue() async {
    setState(() => _showErrors = true);
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showMessage('You are not logged in. Please log in again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('student_cards').upsert({
        'user_id': user.id,
        'full_name': _fullNameController.text.trim(),
        'student_number': _studentNumberController.text.trim(),
        'programme': _programmeController.text.trim(),
      }, onConflict: 'user_id');

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UploadPhotoScreen()),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;
      if (e.code == '23505') {
        _showMessage('That student number is already registered.');
      } else {
        _showMessage(e.message);
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentNumberController.dispose();
    _programmeController.dispose();
    super.dispose();
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Register Student\nCard",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Personal Information",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Please fill in your details",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      _buildField("Full Name", _fullNameController),
                      const SizedBox(height: 16),
                      _buildField(
                        "Student Number",
                        _studentNumberController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildField("Programme", _programmeController),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C1D95),
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
                          "Continue to upload photo",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController c, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_showErrors) ...[
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: c,
          keyboardType: keyboardType,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? "This field is required" : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            fillColor: Colors.grey[200],
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF4C1D95),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            errorStyle: const TextStyle(color: Colors.red, fontSize: 11),
          ),
        ),
      ],
    );
  }
}