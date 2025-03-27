import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'members.dart';

class ChatScreen extends StatefulWidget {
  final Member member;

  const ChatScreen({
    Key? key,
    required this.member,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.member.isNetworkImage
                  ? NetworkImage(widget.member.profilePicUrl)
                  : AssetImage('assets/default_avatar.jpg') as ImageProvider,
            ),
            SizedBox(width: 10),
            Text(
              widget.member.name,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          Divider(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Chatmessages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading messages'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No messages yet'));
        }

        var messages = snapshot.data!.docs;
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            return GestureDetector(
              onLongPress: () => _showDeleteDialog(message),
              child: _buildMessageBubble(message),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(QueryDocumentSnapshot message) {
    var messageText = message['text'];
    var messageSenderId = message['senderId'];

    return BubbleNormal(
      text: messageText,
      isSender: messageSenderId == widget.member.id,
      color: messageSenderId == widget.member.id ? Colors.green : Color(0xFF1B97F3),
      tail: true,
      textStyle: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage(_messageController.text);
              }
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    FirebaseFirestore.instance.collection('Chatmessages').add({
      'text': message,
      'senderId': widget.member.id,
      'timestamp': DateTime.now(),
    }).then((value) {
      _messageController.clear();
    }).catchError((error) {
      print("Failed to send message: $error");
    });
  }

  void _showDeleteDialog(QueryDocumentSnapshot message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteMessage(message);
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(QueryDocumentSnapshot message) {
    FirebaseFirestore.instance.collection('Chatmessages').doc(message.id).delete().catchError((error) {
      print("Failed to delete message: $error");
    });
  }
}
