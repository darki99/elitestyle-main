import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Salir'),
        ],
      ),
      body: Center(
        child: Text('¡Hola, ${user?.email ?? 'usuario'}!',
            style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
