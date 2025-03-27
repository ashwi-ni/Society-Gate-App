import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:share/share.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
class QRCodeGenerator extends StatefulWidget {
  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  String entryCode = '';
  final GlobalKey globalKey = GlobalKey();

  String imageUrl = '';


  @override
  void initState() {
    super.initState();
    generateEntryCode();
  }

  void generateEntryCode() {
    setState(() {
      entryCode = randomAlphaNumeric(10); // Generates a random alphanumeric string of length 10
    });
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);
      Share.shareFiles(['${tempDir.path}/image.png'], text: 'QR Code for entry: $entryCode');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _downloadQRCode() async {
    RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(pngBytes));
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('QR Code Generator'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Gate Pass',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : AssetImage('assets/user.jpg') as ImageProvider,maxRadius: 30,

                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Text('Visitor Name', style: TextStyle(fontSize: 18)),
                            Text('Visitor Info', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    RepaintBoundary(
                      key: globalKey,
                      child: QrImageView(
                        data: entryCode,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                    SizedBox(height: 20),
                    SelectableText(
                      entryCode,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: entryCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Entry code copied to clipboard')),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Show QR code or tell OTP to the guard',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _captureAndSharePng,
                          child: Text('Share'),
                        ),
                        ElevatedButton(
                          onPressed: _downloadQRCode,
                          child: Text('Download'),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}