import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:society_gate_app/local_notification_service.dart';
import 'package:society_gate_app/screens/profilesetting.dart';
import 'package:society_gate_app/screens/visitor_arrival.dart';
import 'package:society_gate_app/screens/visitors_entry.dart';
import 'members.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String userName = 'Loading...';
  String profilePicUrl = '';
  // Locale _locale = Locale('en');
  //
  // void _setLocale(Locale locale) {
  //   setState(() {
  //     _locale = locale;
  //   });
  // }
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Handle the message
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        LocalNotificationService.createAndDisplayNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.notification != null) {
        // Handle the message
      }
    });

    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      String userId = 'user_id'; // Replace with actual user ID retrieval logic
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance.collection('usersProfile').doc(userId).get();
      final Map<String, dynamic> userData = userDoc.data() ?? {};

      if (userData.isNotEmpty) {
        print('User data fetched: $userData'); // Debug statement
        setState(() {
          userName = userData['userName'] ?? 'No Name';
          profilePicUrl = userData['profilePicUrl'] ?? 'assets/user.jpg';
        });
      } else {
        print('No user data found');
        setState(() {
          userName = 'No Name';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        userName = 'Error';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget selectedScreen;
    switch (index) {
      case 0:
        selectedScreen = HomeScreen();
        break;
      case 1:
        selectedScreen = Members();
        break;

      case 2:
        selectedScreen = ProfileSettings();
        break;

      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => selectedScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Text(
                  'Welcome, $userName',
                  style: TextStyle(color: Colors.black, fontSize: 25, fontStyle: FontStyle.normal),
                ),
                Text(
                  "Sevengen society",
                  style: TextStyle(color: Colors.grey[600], fontSize: 20),
                ),
              ],
            ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 25),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(profilePicUrl),
                  radius: 30,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.grey],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Manage Visitors',
                              style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              'Stay updated on arrivals',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Add your onPressed function here
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.orangeAccent),
                              fixedSize: MaterialStateProperty.all(Size.fromWidth(200)),
                            ),
                            child: Text('APPROVE'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Text('Visitor schedule', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Container(
              color: Color(0xffcbcbcb),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  children: [
                    _buildGridItem(context, 'Members', 'Connect society members', 'assets/group.png', Members()),
                    _buildGridItem(context, 'Visitor Arrivals', 'Notifications of visitor', 'assets/notify.png', VisitorArrival()),
                    _buildGridItem(context, 'Visitor', 'Manage visitors entry', 'assets/visitor.png', VisitorEntry()),
                    _buildGridItem(context, 'Profile Setting', 'User profile update', 'assets/setting.png', ProfileSettings(),
                    )],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined, size: 30), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, String subtitle, String imagePath, Widget destination) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        },
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Image.asset(imagePath, height: 60),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
