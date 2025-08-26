import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:stateful_ai/core/enum/chat_model.dart';
import 'package:stateful_ai/core/services/chat_firestore_service.dart';
import 'package:stateful_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:stateful_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:stateful_ai/features/chat/data/repositories/gemini_chat_repository_impl.dart';
import 'package:stateful_ai/features/chat/data/repositories/openai_chat_repository_impl.dart';
import 'package:stateful_ai/features/chat/domain/usecases/chat_usecase.dart';
import 'package:stateful_ai/features/chat/presentation/cubit/model_switch_cubit.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuth>(), getIt<GoogleSignIn>()),
  );

  getIt.registerLazySingleton<ChatFirestoreService>(
    () => ChatFirestoreService(),
  );

  // Tetap disimpan karena digunakan global untuk switch model
  getIt.registerLazySingleton<ModelSwitchCubit>(() => ModelSwitchCubit());

  // BLoC Auth saja yang tetap pakai GetIt
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
}

ChatUseCase provideChatUseCase(ChatModelType model) {
  switch (model) {
    case ChatModelType.openAI:
      return ChatUseCase(
        modelKey: model.key,
        firestoreService: getIt<ChatFirestoreService>(),
        repository: OpenAIChatRepositoryImpl(getIt<http.Client>()),
      );
    case ChatModelType.gemini:
      return ChatUseCase(
        modelKey: model.key,
        firestoreService: getIt<ChatFirestoreService>(),
        repository: GeminiChatRepositoryImpl(),
      );
  }
}
