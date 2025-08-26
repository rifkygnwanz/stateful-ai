import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stateful_ai/core/models/message.dart';
import 'package:stateful_ai/core/services/chat_firestore_service.dart';
import 'package:stateful_ai/features/chat/domain/repositories/chat_repository.dart';

class ChatUseCase {
  final ChatRepository repository;
  final ChatFirestoreService firestoreService;
  final String modelKey;

  ChatUseCase({
    required this.repository,
    required this.firestoreService,
    required this.modelKey,
  });

  Future<String> send(String prompt) async {
    await firestoreService.addMessage(
      modelKey: modelKey,
      text: prompt,
      isUser: true,
    );

    final history = await firestoreService.getChatHistory(
      modelKey: modelKey,
      limit: 10,
    );

    final response = await repository.sendMessageWithContext(
      prompt,
      history.reversed.toList(),
    );

    await firestoreService.addMessage(
      modelKey: modelKey,
      text: response,
      isUser: false,
    );

    return response;
  }

  Future<String> sendImage(
    Uint8List imageBytes, {
    List<Message> context = const [],
    String? prompt,
  }) async {
    final response = await repository.sendImageWithContext(
      imageBytes,
      context,
      prompt: prompt,
    );

    await firestoreService.addMessage(
      modelKey: modelKey,
      text: response,
      isUser: false,
    );

    return response;
  }

  Future<List<Message>> loadHistory({DocumentSnapshot? startAfter}) {
    return firestoreService.getChatHistory(
      modelKey: modelKey,
      startAfter: startAfter,
    );
  }

  Future<void> clearHistory() {
    return firestoreService.clearMessages(modelKey: modelKey);
  }
}
