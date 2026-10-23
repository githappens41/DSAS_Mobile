import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I register my student card?',
      'answer':
          'Tap Register Student Card on the home page, enter your details, then upload your photo and proof of registration.',
    },
    {
      'question': 'What documents do I need?',
      'answer':
          'A clear, front-facing photo and your proof of registration as a PDF.',
    },
    {
      'question': 'How do I track my registration?',
      'answer':
          'Open the Status tab on the home page to see whether your registration is submitted, under review, approved or rejected.',
    },
    {
      'question': 'Why can I not see my student card?',
      'answer':
          'Your student card becomes active only after your registration is approved. Until then an inactive card is shown.',
    },
    {
      'question': 'What if my registration is rejected?',
      'answer':
          'Check the reason on the Status page. Register Student Card becomes available again so you can submit a new registration.',
    },
    {
      'question': 'Can I register again while pending or approved?',
      'answer':
          'No. You can only register again if your previous registration was rejected.',
    },
    {
      'question': 'How do I update my details or photo?',
      'answer':
          'Open My Details, tap Update information, then change your details or tap the photo to choose a new one.',
    },
  ];

  void _showFaq(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _faqs.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  return ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    iconColor: Colors.blue[900],
                    collapsedIconColor: Colors.black54,
                    title: Text(
                      faq['question']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    children: [
                      Text(
                        faq['answer']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Text(
                    '?',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "We're here to assist you. Find answers to common questions or contact our support team",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSupportTile(
              Icons.description_outlined,
              'Frequently Asked Questions',
              'Quick answers for common questions',
              onTap: () => _showFaq(context),
            ),
            _buildSupportTile(
              Icons.phone_outlined,
              'Contact Support',
              '+27 68 680 6972\ngithappens41@gmail.com',
              threeLine: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    bool threeLine = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        isThreeLine: threeLine,
        leading: Icon(icon, color: Colors.blue[900], size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.black54)
            : null,
      ),
    );
  }
}