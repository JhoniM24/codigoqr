import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/comprobante_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  final _nombreCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  final _bancoCtrl = TextEditingController();
  final _numCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();

  bool _isSaving = false;

  void _escanearQR() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        height: 500,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            AppBar(
              title: const Text('Escanear Comprobante QR', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
                clipBehavior: Clip.antiAlias,
                child: MobileScanner(
                  onDetect: (BarcodeCapture capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.displayValue != null) {
                      final String code = barcodes.first.displayValue!;
                      _procesarDatosQR(code);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _procesarDatosQR(String data) {
    try {
      final datos = data.split(',');
      if (datos.length >= 7) {
        setState(() {
          _nombreCtrl.text = datos[0].trim();
          _cedulaCtrl.text = datos[1].trim();
          _conceptoCtrl.text = datos[2].trim();
          _bancoCtrl.text = datos[3].trim();
          _numCtrl.text = datos[4].trim();
          _fechaCtrl.text = datos[5].trim();
          _montoCtrl.text = datos[6].trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Datos cargados con éxito!'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR no compatible. Completa manualmente.'), backgroundColor: Colors.orange),
      );
    }
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final user = _authService.currentUser;
        final comprobante = ComprobanteModel(
          uidUsuario: user?.uid ?? 'anonimo',
          nombreEstudiante: _nombreCtrl.text.trim(),
          cedula: _cedulaCtrl.text.trim(),
          conceptoPago: _conceptoCtrl.text.trim(),
          banco: _bancoCtrl.text.trim(),
          numeroComprobante: _numCtrl.text.trim(),
          fechaTransferencia: _fechaCtrl.text.trim(),
          monto: double.tryParse(_montoCtrl.text.trim()) ?? 0.0,
          fechaRegistro: DateTime.now(),
        );

        await _firestoreService.guardarComprobante(comprobante);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Guardado correctamente en la base de datos'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: (v) => v!.isEmpty ? 'Este campo es obligatorio' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade400, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Registrar Comprobante', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                InkWell(
                  onTap: _escanearQR,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue, Colors.blue.shade700]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Escanear Código QR Automático',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildTextField(controller: _nombreCtrl, label: 'Nombre del Estudiante', icon: Icons.person_outline)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField(controller: _cedulaCtrl, label: 'Cédula / ID', icon: Icons.badge_outlined, type: TextInputType.number)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(controller: _conceptoCtrl, label: 'Concepto de Pago', icon: Icons.receipt_long_outlined)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField(controller: _bancoCtrl, label: 'Banco Emisor', icon: Icons.account_balance_outlined)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(controller: _numCtrl, label: 'Número de Comprobante', icon: Icons.numbers)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField(controller: _fechaCtrl, label: 'Fecha (ej: 09/06/2026)', icon: Icons.calendar_month_outlined)),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildTextField(controller: _nombreCtrl, label: 'Nombre del Estudiante', icon: Icons.person_outline),
                          const SizedBox(height: 14),
                          _buildTextField(controller: _cedulaCtrl, label: 'Cédula / ID', icon: Icons.badge_outlined, type: TextInputType.number),
                          const SizedBox(height: 14),
                          _buildTextField(controller: _conceptoCtrl, label: 'Concepto de Pago', icon: Icons.receipt_long_outlined),
                          const SizedBox(height: 14),
                          _buildTextField(controller: _bancoCtrl, label: 'Banco Emisor', icon: Icons.account_balance_outlined),
                          const SizedBox(height: 14),
                          _buildTextField(controller: _numCtrl, label: 'Número de Comprobante', icon: Icons.numbers),
                          const SizedBox(height: 14),
                          _buildTextField(controller: _fechaCtrl, label: 'Fecha (ej: 09/06/2026)', icon: Icons.calendar_month_outlined),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 14),
                _buildTextField(controller: _montoCtrl, label: 'Monto en Dólares', icon: Icons.attach_money, type: TextInputType.number),
                const SizedBox(height: 36),
                
                _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Guardar Registro en la base de datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}