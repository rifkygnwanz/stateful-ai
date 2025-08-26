import 'package:stateful_ai/core/enum/chat_model.dart';
import 'package:stateful_ai/core/services/chat_firestore_service.dart';
import 'package:stateful_ai/features/chat/data/repositories/gemini_chat_repository_impl.dart';
import 'package:stateful_ai/features/chat/data/repositories/openai_chat_repository_impl.dart';
import 'package:stateful_ai/features/chat/domain/usecases/chat_usecase.dart';
import 'package:stateful_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

ChatUseCase buildChatUseCase(ChatModelType model) {
  final firestoreService = GetIt.I<ChatFirestoreService>();

  ChatRepository repository;
  switch (model) {
    case ChatModelType.openAI:
      repository = OpenAIChatRepositoryImpl(http.Client());
      break;
    case ChatModelType.gemini:
      repository = GeminiChatRepositoryImpl(chatService: firestoreService);
      break;
  }

  return ChatUseCase(
    repository: repository,
    firestoreService: firestoreService,
    modelKey: model.key,
  );
}
