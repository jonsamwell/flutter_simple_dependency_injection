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
new object returned function.
    
```dart
import 'package:flutter_simple_dependency_injection/flutter_simple_dependency_injection.dart';
```
