import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/escaneo_service.dart';

class MobileScannerScreen extends StatefulWidget {
  final void Function(String codigo) onDetect;

  const MobileScannerScreen({super.key, required this.onDetect});

  @override
  State<MobileScannerScreen> createState() => _MobileScannerScreenState();
}

class _MobileScannerScreenState extends State<MobileScannerScreen> {
  late MobileScannerController scannerController;
  bool _detected = false;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController(
      formats: [
        BarcodeFormat.code128,
        BarcodeFormat.ean13,
      ],
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear')),
      body: MobileScanner(
        controller: scannerController,
        onDetect: (capture) async {
          if (_detected) return;
          final barcode = capture.barcodes.firstOrNull;
          if (barcode?.rawValue != null) {
            _detected = true;
            final codigo = EscaneoService.limpiarCodigo(barcode!.rawValue!);
            await scannerController.stop();
            widget.onDetect(codigo);
          }
        },
      ),
    );
  }
}