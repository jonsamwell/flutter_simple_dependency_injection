# flutter_simple_dependency_injection

A simple dependency injection plugin for [Flutter](https://flutter.io).

This implementation *does not* rely on the dart reflection apis (mirrors) and favours a simple factory based approach.
This increases the performance and simplicity of this implementation.

* Support for multiple injectors (useful for unit testing or code running in isolates)
* Support for types and named types
* Support for singletons
* Support simple values (useful for configuration parameters like api keys or urls)

Any help is appreciated! Comment, suggestions, issues, PR's!

## Getting Started

In your flutter project add the dependency:

```yml
dependencies:
  ...
  flutter_simple_dependency_injection: any
```

For help getting started with Flutter, view the online
[documentation](https://flutter.io/).

## Usage example

Import `flutter_simple_dependency_injection`

```dart
import 'package:flutter_simple_dependency_injection/injector.dart';
```

### Injector Configuration

As this injector relies on factories rather than reflection (as mirrors in not available in Flutter)
each mapped type needs to provide a factory function.  In most cases this can just be a simple 
new object returned function.  In slightly more advanced scenarios where the type to be created relies
on other types an injector instances is passed into the factory function to allow the type of be created
to get other types it depends on (see below for examples).
    
```dart
import 'package:flutter_simple_dependency_injection/injector.dart';

void main() {
  final injector = Injector.getInjector();
  injector.map(Logger, (i) => new Logger(), isSingleton: true);
  injector.map(String, (i) => "https://api.com/", key: "apiUrl");
  injector.map(SomeService, (i) => new SomeService(i.get(Logger), i.get(String, "apiUrl")));

  injector.get(SomeService).doSomething();
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

```

### Multiple Injectors

The Injector class has a static method [getInjector] that by default returns the default instance of the injector.  In most cases this will be enough.
However, you can pass a name into this method to return another isolated injector that is independent from the default injector.  Passing in a new 
injector name will create the injector if it has not be retrieved before.  To destroy isolated injector instances call their [dispose] method.

```dart
  final defaultInjector = Injector.getInjector();
  final isolatedInjector = Injector.getInjector("Isolated");
```