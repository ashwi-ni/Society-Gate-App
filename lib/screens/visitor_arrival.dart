import 'package:flutter/material.dart';

import 'notification_list.dart';
class VisitorArrival extends StatefulWidget {
  const VisitorArrival({Key? key}) : super(key: key);

  @override
  State<VisitorArrival> createState() => _VisitorArrivalState();
}

class _VisitorArrivalState extends State<VisitorArrival> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      iconTheme:IconThemeData(color: Colors.black),
      title:Text("Notification",style: TextStyle(color: Colors.black),),
      actions: [IconButton(
          onPressed: (){},
          icon: Icon(Icons.notifications_active)
      )
      ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
               child:
               Center(
              //     child: Text("Notification List")),

            child: MessageList(),),
            )],
        ),
      ),
    );
  }
}
