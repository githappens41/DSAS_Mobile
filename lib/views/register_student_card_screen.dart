import 'package:dsas_app/viewmodels/register_student_card_view_model.dart';
import 'package:dsas_app/views/upload_photo_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    final vm = context.read<RegisterStudentCardViewModel>();
    _fullNameController.text = vm.fullName;
    _studentNumberController.text = vm.studentNumber;
    _programmeController.text = vm.programme;
  }

  void _validateAndContinue() {
    if (!_formKey.currentState!.validate()) return;

    context.read<RegisterStudentCardViewModel>().setDetails(
      fullName: _fullNameController.text,
      studentNumber: _studentNumberController.text,
      programme: _programmeController.text,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UploadPhotoScreen()),
    );
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
      errorStyle: const TextStyle(color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: _textColor,
      fontSize: 14,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Please fill in your details',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      const Text('Full Name', style: labelStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _fullNameController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(color: _textColor),
                        cursorColor: _primaryBlue,
                        decoration: _decoration('Full Name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'This field is required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const Text('Student Number', style: labelStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _studentNumberController,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(color: _textColor),
                        cursorColor: _primaryBlue,
                        decoration: _decoration('Student Number'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'This field is required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const Text('Programme', style: labelStyle),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _programmeController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(color: _textColor),
                        cursorColor: _primaryBlue,
                        decoration: _decoration('Programme'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'This field is required'
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
                  onPressed: _validateAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Continue to upload photo',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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