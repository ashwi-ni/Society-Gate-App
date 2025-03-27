// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class CallScreen extends StatelessWidget {
//
//   final String profilePicUrl;
//   final String name;
//   final String phoneNumber;
//
//   const CallScreen({
//     Key? key,
//     required this.profilePicUrl,
//     required this.name,
//     required this.phoneNumber,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final Uri defaultImageUri = Uri.parse('assets/user.jpg'); // Add a local image as default
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: _getImageProvider(profilePicUrl, defaultImageUri),
//             ),
//             SizedBox(height: 20),
//             Text(
//               name,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 40),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 GestureDetector(
//                   onVerticalDragEnd: (details) async {
//                     final Uri url = Uri(
//                       scheme: 'tel',
//                       path: phoneNumber,
//                     );
//                     try {
//                       if (await canLaunch(url.toString())) {
//                         await launch(url.toString());
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Could not launch $url')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error: $e')),
//                       );
//                     }
//                   },
//                   child: Column(
//                     children: [
//                       Icon(Icons.call, size: 50, color: Colors.green),
//                       Text(
//                         'Swipe up to\nPick Call',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontSize: 16,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Column(
//                     children: [
//                       Icon(Icons.call_end, size: 50, color: Colors.red),
//                       Text(
//                         'End Call',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   ImageProvider _getImageProvider(String profilePicUrl, Uri defaultImageUri) {
//     if (profilePicUrl.isNotEmpty && profilePicUrl.startsWith('http')) {
//       return NetworkImage(profilePicUrl);
//     } else {
//       return AssetImage(defaultImageUri.toString());
//     }
//   }
// }
