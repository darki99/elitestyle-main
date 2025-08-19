import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'booking_screen.dart'; // ⬅️ nueva pantalla

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${user.displayName ?? user.email}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => authService.signOut(),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.calendar_month),
          label: const Text('Reservar corte de pelo'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookingScreen()),
            );
          },
        ),
      ),
    );
  }
}
