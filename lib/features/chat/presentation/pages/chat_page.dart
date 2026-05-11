import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stateful_ai/features/chat/presentation/widgets/chat_appbar.dart';
import 'package:stateful_ai/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:stateful_ai/features/chat/presentation/widgets/chat_drawer.dart';
import 'package:stateful_ai/features/chat/presentation/widgets/chat_input.dart';
import '../bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  late final StreamSubscription _chatSub;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatHistoryEvent());

    _chatSub = context.read<ChatBloc>().stream.listen((state) {
      if (state is ChatLoaded && state.isNewMessageFromUser) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        context.read<ChatBloc>().add(LoadMoreChatsEvent());
      }
    });
  }

  void scrollToBottomSmooth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatSub.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      endDrawer: ChatDrawer(),
      appBar: ChatAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return const Center(child: Text('Mulai mengobrol...'));
                  }

                  return ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isAI = !msg.isUser;
                      final isFirst = index == 0;
                      return ChatBubble(
                        msg.text,
                        isUser: msg.isUser,
                        imageUrl: msg.imageUrl,
                        localImage: msg.localImage,
                        isLoading: msg.isLoading,
                        animate: isAI && isFirst,
                      );
                    },
                  );
                },
              ),
            ),
            ChatInput(onSend: scrollToBottomSmooth),
          ],
        ),
      ),
    );
  }
}
