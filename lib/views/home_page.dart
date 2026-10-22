import 'package:dsas_app/views/active_card_screen.dart';
import 'package:dsas_app/views/help_support_screen.dart';
import 'package:dsas_app/views/login_page.dart';
import 'package:dsas_app/views/my_details_page.dart';
import 'package:dsas_app/views/view_status_screen.dart';
import 'package:dsas_app/viewmodels/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dsas_app/views/register_student_card_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileViewmodel>().loadProfile();
      }
    });
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      context.read<ProfileViewmodel>().clearProfile();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/homepage_hero.jpeg',
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 240,
                width: double.infinity,
                color: const Color.fromARGB(181, 0, 0, 0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 45, left: 15, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Title & Sign out
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Digital Student Access System',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Sign out',
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Greeting
                      Selector<ProfileViewmodel, String>(
                        selector: (_, vm) =>
                            vm.profile?.name.trim().split(' ').first ?? '',
                        builder: (context, firstName, _) {
                          return Text(
                            firstName.isNotEmpty
                                ? 'Hello, $firstName'
                                : 'Hello!',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        'Welcome to your student digital access system',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Grid Buttons
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildGridButton(
                  context,
                  iconColor: Colors.blue[900]!,
                  icon: Icons.add,
                  label: 'Register \n Student Card',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterStudentCardScreen(),
                      ),
                    );
                  },
                ),

                _buildGridButton(
                  context,
                  iconColor: Colors.amber[700]!,
                  icon: Icons.credit_card_rounded,
                  label: 'View My Card',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ActiveCardScreen(),
                      ),
                    );
                  },
                ),

                _buildGridButton(
                  context,
                  iconColor: Colors.lightBlue[700]!,
                  icon: Icons.person_outline,
                  label: 'My Details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyDetailsPage()),
                    );
                  },
                ),

                _buildGridButton(
                  context,
                  iconColor: Colors.red[900]!,
                  icon: Icons.question_mark,
                  label: 'Help & Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),

                _buildGridButton(
                  context,
                  iconColor: Colors.green[700]!,
                  icon: Icons.info_outlined,
                  label: 'Status',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ViewStatusScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildGridButton(
    BuildContext context, {
    required Color iconColor,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
