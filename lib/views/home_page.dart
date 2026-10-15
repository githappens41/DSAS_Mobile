import 'package:flutter/material.dart';
import 'package:dsas_app/views/login_page.dart';
import 'package:dsas_app/views/register_student_card_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // hero
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.blue[900],
            child: Padding(
              padding: const EdgeInsets.only(top: 45.0, left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // app name + logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Digital Student Access System',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                      IconButton(
                        // ✅ FIXED: Logout goes back to LoginPage
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // greet user
                  Text(
                    'Hello, Tshepiso',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // welcome message
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
          const SizedBox(height: 20),

          // navigation buttons
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                // --- REGISTER STUDENT CARD (FIXED) ---
                _buildGridButton(
                  context,
                  iconColor: Colors.blue[900]!,
                  icon: Icons.add,
                  label: 'Register \n Student Card',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterStudentCardScreen(),
                      ),
                    );
                  },
                ),

                // --- VIEW MY CARD ---
                _buildGridButton(
                  context,
                  iconColor: Colors.amber[700]!,
                  icon: Icons.credit_card_rounded,
                  label: 'View My Card',
                  onTap: () {
                    // TODO: navigate to card screen
                  },
                ),

                // --- MY DETAILS ---
                _buildGridButton(
                  context,
                  iconColor: Colors.lightBlue[700]!,
                  icon: Icons.person_outline,
                  label: 'My Details',
                  onTap: () {
                    // TODO: navigate to details screen
                  },
                ),

                // --- HELP & SUPPORT ---
                _buildGridButton(
                  context,
                  iconColor: Colors.red[900]!,
                  icon: Icons.question_mark,
                  label: 'Help & Support',
                  onTap: () {
                    // TODO: navigate to help screen
                  },
                ),

                // --- STATUS ---
                _buildGridButton(
                  context,
                  iconColor: Colors.green[700]!,
                  icon: Icons.info_outlined,
                  label: 'Status',
                  onTap: () {
                    // TODO: navigate to status screen
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

  // Helper widget to avoid repeating the same container code 5 times
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
