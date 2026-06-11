import 'package:cloud_firestore/cloud_firestore.dart';

class ComprobanteModel {
  String? id;
  String uidUsuario;
  String nombreEstudiante;
  String cedula;
  String conceptoPago;
  String banco;
  String numeroComprobante;
  String fechaTransferencia;
  double monto;
  DateTime fechaRegistro;

  ComprobanteModel({
    this.id,
    required this.uidUsuario,
    required this.nombreEstudiante,
    required this.cedula,
    required this.conceptoPago,
    required this.banco,
    required this.numeroComprobante,
    required this.fechaTransferencia,
    required this.monto,
    required this.fechaRegistro,
  });

  // Convierte el objeto a un mapa de datos (Map) para enviarlo a la base de datos de Firebase
  Map<String, dynamic> toMap() {
    return {
      'uidUsuario': uidUsuario,
      'nombreEstudiante': nombreEstudiante,
      'cedula': cedula,
      'conceptoPago': conceptoPago,
      'banco': banco,
      'numeroComprobante': numeroComprobante,
      'fechaTransferencia': fechaTransferencia,
      'monto': monto,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro), // Firebase usa Timestamps para fechas nativas
    };
  }

  // Permite recrear el objeto cuando descarguemos los datos desde Firebase online
  factory ComprobanteModel.fromMap(Map<String, dynamic> map, String id) {
    return ComprobanteModel(
      id: id,
      uidUsuario: map['uidUsuario'] ?? '',
      nombreEstudiante: map['nombreEstudiante'] ?? '',
      cedula: map['cedula'] ?? '',
      conceptoPago: map['conceptoPago'] ?? '',
      banco: map['banco'] ?? '',
      numeroComprobante: map['numeroComprobante'] ?? '',
      fechaTransferencia: map['fechaTransferencia'] ?? '',
      monto: (map['monto'] as num).toDouble(),
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
    );
  }
}