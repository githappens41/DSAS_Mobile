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
  bool _isLoading = false;

  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _textColor = Colors.black87;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _validateAndContinue() async {
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

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _primaryBlue, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: _textColor,
      fontSize: 14,
    );

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
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: _textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Personal Information",
                        style: labelStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Please fill in your details",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text('Full Name', style: labelStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _fullNameController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(color: _textColor),
                        cursorColor: _primaryBlue,
                        decoration: _decoration('Full Name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "This field is required"
                            : null,
                      ),
                      const SizedBox(height: 20),

                      Text('Student Number', style: labelStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _studentNumberController,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(color: _textColor),
                        cursorColor: _primaryBlue,
                        decoration: _decoration('Student Number'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "This field is required"
                            : null,
                      ),
                      const SizedBox(height: 20),

                      Text('Programme', style: labelStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _programmeController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(color: _textColor),
                        cursorColor: _primaryBlue,
                        decoration: _decoration('Programme'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "This field is required"
                            : null,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndContinue,
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
                          "Continue to upload photo",
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
}
