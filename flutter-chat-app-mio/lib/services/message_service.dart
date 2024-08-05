import 'package:chat/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MessageService with ChangeNotifier {
  PrivateMessages reference = PrivateMessages(from: '0', to: '0');
  void setReference(PrivateMessages ref) {
    this.reference = ref;
    notifyListeners();
  }
}
