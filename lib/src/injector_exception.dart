class InjectorException implements Exception {
  String message;

  InjectorException(this.message);

  @override
  String toString() => "Injector Exception: ${this.message}";
}
