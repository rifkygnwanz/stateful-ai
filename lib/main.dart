import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:stateful_ai/core/di/depedency_injection.dart';
import 'package:stateful_ai/core/enum/chat_model.dart';
import 'package:stateful_ai/config/theme/dark_theme.dart';
import 'package:stateful_ai/config/theme/light_theme.dart';
import 'package:stateful_ai/core/utils/chat_usecase_factory.dart';
import 'package:stateful_ai/features/auth/presentation/pages/login_page.dart';
import 'package:stateful_ai/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:stateful_ai/features/chat/presentation/cubit/model_switch_cubit.dart';
import 'package:stateful_ai/config/theme/cubit/theme_cubit.dart';
import 'package:stateful_ai/firebase_options.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chat/presentation/pages/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.I<AuthBloc>()..add(AutoLoginEvent())),
        BlocProvider(create: (_) => GetIt.I<ModelSwitchCubit>()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Stateful AI',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeAnimationCurve: Curves.easeInOut,
            themeAnimationDuration: Duration(milliseconds: 300),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return BlocBuilder<ModelSwitchCubit, ChatModelType>(
            builder: (ctx, model) {
              return BlocProvider<ChatBloc>(
                key: ValueKey(model),
                create:
                    (_) =>
                        ChatBloc(buildChatUseCase(model))
                          ..add(LoadChatHistoryEvent()),
                child: const ChatPage(),
              );
            },
          );
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginPage();
      },
    );
  }
}
