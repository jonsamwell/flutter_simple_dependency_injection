import 'package:flutter_simple_dependency_injection/src/injector_exception.dart';
import 'package:flutter_simple_dependency_injection/src/type_factory.dart';

typedef ObjectFactoryFn<T> = T Function(Injector injector);
typedef ObjectFactoryWithParamsFn<T> = T Function(
  Injector injector,
  Map<String, dynamic> additionalParameters,
);

/// A simple injector implementation for use in Flutter projects where conventional reflection (mirrors)
/// is not available.
///
///```dart
/// import 'package:flutter_simple_dependency_injection/injector.dart';
///
/// void main() {
///   final injector = Injector.getInjector();
///   injector.map<Logger>((i) => Logger(), isSingleton: true);
///   injector.map<String>((i) => 'https://api.com/, key: 'apiUrl');
///   injector.map<SomeService>((i) => SomeService(i.get(Logger), i.get(String, 'apiUrl')));
///
///   injector.get<SomeService>().doSomething();
/// }
///
/// class Logger {
///   void log(String message) => print(message);
/// }
///
/// class SomeService {
///   final Logger _logger;
///   final String _apiUrl;
///
///   SomeService(this._logger, this._apiUrl);
///
///   void doSomething() {
///    _logger.log("Doing something with the api at '$_apiUrl'");
///   }
/// }
///```
class Injector {
  static final Map<String, Injector> _injectors = <String, Injector>{};
  final Map<String, TypeFactory<Object>> _factories =
      <String, TypeFactory<Object>>{};

  /// The name of this injector.
  ///
  /// Naming injectors enable each app to have multiple atomic injectors.
  final String name;

  /// Get the instance of the named injector creating an [Injector] instance
  /// if the named injector cannot be found.
  ///
  /// The [name] is optional and if omitted the "default" injector instance
  /// will be returned.
  ///
  /// ```dart
  /// final defaultInjector = Injector.getInjector();
  /// final isolatedInjector = Injector.getInjector("Isolated");
  /// ```
  static Injector getInjector([String name = 'default']) {
    if (!_injectors.containsKey(name)) {
      _injectors[name] = Injector._internal(name);
    }

    return _injectors[name];
  }

  Injector._internal(this.name);

  String _makeKey<T>(T type, [String key]) => '${_makeKeyPrefix(type)}${key ?? 'default'}';

  String _makeKeyPrefix<T>(T type) => '${type.toString()}::';

  /// Maps the given type to the given factory function. Optionally specify the type as a singleton and give it a named key.
  ///
  /// [T] The type the [factoryFn] will return an instance of.
  ///
  /// [factoryFn] is a simple function which takes in an [Injector] and returns an new instance
  /// of the type [T].  In this method you can use the injector to get other dependencies
  /// this instance depends on (see examples below).
  ///
  /// When [isSingleton] is true the first returned instances of the object is stored and
  /// subsequently return in future calls.
  ///
  /// When [key] is provided the object is keyed by type name and the given key.
  ///
  /// Throws an [InjectorException] if the type and or key combination has already been mapped.
  ///
  /// Returns the current injector instance.
  ///
  /// ```dart
  /// final injector = Injector.getInstance();
  /// injector.map(Logger, (injector) => AppLogger());
  /// injector.map(DbLogger, (injector) => DbLogger(), isSingleton: true);
  /// injector.map(AppLogger, (injector) => AppLogger(injector.get(Logger)), key: "AppLogger");
  /// injector.map(String, (injector) => "https://api.com/", key: "ApiUrl");
  /// ```
  ///
  /// You can also configure mapping in a fluent programming style:
  /// ```dart
  /// Injector.getInstance().map(Logger, (injector) => AppLogger());
  ///                       ..map(DbLogger, (injector) => DbLogger(), isSingleton: true);
  ///                       ..map(AppLogger, (injector) => AppLogger(injector.get(Logger)), key: "AppLogger");
  ///                       ..map(String, (injector) => "https://api.com/", key: "ApiUrl");
  /// ```
  Injector map<T>(ObjectFactoryFn<T> factoryFn,
      {bool isSingleton = false, String key}) {
    final objectKey = _makeKey(T, key);
    if (_factories.containsKey(objectKey)) {
      throw InjectorException("Mapping already present for type '$objectKey'");
    }
    _factories[objectKey] = TypeFactory<T>((i, p) => factoryFn(i), isSingleton);
    return this;
  }

