import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stateful_ai/config/theme/button/switch_theme_button.dart';
import 'package:stateful_ai/core/enum/chat_model.dart';
import 'package:stateful_ai/features/chat/presentation/cubit/model_switch_cubit.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  const ChatAppBar({super.key, this.height = kToolbarHeight});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final currentModel = context.watch<ModelSwitchCubit>().state;

    return AppBar(
      title: const Text('Stateful AI'),
      actions: [
        DropdownButton<ChatModelType>(
          value: currentModel,
          underline: const SizedBox(),
          onChanged: (newModel) {
            if (newModel != null && newModel != currentModel) {
              context.read<ModelSwitchCubit>().switchModel(newModel);
            }
          },
          items:
              ChatModelType.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
        ),
        SwitchThemeButton(),
        Builder(
          builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.format_align_justify),
            );
          },
        ),
      ],
    );
  }
}
