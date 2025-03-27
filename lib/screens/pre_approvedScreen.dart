import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PreApproved extends StatefulWidget {
  const PreApproved({Key? key}) : super(key: key);

  @override
  State<PreApproved> createState() => _PreApprovedState();
}

class _PreApprovedState extends State<PreApproved> {
  bool sendGatePass = false;
  DateTime? selectedDate;
  late TextEditingController enterDateController;

  @override
  void initState() {
    super.initState();
    enterDateController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Visitor',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.black, // Color of the icons
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pre Approve Visitors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Add visitor details for quick action',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: SingleChildScrollView(
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    children: [
                      _buildCard('assets/guest.png', 'Add Guest', () {
                        _showGuestDialog(context);
                      }),
                      _buildCard('assets/cab.png', 'Add Cab', () {
                        _showCabDialog(context);
                      }),
                      _buildCard('assets/delivery.png', 'Add Delivery', () {
                        _showDeliveryDialog(context);
                      }),
                      _buildCard('assets/service.png', 'Add Service', () {
                        _showServiceDialog(context);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String imageUrl, String title, void Function()? onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 230,
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 80,
                    child: Image(
                      image: AssetImage(imageUrl),
                      height: 60,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGuestDialog(BuildContext context) {
    final TextEditingController guestNameController = TextEditingController();
    final TextEditingController guestNumberController = TextEditingController();
    File? profilePicUrl;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              content: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                          final pickedFile = await ImagePicker()
                                              .pickImage(
                                              source: ImageSource.gallery);
                                          if (pickedFile != null) {
                                            setState(() {
                                              profilePicUrl = File(pickedFile.path);
                                            });
                                          }
                                        },
                                      ),
                                      Padding(padding: EdgeInsets.all(8.0)),
                                      GestureDetector(
                                        child: Text('Camera'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final pickedFile = await ImagePicker()
                                              .pickImage(
                                              source: ImageSource.camera);
                                          if (pickedFile != null) {
                                            setState(() {
                                              profilePicUrl = File(pickedFile.path);
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
                          backgroundImage: profilePicUrl != null
                              ? FileImage(profilePicUrl!)
                              : null,
                          child: profilePicUrl == null
                              ? Icon(Icons.camera_alt, size: 30.0)
                              : null,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        'Allow My Guest',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                          'Guest Name', Icons.person, guestNameController,
                          validateGuestName, TextInputType.text),
                      SizedBox(height: 20),
                      _buildTextField(
                          'Guest Number', Icons.phone, guestNumberController,
                          validateGuestNumber, TextInputType.number),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                              'Enter Date', Icons.calendar_today,
                              enterDateController, validateEnterDate,
                              TextInputType.number),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: sendGatePass,
                            onChanged: (bool? value) {
                              setState(() {
                                sendGatePass = value!;
                              });
                            },
                          ),
                          Text('Send gate pass to the guest'),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_validateInputs(guestNameController.text,
                              guestNumberController.text,
                              enterDateController.text)) {
                            String imageUrl = '';
                            if (profilePicUrl != null) {
                              final String fileName =
                                  '${DateTime.now().millisecondsSinceEpoch}.png';
                              final firebase_storage.Reference reference = firebase_storage
                                  .FirebaseStorage.instance
                                  .ref()
                                  .child('profile_images')
                                  .child(fileName);
                              final firebase_storage.UploadTask uploadTask =
                              reference.putFile(profilePicUrl!);
                              final firebase_storage.TaskSnapshot downloadUrl =
                              (await uploadTask);
                              imageUrl = (await downloadUrl.ref.getDownloadURL());
                            }

                            FirebaseFirestore.instance.collection('visitors').add({
                              'name': guestNameController.text,
                              'phoneNumber': guestNumberController.text,
                              'date': enterDateController.text,
                              'profilePicUrl': imageUrl,
                              // Add more fields as needed
                            });
                            Navigator.pop(context); // Close dialog
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String labelText, IconData? prefixIcon,
      TextEditingController controller, String? Function(String?)? validator,
      TextInputType keyboardType) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.black),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        ),
        // Apply the validator function to validate the input
        //validator: validator,
      ),
    );
  }

  bool _validateInputs(String name, String number, String date) {
    if (name.isEmpty || number.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return false;
    }
    return true;
  }

  String? validateGuestName(String? value) {
    if (value!.isEmpty) {
      return 'Guest Name cannot be empty';
    }
    return null;
  }

  String? validateGuestNumber(String? value) {
    if (value!.isEmpty) {
      return 'Guest Number cannot be empty';
    }
    return null;
  }

