import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _controllersLoaded = false;

  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _textColor = Colors.black87;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllersLoaded) {
      _controllersLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final vm = context.read<ProfileViewmodel>();
        if (vm.profile == null && !vm.isLoading) vm.loadProfile();
      });
    }
  }

  void _fillControllers(ProfileViewmodel vm) {
    final profile = vm.profile;
    if (profile == null) return;
    if (_nameController.text.isEmpty) _nameController.text = profile.name;
    if (_emailController.text.isEmpty) _emailController.text = profile.email;
    if (_studentNumberController.text.isEmpty) {
      _studentNumberController.text = profile.studentNumber;
    }
    if (_imageUrlController.text.isEmpty) {
      _imageUrlController.text = profile.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentNumberController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Update Details',

          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProfileViewmodel>(
        builder: (context, vm, _) {
          _fillControllers(vm);

          if (vm.isLoading && vm.profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryBlue),
            );
          }

          if (vm.profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vm.errorMessage ?? 'Profile details are unavailable.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: vm.loadProfile,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = vm.profile!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: profile.imageUrl.trim().isNotEmpty
                      ? NetworkImage(profile.imageUrl)
                      : null,
                  child: profile.imageUrl.trim().isEmpty
                      ? Icon(Icons.person, size: 48, color: _primaryBlue)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              _field('Full name', _nameController),
              const SizedBox(height: 16),
              _field(
                'Email',
                _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _field('Student number', _studentNumberController),
              const SizedBox(height: 16),
              _field('Profile image URL', _imageUrlController),
              const SizedBox(height: 24),
              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final ok = await context
                              .read<ProfileViewmodel>()
                              .updateProfile(
                                name: _nameController.text,
                                email: _emailController.text,
                                studentNumber: _studentNumberController.text,
                                imageUrl: _imageUrlController.text,
                              );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Profile updated.'
                                    : context
                                              .read<ProfileViewmodel>()
                                              .errorMessage ??
                                          'Profile update failed.',
                              ),
                            ),
                          );
                        },
                  child: vm.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textColor),
      cursorColor: _primaryBlue,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
      ),
    );
  }
}
