import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';

class ChatFirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatFirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Simpan pesan (user atau AI)
  Future<void> addMessage({
    required String modelKey,
    required String text,
    required bool isUser,
    Uint8List? localImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messagesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(modelKey)
        .collection('messages');

    await messagesRef.add({
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
      // localImage tidak perlu disimpan ke Firestore (sementara)
    });
  }

  /// Ambil riwayat chat
  Future<List<Message>> getChatHistory({
    required String modelKey,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    Query query = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(modelKey)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Message(
        text: data['text'] ?? '',
        isUser: data['isUser'] ?? false,
        doc: doc,
      );
    }).toList();
  }

  Future<void> clearMessages({required String modelKey}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messagesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(modelKey)
        .collection('messages');

    final snapshot = await messagesRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> addImageMessage({
    required String modelKey,
    required String imageUrl,
    String? text,
    required bool isUser,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messagesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(modelKey)
        .collection('messages');

    await messagesRef.add({
      'text': text ?? '',
      'imageUrl': imageUrl,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, String>>> getFormattedMessagesForContext({
    required String modelKey,
    int limit = 10,
  }) async {
    final messages = await getChatHistory(modelKey: modelKey, limit: limit);

    return messages.reversed.map((msg) {
      return {'role': msg.isUser ? 'user' : 'model', 'content': msg.text};
    }).toList();
  }
}
