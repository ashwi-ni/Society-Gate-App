import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

void main() {
  runApp(MaterialApp(
    home: ProfileUpdateScreen(),
  ));
}

class ProfileUpdateScreen extends StatefulWidget {
  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  File? _image;
  String? _profilePicUrl; // URL of the profile picture
  final picker = ImagePicker();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneNoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _flatNoController = TextEditingController();
  String _userName = '';
  String _flatNo = '';
  String userId = 'user_id'; // Fixed user ID

  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore and initialize text controllers
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Fetch user data from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usersProfile').doc(userId).get();

    // Set user data to text controllers
    setState(() {
      _userNameController.text = userDoc['userName'];
      _phoneNoController.text = userDoc['phoneNo'];
      _emailController.text = userDoc['email'];
      _flatNoController.text = userDoc['flatNo'];
      _userName = userDoc['userName'];
      _flatNo = userDoc['flatNo'];
      _profilePicUrl = userDoc['profilePicUrl']; // Store profile picture URL
    });
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Function to update profile
  void updateProfile() async {
    // Get the updated information from text fields
    String userName = _userNameController.text;
    String phoneNo = _phoneNoController.text;
    String email = _emailController.text;
    String flatNo = _flatNoController.text;

    try {
      String profilePicUrl = _profilePicUrl ?? ''; // Use existing profile picture URL if available

      // Upload profile picture to Firebase Storage if a new image is selected
      if (_image != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('profile_pictures').child(fileName);
        await ref.putFile(_image!);
        profilePicUrl = await ref.getDownloadURL();
      }

      // Update user information with profile picture URL in Firestore
      await FirebaseFirestore.instance.collection('usersProfile').doc(userId).set({
        'userName': userName,
        'phoneNo': phoneNo,
        'email': email,
        'flatNo': flatNo,
        'profilePicUrl': profilePicUrl,
        // Add additional fields as needed
      });

      // Show a success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Container(
                        child: Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.photo_camera),
                              title: Text('Take a photo'),
                              onTap: () {
                                getImageFromCamera();
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Choose from gallery'),
                              onTap: () {
                                getImageFromGallery();
                                Navigator.pop(context);
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
                //backgroundColor: Colors.grey,
                radius: 50.0,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _profilePicUrl == null ? Icon(Icons.camera_alt, size: 30.0) : null,
              ),



            ),
        SizedBox(height: 16.0),

            // Displaying user name dynamically
            Text(
              'Name: $_userName',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Flat No.: $_flatNo',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: 'User Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phoneNoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email ID',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _flatNoController,
              decoration: InputDecoration(
                labelText: 'Flat No.',
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Call update profile function
                updateProfile();
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