  String? validateEnterDate(String? value) {
    if (value!.isEmpty) {
      return 'Enter Date cannot be empty';
    }
    return null;
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        enterDateController.text = DateFormat('yyyy-MM-dd').format(
            selectedDate!); // Update the text field
      });
    }
  }

  void _showCabDialog(BuildContext context) {
    final TextEditingController lastFourDigitsController = TextEditingController();
    String? selectedCompany;
    File? profilePicUrl;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                                final pickedFile = await ImagePicker()
                                    .pickImage(
                                    source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setState(() {
                                    profilePicUrl = File(pickedFile.path);
                                  });
                                }
                              },
                            ),


                                  Padding(padding: EdgeInsets.all(8.0)),
                                  GestureDetector(
                                    child: Text('Camera'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final pickedFile = await ImagePicker()
                                          .pickImage(
                                          source: ImageSource.camera);
                                      if (pickedFile != null) {
                                        setState(() {
                                          profilePicUrl = File(pickedFile.path);
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
                backgroundImage: profilePicUrl != null
                    ? FileImage(profilePicUrl!)
                    : null,
                child: profilePicUrl == null
                    ? Icon(Icons.camera_alt, size: 30.0)
                    : null,
              ),
            ),


                  SizedBox(height: 10,),
                  Center(
                    child: Text(
                      'Allow My Cab',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Allow my cab to enter today once in next',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    'Last 4 Digits of Vehicle No.',
                    null, // Prefix icon is null in this case
                    lastFourDigitsController,
                    validateGuestNumber, // Pass the validator function
                    TextInputType.number,
                  ),

                  //_buildTextField('Guest Number', Icons.phone, guestNumberController, validateGuestNumber, TextInputType.number),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Company',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    value: selectedCompany,
                    items: ['Ola', 'Uber', 'Lyft', 'DIDI'].map((company) {
                      return DropdownMenuItem<String>(
                        value: company,
                        child: Text(company),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCompany = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField('Enter Date', Icons.calendar_today,
                          enterDateController, validateEnterDate,
                          TextInputType.number),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: sendGatePass,
                        onChanged: (bool? value) {
                          setState(() {
                            sendGatePass = value!;
                          });
                        },
                      ),
                      Text('Send gate pass to the guest'),
                    ],
                  ),

                  SizedBox(height: 20),
        ElevatedButton(
        onPressed: () async {
        if (_validateCabInputs(lastFourDigitsController.text, selectedCompany)) {
          String imageUrl = '';
          if (profilePicUrl != null) {
            final String fileName =
                '${DateTime.now().millisecondsSinceEpoch}.png';
            final firebase_storage.Reference reference = firebase_storage
                .FirebaseStorage.instance
                .ref()
                .child('profile_images')
                .child(fileName);
            final firebase_storage.UploadTask uploadTask =
            reference.putFile(profilePicUrl!);
            final firebase_storage.TaskSnapshot downloadUrl =
            (await uploadTask);
            imageUrl = (await downloadUrl.ref.getDownloadURL());
          }

        FirebaseFirestore.instance.collection('visitors').add({
        'lastFourDigits': lastFourDigitsController.text,
        'name': selectedCompany,
        'date': enterDateController.text,
        'profilePicUrl': imageUrl,
        // Add more fields as needed
        });
        Navigator.pop(context); // Close dialog
        }
        },
        child: Text('Submit'),
        ),
        ]))));
      },
    );
  }

  bool _validateCabInputs(String lastFourDigits, String? selectedCompany) {
    if (lastFourDigits.isEmpty || selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return false;
    }
    return true;
  }

  void _showDeliveryDialog(BuildContext context) {
    String? selectedCompany;
    String? selectedDay;
    File? profilePicUrl;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

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
                                      final pickedFile = await ImagePicker()
                                          .pickImage(
                                          source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        setState(() {
                                          profilePicUrl = File(pickedFile.path);
                                        });
                                      }
                                    },

                                  ),
                                  Padding(padding: EdgeInsets.all(8.0)),
                                  GestureDetector(
                                    child: Text('Camera'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final pickedFile = await ImagePicker()
                                          .pickImage(
                                          source: ImageSource.camera);
                                      if (pickedFile != null) {
                                        setState(() {
                                          profilePicUrl = File(pickedFile.path);
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
                      backgroundImage: profilePicUrl != null ? FileImage(
                          profilePicUrl!) : null,
                      child: profilePicUrl == null ? Icon(
                          Icons.camera_alt, size: 30.0) : null,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'Select Delivery Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Company',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    value: selectedCompany,
                    items: ['Amazon', 'Flipkart', 'Meesho', 'Myntra'].map((
                        company) {
                      return DropdownMenuItem<String>(
                        value: company,
                        child: Text(company),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCompany = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField('Enter Date', Icons.calendar_today,
                          enterDateController, validateEnterDate,
                          TextInputType.number),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: sendGatePass,
                        onChanged: (bool? value) {
                          setState(() {
                            sendGatePass = value!;
                          });
                        },
                      ),
                      Text('Send gate pass to the guest'),
                    ],
                  ),
                  SizedBox(height: 20),
        ElevatedButton(
        onPressed: () async {
        if (selectedCompany != null && enterDateController.text.isNotEmpty) {
          String imageUrl = '';
          if (profilePicUrl != null) {
            final String fileName =
                '${DateTime.now().millisecondsSinceEpoch}.png';
            final firebase_storage.Reference reference = firebase_storage
                .FirebaseStorage.instance
                .ref()
                .child('profile_images')
                .child(fileName);
            final firebase_storage.UploadTask uploadTask =
            reference.putFile(profilePicUrl!);
            final firebase_storage.TaskSnapshot downloadUrl =
            (await uploadTask);
            imageUrl = (await downloadUrl.ref.getDownloadURL());
          }

        FirebaseFirestore.instance.collection('visitors').add({
        'name': selectedCompany,
        'date': enterDateController.text,
        'profilePicUrl': imageUrl,
        // Add more fields as needed
        });
        Navigator.pop(context); // Close dialog
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
        );
        }
        },
        child: Text('Submit'),
        ),
    ]
              ),
            ),
          ),
        );
      },
    );
  }

  void _showServiceDialog(BuildContext context) {
    final TextEditingController servicemanNameController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

    File? profilePicUrl;
    String? date;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              content: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                                          final pickedFile = await ImagePicker()
                                              .pickImage(
                                              source: ImageSource.gallery);
                                          if (pickedFile != null) {
                                            setState(() {
                                              profilePicUrl =
                                                  File(pickedFile.path);
                                            });
                                          }
                                        },
                                      ),
                                      Padding(padding: EdgeInsets.all(8.0)),
                                      GestureDetector(
                                        child: Text('Camera'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final pickedFile = await ImagePicker()
                                              .pickImage(
                                              source: ImageSource.camera);
                                          if (pickedFile != null) {
                                            setState(() {
                                              profilePicUrl =
                                                  File(pickedFile.path);
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
                          backgroundImage: profilePicUrl != null ? FileImage(
                              profilePicUrl!) : null,
                          child: profilePicUrl == null ? Icon(
                              Icons.camera_alt, size: 30.0) : null,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        'Allow My Serviceman',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight
                            .bold),
                      ),
                      SizedBox(height: 20),
                      _buildTextField('Serviceman/Company Name', Icons.person,
                          servicemanNameController, validateGuestName,
                          TextInputType.text),
                      SizedBox(height: 20),
                      _buildTextField(
                          'Phone Number', Icons.phone, phoneNumberController,
                          validateGuestNumber, TextInputType.number),

              SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField('Enter Date', Icons.calendar_today,
                        enterDateController, validateEnterDate,
                        TextInputType.number),
                  ),),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: sendGatePass,
                    onChanged: (bool? value) {
                      setState(() {
                        sendGatePass = value!;
                      });
                    },
                  ),
                  Text('Send gate pass to the guest'),
                ],
              ),

                      SizedBox(height: 20),
            ElevatedButton(
            onPressed: () async {
            if (_validateServiceInputs(context, servicemanNameController.text, phoneNumberController.text, date)) {
              String imageUrl = '';
              if (profilePicUrl != null) {
                final String fileName =
                    '${DateTime.now().millisecondsSinceEpoch}.png';
                final firebase_storage.Reference reference = firebase_storage
                    .FirebaseStorage.instance
                    .ref()
                    .child('profile_images')
                    .child(fileName);
                final firebase_storage.UploadTask uploadTask =
                reference.putFile(profilePicUrl!);
                final firebase_storage.TaskSnapshot downloadUrl =
                (await uploadTask);
                imageUrl = (await downloadUrl.ref.getDownloadURL());
              }
            FirebaseFirestore.instance.collection('visitors').add({
            'name': servicemanNameController.text,
            'phoneNumber': phoneNumberController.text,
            'date': enterDateController.text,
            'profilePicUrl': imageUrl,
            // Add more fields as needed
            });

            Navigator.pop(context); // Close dialog
            }
            },
            child: Text('Submit'),
            ),

                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  bool _validateServiceInputs(BuildContext context, String servicemanName,
      String phoneNumber, String? date) {
    if (servicemanName.isEmpty || phoneNumber.isEmpty ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return false;
    }
    return true;
  }
}
  void main() {
  runApp(MaterialApp(
    home: PreApproved(),
  ));
}
