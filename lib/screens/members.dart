import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'chat_scren.dart';

class Members extends StatefulWidget {
  const Members({Key? key}) : super(key: key);

  @override
  State<Members> createState() => _MembersState();
}
directCall(String phoneNumber) async {
  await FlutterPhoneDirectCaller.callNumber(phoneNumber);
}

class _MembersState extends State<Members> {
  final CollectionReference membersCollection =
  FirebaseFirestore.instance.collection('members');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Text('Members', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: membersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No members found.'));
          }

          final List<Member> members = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Member(
              profilePicUrl: data['profilePicUrl'] ?? 'assets/user.jpg',
              name: data['name'] ?? 'No Name',
              flatNumber: data['flatNumber'] ?? 'No Flat Number',
              societyName: data['societyName'] ?? 'No Society Name',
              isNetworkImage: data['profilePicUrl']?.startsWith('http') ?? false,
              id: data['id'] ?? 'No id',
              phoneNo:data['phoneNo']?? 'No phone Number',
            );
          }).toList();

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    elevation: 5,
                    child: ListTile(
                      leading: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8), // Adjust this for rounded corners
                          image: DecorationImage(
                            image: member.isNetworkImage
                                ? NetworkImage(member.profilePicUrl)
                                : AssetImage(member.profilePicUrl) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(member.name),
                      subtitle: Text('${member.flatNumber} | ${member.societyName}'),
                      onTap: () {
                        // Show dialog with call and chat options
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(


                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(8), // Adjust this for rounded corners
                                        image: DecorationImage(
                                          image: member.isNetworkImage
                                              ? NetworkImage(member.profilePicUrl)
                                              : AssetImage(member.profilePicUrl) as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text(member.name),

                                  ),
                                  ListTile(

                                    title: Text(member.phoneNo),

                                  ),
                                  ListTile(
                                    leading: Icon(Icons.call),
                                    title: Text('Call'),
                                    onTap: () {
                                      // Close dialog and call the member
                                      Navigator.pop(context);
                                      directCall(member.phoneNo);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.chat),
                                    title: Text('Chat'),
                                    onTap: () {
                                      // Close dialog and navigate to chat screen
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            member: member,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Member {
  final String id;
  final String profilePicUrl;
  final String name;
  final String flatNumber;
  final String societyName;
  final bool isNetworkImage;
  final String phoneNo;
  Member( {
    required this.id,
    required this.profilePicUrl,
    required this.name,
    required this.flatNumber,
    required this.societyName,
    required this.isNetworkImage,
    required this.phoneNo,
  });
}
