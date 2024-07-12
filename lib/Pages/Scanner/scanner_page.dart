import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gestaoestoque/componentes/email_sender.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:gestaoestoque/Db/Db_model.dart';
import 'package:gestaoestoque/Pages/pagina_inicla.dart';
import 'package:gestaoestoque/model/produt_model.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  late BarcodeScanner _barcodeScanner;
  Timer? _scanTimer;
  final List<Product> _scannedProducts = [];
  double _totalValue = 0.0;
  final DatabaseHelper dbHelper = DatabaseHelper();
  final EmailSender emailSender = EmailSender();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
      await _cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      _startContinuousScanning();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcodeScanner.close();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startContinuousScanning() {
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _scanImage();
    });
  }

  Future<void> _scanImage() async {
    if (_cameraController.value.isInitialized) {
      try {
        final image = await _cameraController.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);
        final List<Barcode> barcodes =
            await _barcodeScanner.processImage(inputImage);

        for (Barcode barcode in barcodes) {
          final String? code = barcode.rawValue;
          if (code != null) {
            _addProductToList(code);
          }
        }
      } catch (e) {
        print(e);
        _showToast('Erro ao escanear imagem.');
      }
    }
  }

  Future<void> _addProductToList(String barcode) async {
    final product = await dbHelper.getProductByBarcode(barcode);
    if (product != null) {
      setState(() {
        _scannedProducts.add(product);
        _totalValue += product.price;
      });
      _showToast('Produto adicionado: ${product.name}');
    } else {
      _showToast('Produto não encontrado.');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
  }

  void _finalizePurchase() async {
    for (var product in _scannedProducts) {
      product.quantity -= 1;
      await dbHelper.updateProductQuantity(product.id!, product.quantity);
    }

    // Criar relatório e enviar e-mail
    final lowStock =
        _scannedProducts.where((product) => product.quantity < 5).toList();
    final report = lowStock
        .map((product) =>
            'Produto: ${product.name}, Quantidade: ${product.quantity}')
        .join('\n');
    await emailSender.sendEmail(
        'peidinho16@gmail.com', 'Relatório de Estoque', report);

    setState(() {
      _scannedProducts.clear();
      _totalValue = 0.0;
    });
    _showToast('Compra finalizada e relatório enviado!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 42, 42),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 3, 3),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const HomePage(),
            ));
          },
        ),
        title: const Text('Scanner de Produtos',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _isCameraInitialized
              ? SizedBox(
                  height: 250,
                  width: 400,
                  child: CameraPreview(_cameraController),
                )
              : const Center(child: CircularProgressIndicator()),
          Expanded(
            child: ListView.builder(
              itemCount: _scannedProducts.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(_scannedProducts[index].name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        'Preço: R\$ ${_scannedProducts[index].price.toStringAsFixed(2)} | Quantidade: 1',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                          'Total: R\$ ${_scannedProducts[index].price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    Divider(
                      color: Colors.grey[800],
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Valor Total: R\$ ${_totalValue.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _finalizePurchase,
              child: const Text('Finalizar Compra',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
