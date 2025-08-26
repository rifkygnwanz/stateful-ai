import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/message.dart';

abstract class ChatRepository {
  Future<String> sendMessage(String prompt);
  Future<String> sendMessageWithContext(String prompt, List<Message> history);
  Future<String> sendImageWithContext(
    Uint8List imageBytes,
    List<Message> context, {
    String? prompt,
  });
  Future<List<Message>> getChatHistory({DocumentSnapshot? startAfter});
}
