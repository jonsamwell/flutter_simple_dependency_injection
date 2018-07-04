import 'package:flutter_simple_dependency_injection/injector.dart';

void main() {
  final injector = Injector.getInjector();
  injector.map<Logger>((i) => new Logger(), isSingleton: true);
  injector.map<String>((i) => "https://api.com/", key: "apiUrl");
  injector.map<SomeService>((i) => new SomeService(i.get<Logger>(), i.get<String>(key: "apiUrl")));

  injector.get<SomeService>().doSomething();

  // get an instace of each of the same mapped types
  injector.map<SomeType>((injector) => new SomeType("0"));
  injector.map<SomeType>((injector) => new SomeType("1"), key: "One");
  injector.map<SomeType>((injector) => new SomeType("2"), key: "Two");
  final instances = injector.getAll<SomeType>();
  print(instances.length); // prints '3'

  // passing in additional arguments when getting an instance
  injector.mapWithParams<SomeType>((i, p) => new SomeType(p["id"]), key: "Three");
  final instance = injector.get<SomeType>(additionalParameters: { "id": "some-id" });
  print(instance.id); // prints 'some-id'
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

class SomeType {
  final String id;
  SomeType(this.id);
}
