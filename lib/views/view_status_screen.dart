import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _StepState { done, current, waiting, rejected }

class ViewStatusScreen extends StatefulWidget {
  const ViewStatusScreen({super.key});

  @override
  State<ViewStatusScreen> createState() => _ViewStatusScreenState();
}

class _ViewStatusScreenState extends State<ViewStatusScreen> {
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>?> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    return await Supabase.instance.client
        .from('student_cards')
        .select('status, created_at, rejection_reason')
        .eq('user_id', user.id)
        .maybeSingle();
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // The FutureBuilder shows the error state.
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  List<Widget> _buildSteps(Map<String, dynamic> card) {
    final status = (card['status'] as String?) ?? 'pending';
    final submitted = _formatDate(card['created_at'] as String?);
    final reason = card['rejection_reason'] as String?;

    if (status == 'rejected') {
      return [
        _item('Submitted', submitted, _StepState.done),
        _item('Under Review', 'Completed', _StepState.done),
        _item(
          'Rejected',
          (reason != null && reason.trim().isNotEmpty)
              ? reason
              : 'Your registration was not approved',
          _StepState.rejected,
        ),
        _item('Card collection', 'Not available', _StepState.waiting),
      ];
    }

    // How many steps are finished, and which step (if any) is in progress.
    final int done;
    final int current;
    switch (status) {
      case 'approved':
        done = 3;
        current = -1;
        break;
      case 'ready_for_collection':
        done = 3;
        current = 3;
        break;
      case 'collected':
        done = 4;
        current = -1;
        break;
      default: // pending
        done = 1;
        current = 1;
    }

    _StepState stateOf(int i) {
      if (i < done) return _StepState.done;
      if (i == current) return _StepState.current;
      return _StepState.waiting;
    }

    return [
      _item('Submitted', submitted, stateOf(0)),
      _item(
        'Under Review',
        stateOf(1) == _StepState.done ? 'Completed' : 'Pending',
        stateOf(1),
      ),
      _item(
        'Approved',
        stateOf(2) == _StepState.done ? 'Approved' : 'Waiting',
        stateOf(2),
      ),
      _item(
        'Card collection',
        switch (stateOf(3)) {
          _StepState.done => 'Collected',
          _StepState.current => 'Ready for collection',
          _ => 'Waiting',
        },
        stateOf(3),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Registration Status",
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
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }

              if (snapshot.hasError) {
                return _message(
                  'Could not load your status.\nPull down to try again.',
                );
              }

              final card = snapshot.data;
              if (card == null) {
                return _message(
                  'No registration found.\nGo back and register your student card.',
                );
              }

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                children: [
                  const SizedBox(height: 16),
                  ..._buildSteps(card),
                ],
              );
            },
          ),
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
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _item(String title, String sub, _StepState state) {
    final Color color;
    switch (state) {
      case _StepState.done:
        color = Colors.green;
        break;
      case _StepState.current:
        color = Colors.orange;
        break;
      case _StepState.rejected:
        color = Colors.red;
        break;
      case _StepState.waiting:
        color = Colors.grey;
        break;
    }

    final active = state != _StepState.waiting;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: active ? color : Colors.grey[300],
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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: active ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    color: active ? color : Colors.grey,
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