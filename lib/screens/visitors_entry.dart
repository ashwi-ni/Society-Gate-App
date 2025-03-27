import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:share/share.dart';
import 'package:society_gate_app/screens/pre_approvedScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import '../widgets/call_screen.dart';

class VisitorEntry extends StatefulWidget {
  const VisitorEntry({Key? key}) : super(key: key);

  @override
  State<VisitorEntry> createState() => _VisitorEntryState();
}

class _VisitorEntryState extends State<VisitorEntry> {
  List<Visitor> visitors = [];
  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _captureAndSharePng(String entryCode) async {
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
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(Uint8List.fromList(pngBytes));
      print(result);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _loadVisitors() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('visitors').get();
      List<Visitor> loadedVisitors = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Visitor(
          id: doc.id,
          profilePicUrl: data['profilePicUrl'] ?? 'assets/user.jpg',
          name: data['name'] ?? 'Unknown',
          date: data['date'] ?? 'Unknown Date',
          time: data['time'] ?? DateFormat('HH:mm:ss').format(DateTime.now()),
          status: _getStatusFromString(data['status']),
          entryCode: data['entryCode'] ?? randomAlphaNumeric(10),
          phoneNumber: data['phoneNumber'] ?? 'Unknown', // Ensure this is correctly set
        );
      }).toList();

      // Add debug statement here to print out the visitors' information
      loadedVisitors.forEach((visitor) {
        print('Visitor: ${visitor.name}, Phone: ${visitor.phoneNumber}');
      });

      setState(() {
        visitors = loadedVisitors;
      });
    } catch (e) {
      print('Error loading visitors: $e');
    }
  }


  VisitorStatus _getStatusFromString(String? status) {
    switch (status) {
      case 'inside':
        return VisitorStatus.inside;
      case 'preApproved':
        return VisitorStatus.preApproved;
      default:
        return VisitorStatus.unknown;
    }
  }

  Future<void> _deleteVisitor(String id) async {
    try {
      await FirebaseFirestore.instance.collection('visitors').doc(id).delete();
      setState(() {
        visitors.removeWhere((visitor) => visitor.id == id);
      });
    } catch (e) {
      print('Error deleting visitor: $e');
    }
  }

  Uri dialnumber = Uri(scheme: 'tel',path:'1234567890');

  callnumber()async{
    await launchUrl(dialnumber);
  }
  directCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  // Future<void> _launchPhoneCall(String phoneNumber) async {
  //   if (phoneNumber == 'Unknown') {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Phone number is not available')),
  //     );
  //     return;
  //   }
  //
  //   final url = 'tel:$phoneNumber';
  //   print('Attempting to call $phoneNumber'); // Debug statement
  //   if (await canLaunch(url)) {
  //     print('Launching $url'); // Debug statement
  //     await launch(url);
  //   } else {
  //     print('Could not launch $url'); // Debug statement
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not launch phone call')),
  //     );
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text('Visitors', style: TextStyle(color: Colors.black)),
      ),
      body: ListView.builder(
        itemCount: visitors.length,
        itemBuilder: (context, index) {
          final visitor = visitors[index];
          return SizedBox(
            height: 160,
            child: Card(
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: visitor.profilePicUrl != null ? NetworkImage(visitor.profilePicUrl) : null,
                  child: visitor.profilePicUrl == null ? Icon(Icons.camera_alt, size: 30.0) : null,
                ),
                title: SizedBox(height: 30, child: Text(visitor.name)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${visitor.date} | ${visitor.time}'),
                    SizedBox(height: 10),
                    Text(
                        '${getStatusText(visitor.status)}',
                        style: TextStyle(decoration: TextDecoration.underline, color: Colors.red)),
                    Text('--------------------------------------------------------------------'),
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  directCall(visitor.phoneNumber); // Pass the visitor's phone number
                                },
                                icon: Icon(Icons.call),
                              ),

                              Text('Call'),
                            ],
                          ),

                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _deleteVisitor(visitor.id);
                                },
                                icon: Icon(Icons.delete),
                              ),
                              Text('Delete')
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.qr_code, size: 30, color: Colors.grey[600]),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: Padding(
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
                                                backgroundImage: visitor.profilePicUrl != null ? NetworkImage(visitor.profilePicUrl) : null,
                                                child: visitor.profilePicUrl == null ? Icon(Icons.camera_alt, size: 30.0) : null,
                                                maxRadius: 30,
                                              ),
                                              SizedBox(width: 20),
                                              Column(
                                                children: [
                                                  Text(visitor.name, style: TextStyle(fontSize: 18)),
                                                  Text('${visitor.date} | ${visitor.time}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          RepaintBoundary(
                                            key: globalKey,
                                            child: QrImageView(
                                              data: visitor.entryCode,
                                              version: QrVersions.auto,
                                              size: 200.0,
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          SelectableText(
                                            visitor.entryCode,
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: visitor.entryCode));
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
                                                onPressed: () => _captureAndSharePng(visitor.entryCode),
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
                                  ),
                                ),
                              ),
                              Text('Gatepass'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],  // Use backgroundColor instead of primary
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PreApproved()),
            );
          },
          child: Text('Pre-Approve Visitor'),
        ),
      ),
    );
  }

  String getStatusText(VisitorStatus status) {
    switch (status) {
      case VisitorStatus.inside:
        return 'Inside';
      case VisitorStatus.preApproved:
        return 'Pre-approved';
      default:
        return 'Unknown';
    }
  }
}

class Visitor {
  final String id;
  final String profilePicUrl;
  final String name;
  final String date;
  final String time;
  final VisitorStatus status;
  final String entryCode;
  final String phoneNumber; // Add this field

  Visitor({
    required this.id,
    required this.profilePicUrl,
    required this.name,
    required this.date,
    required this.time,
    required this.status,
    required this.entryCode,
    required this.phoneNumber, // Add this parameter
  });
}

enum VisitorStatus { inside, preApproved, unknown }
