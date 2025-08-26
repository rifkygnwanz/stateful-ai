import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stateful_ai/core/services/chat_firestore_service.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/models/message.dart';
import '../../../../core/enum/chat_model.dart';

class GeminiChatRepositoryImpl implements ChatRepository {
  final ChatFirestoreService _chatService;
  final String _modelKey = ChatModelType.gemini.key; // 'gemini'

  GeminiChatRepositoryImpl({ChatFirestoreService? chatService})
    : _chatService = chatService ?? ChatFirestoreService();

  @override
  Future<String> sendMessage(String prompt) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("GEMINI_API_KEY tidak ditemukan di .env");
    }

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    await _chatService.addMessage(
      modelKey: _modelKey,
      text: prompt,
      isUser: true,
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final reply =
          response.text?.trim() ?? "Maaf, tidak bisa menjawab saat ini.";

      // Simpan jawaban AI
      await _chatService.addMessage(
        modelKey: _modelKey,
        text: reply,
        isUser: false,
      );

      return reply;
    } catch (e) {
      throw Exception("Gemini Error: ${e.toString()}");
    }
  }

  @override
  Future<String> sendMessageWithContext(
    String prompt,
    List<Message> history,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey!);

    final content = [
      ...history.map((e) => Content.text(e.text)),
      Content.text(prompt),
    ];

    final response = await model.generateContent(content);
    return response.text?.trim() ?? 'Maaf, tidak bisa menjawab';
  }

  @override
  Future<String> sendImageWithContext(
    Uint8List imageBytes,
    List<Message> context, {
    String? prompt,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("GEMINI_API_KEY tidak ditemukan");
    }

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final promptText =
        prompt?.trim().isNotEmpty == true
            ? prompt!
            : 'Tolong analisa gambar ini dan berikan penjelasan.';

    final imageContent = Content.multi([
      TextPart(promptText),
      DataPart('image/jpeg', imageBytes),
    ]);

    final contents = [
      ...context.map((e) => Content.text(e.text)),
      imageContent,
    ];

    final response = await model.generateContent(contents);

    return response.text ?? "Tidak ada respons dari gambar.";
  }

  @override
  Future<List<Message>> getChatHistory({DocumentSnapshot? startAfter}) {
    return _chatService.getChatHistory(
      modelKey: _modelKey,
      startAfter: startAfter,
    );
  }
}
