import 'package:flutter_simple_dependency_injection/src/injector.dart';

class TypeFactory<T> {
  final bool _isSingleton;
  final ObjectFactoryWithParamsFn<T> _factoryFn;
  T _instance;

  TypeFactory(this._factoryFn, this._isSingleton);

  T get(Injector injector, Map<String, dynamic> additionalParameters) {
    if (_isSingleton && _instance != null) {
      return _instance;
    }

    final instance = _factoryFn(injector, additionalParameters);
    if (_isSingleton) {
      _instance = instance;
    }
    return instance;
  }
}
