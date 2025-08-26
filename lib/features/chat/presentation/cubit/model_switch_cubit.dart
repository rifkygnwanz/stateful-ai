import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stateful_ai/core/enum/chat_model.dart';

class ModelSwitchCubit extends Cubit<ChatModelType> {
  ModelSwitchCubit() : super(ChatModelType.gemini); // default model

  void switchModel(ChatModelType model) {
    emit(model);
  }
}
