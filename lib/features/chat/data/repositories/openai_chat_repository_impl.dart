import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stateful_ai/core/enum/chat_model.dart';
import 'package:stateful_ai/core/services/chat_firestore_service.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OpenAIChatRepositoryImpl implements ChatRepository {
  final http.Client _client;
  final ChatFirestoreService _chatService;
  final String _modelKey = ChatModelType.openAI.key; // 'openai'

  OpenAIChatRepositoryImpl(this._client)
    : _chatService = ChatFirestoreService();

  @override
  Future<String> sendMessage(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("OPENAI_API_KEY tidak ditemukan di .env");
    }

    // Simpan pesan user
    await _chatService.addMessage(
      modelKey: _modelKey,
      text: prompt,
      isUser: true,
    );

    // Kirim ke OpenAI
    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 100,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['choices'][0]['message']['content'];

      // Simpan balasan AI
      await _chatService.addMessage(
        modelKey: _modelKey,
        text: reply,
        isUser: false,
      );

      return reply;
    } else {
      final error = jsonDecode(response.body);
      log(response.body, name: 'OpenAI Error');
      throw Exception(error['error']?['message'] ?? 'Unknown error');
    }
  }

  @override
  Future<String> sendMessageWithContext(
    String prompt,
    List<Message> history,
  ) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null) throw Exception("API Key kosong");

    final messages =
        history
            .map(
              (e) => {
                'role': e.isUser ? 'user' : 'assistant',
                'content': e.text,
              },
            )
            .toList();

    messages.add({'role': 'user', 'content': prompt});

    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': messages,
        'max_tokens': 100,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error']?['message'] ?? 'Unknown error');
    }
  }

  @override
  Future<String> sendImageWithContext(
    Uint8List imageBytes,
    List<Message> context, {
    String? prompt,
  }) async {
    // return "❌ Model OpenAI belum mendukung input gambar di versi ini. Gunakan model Gemini untuk fitur ini.";
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("OPENAI_API_KEY tidak ditemukan");
    }

    final base64Image = base64Encode(imageBytes);

    final messages = [
      ...context.map(
        (msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        },
      ),
      {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': 'Berikut gambar yang saya upload:'},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
          },
        ],
      },
    ];

    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': messages,
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(data['error']?['message'] ?? 'Unknown error');
    }
  }

  @override
  Future<List<Message>> getChatHistory({DocumentSnapshot? startAfter}) {
    return _chatService.getChatHistory(
      modelKey: _modelKey,
      startAfter: startAfter,
    );
  }
}
