import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comprobante_model.dart';

class FirestoreService {
  // Referencia directa a la colección online 'comprobantes'
  final CollectionReference _collection = 
      FirebaseFirestore.instance.collection('comprobantes');

  // Función para guardar el comprobante en Firebase de manera online (RF06)
  Future<void> guardarComprobante(ComprobanteModel comprobante) async {
    await _collection.add(comprobante.toMap());
  }

  // Función para escuchar los cambios en tiempo real y listar los comprobantes (RF07)
  Stream<List<ComprobanteModel>> obtenerComprobantes() {
    return _collection
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ComprobanteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }
}