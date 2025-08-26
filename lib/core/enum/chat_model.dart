enum ChatModelType { openAI, gemini }

extension ChatModelTypeExt on ChatModelType {
  String get key {
    switch (this) {
      case ChatModelType.openAI:
        return 'openai';
      case ChatModelType.gemini:
        return 'gemini';
    }
  }
}
