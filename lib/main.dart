import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async'; // For the delay

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRScannerPage(),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String scannedData = '';
  String previousScannedData = ''; // Store the previous scanned data
  FlutterTts flutterTts = FlutterTts();
  bool isScanning = false;
  late Timer _timer; // Timer for the 5-second delay

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage('en-US');
    flutterTts.setSpeechRate(0.5);
  }

  void _readText(String text) {
    flutterTts.speak(text);
  }

  // To handle the 5-second delay before reading the QR code again
  void _startCooldown() {
    _timer = Timer(Duration(seconds: 5), () {
      setState(() {
        isScanning = false; // Allow scanning after 5 seconds
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Scanner"),
      ),
      body: Stack(
        children: [
          // QR Scanner
          Positioned.fill(
            child: MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                if (barcodeCapture.barcodes.isNotEmpty) {
                  Barcode barcode = barcodeCapture.barcodes.first;
                  if (barcode.rawValue != null && barcode.rawValue != previousScannedData) {
                    setState(() {
                      scannedData = barcode.rawValue!;
                      previousScannedData = scannedData;
                    });

                    _readText(scannedData); // Read the scanned data aloud
                    _startCooldown(); // Start the 5-second cooldown
                  }
                }
              },
            ),
          ),
          // Scanner overlay with moving scanner bar
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500), // animation speed
              width: 300,
              height: 2,
              color: Colors.green, // Scanner bar
              transform: Matrix4.translationValues(0, isScanning ? 150.0 : -150.0, 0),
            ),
          ),
          // Display the scanned QR code data
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                scannedData.isEmpty ? "Scan a QR code" : "Scanned Data: $scannedData",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
