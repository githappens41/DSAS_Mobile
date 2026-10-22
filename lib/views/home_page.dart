import 'package:dsas_app/views/active_card_screen.dart';
import 'package:dsas_app/views/help_support_screen.dart';
import 'package:dsas_app/views/login_page.dart';
import 'package:dsas_app/views/profile_details_page.dart';
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
                height: 270,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 270,
                width: double.infinity,
                color: const Color.fromARGB(161, 0, 0, 0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 45, left: 15, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Digital Student Access System',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
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

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
                      MaterialPageRoute(
                        builder: (_) => const ProfileDetailsPage(),
                      ),
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
          color: const Color(0x0B000000),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(1000),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: IconButton(
                  onPressed: onTap,
                  icon: Icon(icon, color: Colors.white),
                ),
              ),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
