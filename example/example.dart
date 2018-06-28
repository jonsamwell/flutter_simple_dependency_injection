import 'package:flutter_simple_dependency_injection/injector.dart';

void main() {
  final injector = Injector.getInjector();
  injector.map(Logger, (i) => new Logger(), isSingleton: true);
  injector.map(String, (i) => "https://api.com/", key: "apiUrl");
  injector.map(SomeService,
      (i) => new SomeService(i.get(Logger), i.get(String, "apiUrl")));

  injector.get<SomeService>(SomeService).doSomething();
  // passing in the [SomeService] as a generic parameter strongly types the return object.
  injector.get<SomeService>(SomeService).doSomething();
}

class Logger {
  void log(String message) => print(message);
}

class SomeService {
  final Logger _logger;
  final String _apiUrl;

  SomeService(this._logger, this._apiUrl);

  void doSomething() {
    _logger.log("Doing something with the api at '$_apiUrl'");
  }
}
