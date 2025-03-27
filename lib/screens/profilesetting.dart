
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:share/share.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_gate_app/screens/setting_screen.dart';
import 'dart:io';
import '../model/profile_model.dart';


class ProfileSettings extends StatefulWidget {
  // final Function(Locale) setLocale; // Add this line
  //
  // ProfileSettings({required this.setLocale}); // Add this constructor

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  File? _image;
  List<FamilyMember> familyMembers = [];
  List<DailyHelp> dailyHelps = [];
  List<Vehicle> vehicles = [];
  List<FrequentEntry> frequentEntries = [];
  String entryCode = '';
  final GlobalKey globalKey = GlobalKey();
  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    print("Locale set to: ${locale.languageCode}"); // Add this line
  }
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
  Locale _locale = Locale('en');

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
  Future<String> _uploadImage(File imageFile) async {
    try {
      // Create a reference to the Firebase Storage bucket
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageReference = storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to the reference
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }


  // Define your Firestore instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  void _showFamilyForm() {
    File? capturedImage;
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String mblNo = '';
    String relation = '';
    bool sendGatePass = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  // Icon(Icons.camera_alt),
                  SizedBox(width: 8.0),
                  Text('Add Family Member'),
                ],
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Select Image Source'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Text('Gallery'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                          if (pickedFile != null) {
                                            setState(() {
                                              _image = File(pickedFile.path);
                                            });
                                          }
                                        },
                                      ),
                                      Padding(padding: EdgeInsets.all(8.0)),
                                      GestureDetector(
                                        child: Text('Camera'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                          if (pickedFile != null) {
                                            setState(() {
                                              _image = File(pickedFile.path);
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: _image != null ? FileImage(_image!) : null,
                          child: _image == null ? Icon(Icons.camera_alt, size: 30.0) : null,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          name = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Mobile Number'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a mobile number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          mblNo = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Relation'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a relation';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          relation = value!;
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Send Gate Pass to Guest'),
                        value: sendGatePass,
                        onChanged: (bool? value) {
                          setState(() {
                            sendGatePass = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Submit'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      String imageUrl = '';
                      if (_image != null) {
                        imageUrl = await _uploadImage(_image!);
                      }
                      // Add family member to Firestore
                      await FirebaseFirestore.instance.collection('familyMembers').add({
                        'name': name,
                        'mobileNumber': mblNo,
                        'relation': relation,
                        'sendGatePass': sendGatePass,
                        'image':imageUrl
                        // Add other fields as needed
                      });

                      // Close the dialog
                      Navigator.of(context).pop();
                    }
                  },
                ),

              ],
            );
          },
        );
      },
    );

  }

  void _showDailyHelpForm() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String mblNo = '';
    bool sendGatePass = true;
    String helpType = 'Milkman';
    List<String> helpTypes = ['Milkman', 'Maid', 'Postman', 'Cook'];
    File? capturedImage;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
        return AlertDialog(
          title: Row(
            children: [
              SizedBox(width: 8.0),
              Text('Add Daily Help'),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Select Image Source'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Text('Gallery'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        setState(() {
                                          _image = File(pickedFile.path);
                                        });
                                      }
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.all(8.0)),
                                  GestureDetector(
                                    child: Text('Camera'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                      if (pickedFile != null) {
                                        setState(() {
                                          _image = File(pickedFile.path);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null ? Icon(Icons.camera_alt, size: 30.0) : null,
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Mobile Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a mobile number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      mblNo = value!;
                    },
                  ),
                  DropdownButtonFormField(
                    value: helpType,
                    decoration: InputDecoration(labelText: 'Help Type'),
                    items: helpTypes.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        helpType = newValue.toString();
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Send Gate Pass to Guest'),
                    value: sendGatePass,
                    onChanged: (bool? value) {
                      setState(() {
                        sendGatePass = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  String imageUrl = '';
                  if (_image != null) {
                    imageUrl = await _uploadImage(_image!);
                  }
                  // Add family member to Firestore
                  await FirebaseFirestore.instance.collection('dailyHelps').add({
                    'name': name,
                    'mobileNumber': mblNo,
                    "helpType":helpType,
                   'sendGatePass': sendGatePass,
                    'image':imageUrl
                    // Add other fields as needed
                  });

                  // Close the dialog
                  Navigator.of(context).pop();
                }
              },
            ),

          ],
        );
      },
        );
      }
      );
  }

  void _showVehicleForm() {
    File? capturedImage;
    final _formKey = GlobalKey<FormState>();
    String vehicleNo = '';
    String model = '';
    String color = '';
bool sendGatePass =true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  SizedBox(width: 8.0),
                  Text('Add Vehicle'),
                ],
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Your form fields here
                      InkWell(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Select Image Source'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Text('Gallery'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                          if (pickedFile != null) {
                                            setState(() {
                                              _image = File(pickedFile.path);
                                            });
                                          }
                                        },
                                      ),
                                      Padding(padding: EdgeInsets.all(8.0)),
                                      GestureDetector(
                                        child: Text('Camera'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                          if (pickedFile != null) {
                                            setState(() {
                                              _image = File(pickedFile.path);
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: _image != null ? FileImage(_image!) : null,
                          child: _image == null ? Icon(Icons.camera_alt, size: 30.0) : null,
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Vehicle Number'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a vehicle number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          vehicleNo = value ?? '';// Use ?? to provide a default value
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Model'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a model';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          model = value ?? ''; // Use ?? to provide a default value
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Color'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a color';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          color =value ?? '';// Use ?? to provide a default value
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Send Gate Pass to Guest'),
                        value: sendGatePass,
                        onChanged: (bool? value) {
                          setState(() {
                            sendGatePass = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Submit'),
                  onPressed: () async {
            if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            // Upload the image to Firebase Storage and get the download URL
            String imageUrl = '';
            if (_image != null) {
            imageUrl = await _uploadImage(_image!);
            }
                      // Add vehicle to Firestore
                      await FirebaseFirestore.instance.collection('vehicles').add({
                        'vehicleNumber': vehicleNo,
                        'model': model,
                        'color': color,
                        'sendGatePass': sendGatePass,
                        'image':imageUrl
                        // Add other fields as needed
                      });

                      // Close the dialog
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showFrequentEntryForm() {
    final _formKey = GlobalKey<FormState>();
    String name = ''; // Changed from String? to String
    String mblNo = ''; // Changed from String? to String
    String relation = '';
    bool sendGatePass=true;
    File? capturedImage;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
        return AlertDialog(
          title: Row(
            children: [
              SizedBox(width: 8.0),
              Text('Add Frequent Entries'),
            ],
          ),

          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Select Image Source'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Text('Gallery'),
                              onTap: () async {
                                Navigator.pop(context);
                                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setState(() {
                                    _image = File(pickedFile.path);
                                  });
                                }
                              },

                                  ),
                                  Padding(padding: EdgeInsets.all(8.0)),
                                  GestureDetector(
                                    child: Text('Camera'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                      if (pickedFile != null) {
                                        setState(() {
                                          _image = File(pickedFile.path);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null ? Icon(Icons.camera_alt, size: 30.0) : null,
                    ),
                  ),


                  SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Mobile Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a mobile number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      mblNo = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Relation'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a relation';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      relation = value!;
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Send Gate Pass to Guest'),
                    value: sendGatePass,
                    onChanged: (bool? value) {
                      setState(() {
                        sendGatePass = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Upload the image to Firebase Storage and get the download URL
                    String imageUrl = '';
                    if (_image != null) {
                      imageUrl = await _uploadImage(_image!);
                    }

                    // Add the entry to Firestore
                    await FirebaseFirestore.instance.collection('frequentEntries').add({
                      'name': name,
                      'mobileNumber': mblNo,
                      'relation': relation,
                      'sendGatePass':sendGatePass,
                      'image': imageUrl,
                    });

                    // Close the dialog
                    Navigator.of(context).pop();
                  }
                }
            ),
          ],
        );
      },
        );
      }
        );
  }

  Widget _buildSection(String title, VoidCallback onAddPressed, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: onAddPressed,
                child: Text(' + Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],  // Use backgroundColor instead of primary
                  foregroundColor: Colors.white,      // Use foregroundColor instead of onPrimary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: items),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Text('Profile Settings', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, 'settings');


            },
          ),

        ],
        leading: IconButton(
          icon: Icon(Icons.chevron_left_outlined, color: Colors.blueGrey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            _buildFirestoreSection(
              'My Family',
              _showFamilyForm,
              'familyMembers',
                  (data) => _buildItemCard(data['name'], data['relation'], data['image']),
            ),
            Divider(thickness: 1, color: Colors.grey),
            _buildFirestoreSection(
              'Daily Help',
              _showDailyHelpForm,
              'dailyHelps',
                  (data) => _buildItemCard(data['name'], data['helpType'], data['image']),
            ),
            Divider(thickness: 1, color: Colors.grey),
            _buildFirestoreSection(
              'My Vehicles',
              _showVehicleForm,
              'vehicles',
                  (data) => _buildVehicleCard(data['vehicleNumber'], '${data['model']} (${data['color']})', data['image']),
            ),
            Divider(thickness: 1, color: Colors.grey),
            _buildFirestoreSection(
              'Frequent Entries',
              _showFrequentEntryForm,
              'frequentEntries',
                  (data) => _buildItemCard(data['name'], data['relation'], data['image']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    String userId = 'user_id';
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usersProfile').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while data is being fetched
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>; // Cast userData to the correct type
        var userName = userData['userName'] as String; // Cast to String
        var flatNo = userData['flatNo'] as String; // Cast to String
        var profilePicUrl = userData['profilePicUrl'] as String; // Cast to String
        var phoneNo = userData['phoneNo'] as String; // Cast to String
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey[200],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundImage: profilePicUrl != null
                    ? NetworkImage(profilePicUrl)
                    : AssetImage('assets/user.jpg') as ImageProvider<Object>,
              ),

              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  _buildSocietyDetails(flatNo,phoneNo),
                ],
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.qr_code, size: 40, color: Colors.grey[600]),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Your existing code for QR code dialog
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocietyDetails(String flatNo,String phoneNo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.home),
            SizedBox(width: 8.0),
            Text('Flat No: $flatNo'),
          ],
        ),

        SizedBox(height: 8.0),
        Row(
          children: [
            Icon(Icons.apartment),
            SizedBox(width: 8.0),
            Text('Phone No:$phoneNo'),
          ],
        ),
      ],
    );
  }

  Widget _buildFirestoreSection(
      String title,
      VoidCallback onAddPressed,
      String collectionName,
      Widget Function(Map<String, dynamic> data) itemBuilder,
      ) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<Widget> items = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return itemBuilder(data);
        }).toList();

        return _buildSection(title, onAddPressed, items);
      },
    );
  }

  Widget _buildItemCard(String name, String subtitle, String? imageUrl) {
    return SizedBox(
      width: 150,
      height: 130,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : AssetImage('assets/user.jpg') as ImageProvider,maxRadius: 30,

                  ),

      IconButton(
        icon: Icon(Icons.qr_code, size: 40, color: Colors.grey[600]),
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
          ),
        ),
      ),


                    ],
              ),
             // SizedBox(height: 10),
              Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 5),
              Text(subtitle, style: TextStyle(color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(String vehicleNumber, String subtitle, String? imageUrl) {
    return SizedBox(
      width: 150,
      height: 130,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : AssetImage('assets/user.jpg') as ImageProvider,maxRadius: 30,
                  ),
                  IconButton(
                    icon: Icon(Icons.qr_code, size: 40, color: Colors.grey[600]),
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
                      ),
                    ),
                  ),
                ],
              ),
             // SizedBox(height: 20),
              Text(vehicleNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 5),
              Text(subtitle, style: TextStyle(color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }
}

