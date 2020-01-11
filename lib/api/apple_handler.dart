class AppleHandler {
  static final AppleHandler _instance = AppleHandler._internal();

  factory AppleHandler() {
    return _instance;
  }

  AppleHandler._internal();
}
