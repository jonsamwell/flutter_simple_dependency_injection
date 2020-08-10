# flutter_simple_dependency_injection

A simple dependency injection plugin for [Flutter](https://flutter.io) and Dart.

This implementation *does not* rely on the dart reflection apis (mirrors) and favours a simple factory based approach.
This increases the performance and simplicity of this implementation.

* Support for multiple injectors (useful for unit testing or code running in isolates)
* Support for types and named types
* Support for singletons
* Support simple values (useful for configuration parameters like api keys or urls)

Any help is appreciated! Comment, suggestions, issues, PR's!

## Getting Started

In your flutter or dart project add the dependency:

``` yml
dependencies:
  ...
  flutter_simple_dependency_injection: any
```

For help getting started with Flutter, view the online
[documentation](https://flutter.io/).

## Usage example

Import `flutter_simple_dependency_injection`

``` dart
import 'package:flutter_simple_dependency_injection/injector.dart';
```

### Injector Configuration

As this injector relies on factories rather than reflection (as mirrors in not available in Flutter)
each mapped type needs to provide a factory function.  In most cases this can just be a simple 
new object returned function.  In slightly more advanced scenarios where the type to be created relies
on other types an injector instances is passed into the factory function to allow the type of be created
to get other types it depends on (see below for examples).

    

``` dart
import 'package:flutter_simple_dependency_injection/injector.dart';

void main() {
  // it is best to place all injector initialisation work into one or more modules
  // so it can act more like a dependency injector than a service locator
  final injector = ModuleContainer().initialise(Injector.getInjector());

  // NOTE: it is best to architect your code so that you never need to
  // interact with the injector itself.  Make this framework act like a dependency injector
  // by having dependencies injected into objects in their constructors.  That way you avoid
  // any tight coupling with the injector itself.

  // Basic usage, however this kind of tight couple and direct interaction with the injector
  // should be limited.  Instead prefer dependencies injection.

  // simple dependency retrieval and method call
  injector.get<SomeService>().doSomething();

  // get an instance of each of the same mapped types
  final instances = injector.getAll<SomeType>();
  print(instances.length); // prints '3'

  // passing in additional arguments when getting an instance
  final instance =
      injector.get<SomeOtherType>(additionalParameters: {"id": "some-id"});
  print(instance.id); // prints 'some-id'
}

class ModuleContainer {
  Injector initialise(Injector injector) {
    injector.map<Logger>((i) => Logger(), isSingleton: true);
    injector.map<String>((i) => "https://api.com/", key: "apiUrl");
    injector.map<SomeService>(
        (i) => SomeService(i.get<Logger>(), i.get<String>(key: "apiUrl")));

    injector.map<SomeType>((injector) => SomeType("0"));
    injector.map<SomeType>((injector) => SomeType("1"), key: "One");
    injector.map<SomeType>((injector) => SomeType("2"), key: "Two");

    injector.mapWithParams<SomeOtherType>((i, p) => SomeOtherType(p["id"]));

    return injector;
  }
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

class SomeOtherType {
  final String id;
  SomeOtherType(this.id);
}

```

### Remove mappings

You can remove a mapped a factory/instance at any time:

``` 
  injector.removeMapping<SomeType>();

  injector.removeMapping<SomeType>(key: 'some_key');

  injector.removeAllMappings<SomeType>();
```

### Multiple Injectors

The Injector class has a static method [getInjector] that by default returns the default instance of the injector.  In most cases this will be enough.
However, you can pass a name into this method to return another isolated injector that is independent from the default injector.  Passing in a new 
injector name will create the injector if it has not be retrieved before.  To destroy isolated injector instances call their [dispose] method.

``` dart
  final defaultInjector = Injector.getInjector();
  final isolatedInjector = Injector.getInjector("Isolated");
```
