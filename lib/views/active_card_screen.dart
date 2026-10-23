import 'package:barcode_widget/barcode_widget.dart';
import 'package:dsas_app/models/profile.dart';
import 'package:flutter/material.dart';
import '../viewmodels/profile_viewmodel.dart';

class ActiveCardScreen extends StatefulWidget {
  const ActiveCardScreen({super.key});

  @override
  State<ActiveCardScreen> createState() => _ActiveCardScreenState();
}

class _ActiveCardScreenState extends State<ActiveCardScreen> {
  final _vm = ProfileViewmodel();

  @override
  void initState() {
    super.initState();
    _vm.loadProfile();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Card",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (_vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_vm.errorMessage != null || _vm.profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_vm.errorMessage ?? 'No profile found.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _vm.loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildCard(_vm.profile!);
        },
      ),
    );
  }

  Widget _buildCard(Profile p) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.99,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, Color(0xFF1E5B9B)],
                  stops: [0.0, 0.50, 1.0],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/cut_emblem.jpeg',
                          width: 150, fit: BoxFit.cover),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: p.imageUrl.isEmpty
                              ? const Icon(Icons.person, size: 40)
                              : Image.network(
                                  p.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.person, size: 40),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.black)),
                            const SizedBox(height: 1),
                            Text(p.studentNumber,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            const SizedBox(height: 2),
                            Text('Diploma in Information Technology',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                        // Generated barcode (replaces barcode.jpeg)
                        Container(
                          height: 70,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: p.studentNumber.isEmpty
                              ? const Center(
                                  child: Text('No student number',
                                      style: TextStyle(color: Colors.black)))
                              : BarcodeWidget(
                                  barcode: Barcode.code128(),
                                  data: p.studentNumber,
                                  drawText: false,
                                  color: Colors.black,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}