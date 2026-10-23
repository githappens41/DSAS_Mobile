import 'package:dsas_app/views/help_support_screen.dart';
import 'package:dsas_app/views/update_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class MyDetailsPage extends StatelessWidget {
  const MyDetailsPage({super.key});

  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _textColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HelpSupportScreen(),
              ),
            );
          }, icon: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF8B0000),
              radius: 16,
              child: const Text(
                '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),)
          
        ],
      ),
      body: Consumer<ProfileViewmodel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryBlue),
            );
          }

          if (vm.profile == null) {
            return Center(
              child: Text(
                vm.errorMessage ?? 'No profile data available.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            );
          }

          final profile = vm.profile!;

          String initials = 'U';
          if (profile.name.trim().isNotEmpty) {
            final nameParts = profile.name.trim().split(' ');
            if (nameParts.length > 1) {
              initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
            } else {
              initials = nameParts[0][0].toUpperCase();
            }
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: _primaryBlue,

                      
                      backgroundImage: profile.imageUrl.isNotEmpty ? NetworkImage(profile.imageUrl) : null,

                      child: profile.imageUrl.isEmpty ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ) : Container(),
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.studentNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: const Text(
                      'Update information',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade600,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const UpdateProfilePage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