  /// Maps the given type to the given factory function. Optionally give it a named key.
  ///
  /// [T] The type the [factoryFn] will return an instance of.
  ///
  /// [factoryFn] is a simple function which takes in an [Injector] and returns an new instance
  /// of the type [T].  In this method you can use the injector to get other dependencies
  /// this instance depends on (see examples below).
  ///
  /// When [isSingleton] is true the first returned instances of the object is stored and
  /// subsequently return in future calls.
  ///
  /// When [key] is provided the object is keyed by type name and the given key.
  ///
  /// Throws an [InjectorException] if the type and or key combination has already been mapped.
  ///
  /// Returns the current injector instance.
  ///
  /// ```dart
  /// final injector = Injector.getInstance();
  /// injector.map(Logger, (injector, params) => AppLogger(params["logKey"]));
  /// injector.map(AppLogger, (injector, params) => AppLogger(injector.get(Logger, params["apiUrl"])), key: "AppLogger");
  /// ```
  Injector mapWithParams<T>(ObjectFactoryWithParamsFn<T> factoryFn, {String key}) {
    final objectKey = _makeKey(T, key);
    if (_factories.containsKey(objectKey)) {
      throw InjectorException("Mapping already present for type '$objectKey'");
    }
    _factories[objectKey] = TypeFactory<T>(factoryFn, false);
    return this;
  }

  /// Returns true if the given type has been mapped. Optionally give it a named key.
  bool isMapped<T>({String key}) {
    final objectKey = _makeKey(T, key);
    return _factories.containsKey(objectKey);
  }

  /// Removes the type mapping from the injector if present. Optionally give it a named key.
  /// The remove operation is silent, means no exception is thrown if the type or key combination is not present.
  ///
  /// Returns the current injector instance.
  Injector removeMapping<T>({String key}) {
    final objectKey = _makeKey(T, key);
    if (_factories.containsKey(objectKey)) {
      _factories.remove(objectKey);
    }
    return this;
  }

  /// Removes all the mappings for the given type
  /// The remove operation is silent, means no exception is thrown if the type or key combination is not present.
  ///
  /// Returns the current injector instance.
  Injector removeAllMappings<T>() {
    final keyForType = _makeKeyPrefix(T);
    _factories.removeWhere((key, value) => key.startsWith(keyForType));
    return this;
  }

  /// Gets an instance of the given type of [T] and optional given key and parameters.
  ///
  /// Throws an [InjectorException] if the given type has not been mapped
  /// using the map method.
  ///
  /// Note that instance that are mapped to need additional parameters cannot be singletons
  ///
  /// ```dart
  /// final injector = Injector.getInstance();
  /// // map the type
  /// injector.map<Logger>((injector) => AppLogger());
  /// // get the type
  /// injector.get<Logger>().log("some message");
  ///
  /// injector.mapWithParams<SomeType>((i, p) => SomeType(p["id"]))
  /// final instance = injector.get<SomeType>(additionalParameters: { "id": "some-id" });
  /// print(instance.id) // prints 'some-id'
  /// ```
  T get<T>({String key, Map<String, dynamic> additionalParameters}) {
    final objectKey = _makeKey(T, key);
    final objectFactory = _factories[objectKey];
    if (objectFactory == null) {
      throw InjectorException("Cannot find object factory for '$objectKey'");
    }

    return objectFactory.get(this, additionalParameters);
  }

  /// Gets all the mapped instances of the given type and additional parameters
  Iterable<T> getAll<T>({Map<String, dynamic> additionalParameters}) {
    final keyForType = _makeKeyPrefix(T);
    return _factories.entries //
        .where((entry) => entry.key.startsWith(keyForType)) //
        .map((entry) => entry.value.get(this, additionalParameters) as T);
  }

  /// Disposes of the injector instance and removes it from the named collection of injectors
  void dispose() {
    _factories.clear();
    _injectors.remove(name);
  }
}
