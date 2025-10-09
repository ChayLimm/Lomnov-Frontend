import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.offAllNamed('/'),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text('You are logged in!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
