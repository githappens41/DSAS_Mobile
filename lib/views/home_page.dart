import 'package:dsas_app/viewmodels/profile_viewmodel.dart';
import 'package:dsas_app/viewmodels/register_student_card_view_model.dart';
import 'package:dsas_app/views/active_card_screen.dart';
import 'package:dsas_app/views/help_support_screen.dart';
import 'package:dsas_app/views/inactive_card_screen.dart';
import 'package:dsas_app/views/login_page.dart';
import 'package:dsas_app/views/my_details_page.dart';
import 'package:dsas_app/views/register_student_card_screen.dart';
import 'package:dsas_app/views/view_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        context.read<RegisterStudentCardViewModel>().loadStatus();
      }
    });
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      context.read<ProfileViewmodel>().clearProfile();
      context.read<RegisterStudentCardViewModel>().clear();
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

  Future<void> _openCard() async {
    final reg = context.read<RegisterStudentCardViewModel>();
    await reg.loadStatus();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            reg.isApproved ? const ActiveCardScreen() : const InactiveCardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reg = context.watch<RegisterStudentCardViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Digital Student Access System',
                              style: TextStyle(color: Colors.white, fontSize: 16),
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
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildGridButton(
                  icon: Icons.add,
                  label: 'Register \n Student Card',
                  enabled: reg.canRegister,
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
                  icon: Icons.credit_card_rounded,
                  label: 'View My Card',
                  onTap: _openCard,
                ),
                _buildGridButton(
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

  Widget _buildGridButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final Color iconColor = enabled ? Colors.blue[900]! : Colors.black26;

    return GestureDetector(
      onTap: enabled ? onTap : null,
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
                    color: enabled ? Colors.black87 : Colors.black38,
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