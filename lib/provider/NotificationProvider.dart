import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationProvider with ChangeNotifier {
  List<RemoteMessage> _messages = [];

  List<RemoteMessage> get messages => _messages;

  void addMessage(RemoteMessage message) {
    _messages = [..._messages, message];
    notifyListeners();
  }

  void removeMessage(int index) {
    _messages.removeAt(index);
    notifyListeners();
  }
}
