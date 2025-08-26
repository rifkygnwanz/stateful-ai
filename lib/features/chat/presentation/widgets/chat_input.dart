import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stateful_ai/features/chat/presentation/bloc/chat_bloc.dart';

class ChatInput extends StatefulWidget {
  final VoidCallback? onSend;
  const ChatInput({super.key, this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() => _selectedImage = bytes);
  }

  void _send() {
    final text = _controller.text.trim();

    if (_selectedImage != null) {
      context.read<ChatBloc>().add(
        SendImageEvent(_selectedImage!, prompt: text.isEmpty ? null : text),
      );
      _controller.clear();
      setState(() => _selectedImage = null);
      if (widget.onSend != null) widget.onSend!();
      return;
    }

    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessageEvent(text));
      _controller.clear();
      if (widget.onSend != null) widget.onSend!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _selectedImage!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => _selectedImage = null),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Ketik pesan...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.send), onPressed: _send),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
