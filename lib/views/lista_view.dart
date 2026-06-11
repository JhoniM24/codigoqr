import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/comprobante_model.dart';

class ListaView extends StatelessWidget {
  const ListaView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprobantes Guardados'),
      ),
      body: StreamBuilder<List<ComprobanteModel>>(
        stream: firestoreService.obtenerComprobantes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ocurrió un error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final comprobantes = snapshot.data ?? [];

          if (comprobantes.isEmpty) {
            return const Center(
              child: Text('No hay comprobantes registrados aún.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: comprobantes.length,
            itemBuilder: (context, index) {
              final item = comprobantes[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.attach_money, color: Colors.white),
                  ),
                  title: Text(item.nombreEstudiante, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('C.I: ${item.cedula}\nFecha Transf: ${item.fechaTransferencia}'),
                  trailing: Text(
                    '\$${item.monto.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}