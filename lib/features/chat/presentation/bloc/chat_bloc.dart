import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stateful_ai/core/models/message.dart';
import 'package:stateful_ai/features/chat/domain/usecases/chat_usecase.dart';

abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String text;
  SendMessageEvent(this.text);
}

class SendImageEvent extends ChatEvent {
  final Uint8List imageBytes;
  final String? prompt;
  SendImageEvent(this.imageBytes, {this.prompt});
}

class LoadChatHistoryEvent extends ChatEvent {}

class LoadMoreChatsEvent extends ChatEvent {}

abstract class ChatState {
  final List<Message> messages;
  ChatState(this.messages);
}

class ChatInitial extends ChatState {
  ChatInitial() : super([]);
}

class ChatLoading extends ChatState {
  ChatLoading(super.messages);
}

class ChatLoaded extends ChatState {
  final bool isNewMessageFromUser;
  ChatLoaded(super.messages, {this.isNewMessageFromUser = false});
}

class ChatError extends ChatState {
  final String error;
  ChatError(this.error, List<Message> messages) : super(messages);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCase _useCase;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  ChatBloc(this._useCase) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<SendImageEvent>(_onSendImage);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<LoadMoreChatsEvent>(_onLoadMoreChats);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final current = List<Message>.from(state.messages);
    current.insert(0, Message(text: event.text, isUser: true));
    current.insert(
      0,
      Message(text: 'Loading ...', isUser: false, isLoading: true),
    );
    emit(ChatLoading(current));

    try {
      final reply = await _useCase.send(event.text);
      current.removeAt(0);
      current.insert(0, Message(text: reply, isUser: false));
      emit(ChatLoaded(current, isNewMessageFromUser: true));
    } catch (e) {
      current.removeAt(0);
      current.insert(0, Message(text: '⚠️ ${e.toString()}', isUser: false));
      emit(ChatError(e.toString(), current));
    }
  }

  Future<void> _onSendImage(
    SendImageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final current = List<Message>.from(state.messages);
    final promptText = event.prompt ?? 'Gambar dikirim';
    current.insert(
      0,
      Message(text: promptText, isUser: true, localImage: event.imageBytes),
    );

    current.insert(
      0,
      Message(text: 'Sedang menganalisis...', isUser: false, isLoading: true),
    );

    emit(ChatLoading(current));

    try {
      final history = await _useCase.loadHistory();

      final reply = await _useCase.sendImage(
        event.imageBytes,
        context: history,
        prompt: event.prompt,
      );
      current.removeAt(0);
      current.insert(0, Message(text: reply, isUser: false));

      emit(ChatLoaded(current, isNewMessageFromUser: true));
    } catch (e) {
      current.removeAt(0);
      current.insert(0, Message(text: 'Gagal kirim gambar: $e', isUser: false));
      emit(ChatError(e.toString(), current));
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    final messages = await _useCase.loadHistory();
    if (messages.isNotEmpty) _lastDoc = messages.last.doc;
    emit(ChatLoaded(messages));
  }

  Future<void> _onLoadMoreChats(
    LoadMoreChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (!_hasMore || state is ChatLoading) return;
    emit(ChatLoading(state.messages));

    final newMsgs = await _useCase.loadHistory(startAfter: _lastDoc);
    if (newMsgs.isNotEmpty) {
      _lastDoc = newMsgs.last.doc;
    } else {
      _hasMore = false;
    }

    emit(ChatLoaded([...state.messages, ...newMsgs]));
  }
}
