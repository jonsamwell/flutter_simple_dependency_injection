import 'package:flutter_simple_dependency_injection/src/injector.dart';

class TypeFactory<T> {
  final bool _isSingleton;
  final ObjectFactoryFn<T> _factoryFn;
  T _instance;

  TypeFactory(this._factoryFn, this._isSingleton);

  T get(Injector injector) {
    if (_isSingleton && _instance != null) {
      return _instance;
    }

    final instance = _factoryFn(injector);
    if (_isSingleton) {
      _instance = instance;
    }
    return instance;
  }
}
