import 'package:dsas_app/viewmodels/register_student_card_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewStatusScreen extends StatefulWidget {
  const ViewStatusScreen({super.key});

  @override
  State<ViewStatusScreen> createState() => _ViewStatusScreenState();
}

class _ViewStatusScreenState extends State<ViewStatusScreen> {
  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RegisterStudentCardViewModel>().loadStatus();
    });
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  List<Widget> _buildSteps(RegisterStudentCardViewModel vm) {
    final submitted = _formatDate(vm.submittedAt);
    final reason = vm.rejectionReason?.trim() ?? '';

    final String approvedText;
    if (vm.isApproved) {
      approvedText = 'Your student card is approved';
    } else if (vm.isRejected) {
      approvedText = 'Not applicable';
    } else {
      approvedText = 'Pending decision';
    }

    final String rejectedText;
    if (vm.isRejected) {
      rejectedText = reason.isNotEmpty
          ? reason
          : 'Your registration was not approved';
    } else if (vm.isApproved) {
      rejectedText = 'Not applicable';
    } else {
      rejectedText = 'Pending decision';
    }

    return [
      _item(
        'Submitted',
        submitted.isEmpty ? 'Submitted' : submitted,
        Colors.grey,
        true,
      ),
      _item(
        'Under Review',
        vm.isPending ? 'Pending' : 'Completed',
        Colors.amber[700]!,
        true,
      ),
      _item('Approved', approvedText, Colors.green, vm.isApproved),
      _item('Rejected', rejectedText, Colors.red, vm.isRejected),
    ];
  }

  Widget _buildBody(RegisterStudentCardViewModel vm) {
    if (vm.isLoading && !vm.hasLoaded) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator(color: _primaryBlue)),
        ],
      );
    }

    if (!vm.hasLoaded) {
      return _message('Could not load your status.\nPull down to try again.');
    }

    if (!vm.hasCard) {
      return _message(
        'No registration found.\nGo back and register your student card.',
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Your Application',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track the progress of your student card registration.',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 32),
        ..._buildSteps(vm),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registration Status',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<RegisterStudentCardViewModel>(
          builder: (context, vm, _) {
            return RefreshIndicator(
              onRefresh: vm.loadStatus,
              color: _primaryBlue,
              child: _buildBody(vm),
            );
          },
        ),
      ),
    );
  }

  Widget _message(String text) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        const SizedBox(height: 120),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _item(String title, String sub, Color color, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: active ? color : Colors.white,
              border: Border.all(
                color: active ? color : Colors.grey.shade300,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: active ? _textColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 13,
                    color: active ? color : Colors.grey,
                    fontWeight: active ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}