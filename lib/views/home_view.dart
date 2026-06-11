import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_view.dart';
import 'registro_view.dart';
import 'lista_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.supervised_user_circle, size: 50, color: Colors.blue),
                    const SizedBox(height: 8),
                    const Text('Usuario Autenticado:', style: TextStyle(color: Colors.grey)),
                    Text(
                      '${user?.email}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner, size: 24),
              label: const Text('Registrar Comprobante', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistroView()),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt, size: 24),
              label: const Text('Ver Registros', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListaView()),
              ),
            ),
            const SizedBox(height: 40),
            TextButton.icon(
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontSize: 16)),
              onPressed: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}