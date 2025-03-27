import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../provider/NotificationProvider.dart';


class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Provider.of<NotificationProvider>(context, listen: false).addMessage(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.messages.isEmpty) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_rounded),
                SizedBox(width: 8),
                Text("No new notification",style: TextStyle(fontSize: 15)),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: provider.messages.length,
          itemBuilder: (context, index) {
            RemoteMessage message = provider.messages[index];
            String? imageUrl = message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl;

            return Dismissible(
              key: Key(message.messageId ?? index.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                provider.removeMessage(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notification dismissed')),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: imageUrl != null
                    ? Image.network(imageUrl)
                    : Icon(Icons.image_not_supported),
                title: Text(
                  message.notification?.title ?? "No Title",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(message.sentTime?.toString() ?? DateTime.now().toString()),
                trailing: Icon(
                  Icons.notifications_active,
                  color: Colors.red,
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  "/message",
                  // arguments:MessageArguments(message,false)
                ),
              ),
            );
          },
        );
      },
    );
  }
}
