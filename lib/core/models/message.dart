import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final bool isUser;
  final bool isLoading;
  final DocumentSnapshot? doc;
  final String? imageUrl;
  final Uint8List? localImage;

  Message({
    required this.text,
    this.isUser = false,
    this.isLoading = false,
    this.doc,
    this.imageUrl,
    this.localImage,
  });
}
