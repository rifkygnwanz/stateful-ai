import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stateful_ai/core/enum/chat_model.dart';
import 'package:stateful_ai/core/utils/chat_usecase_factory.dart';
import 'package:stateful_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stateful_ai/features/auth/presentation/pages/login_page.dart';
import 'package:stateful_ai/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:stateful_ai/features/chat/presentation/cubit/model_switch_cubit.dart';
import 'package:stateful_ai/features/chat/presentation/pages/chat_page.dart';

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
