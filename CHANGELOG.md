## [0.0.3] - 01/07/2018.

* Improved injector interface using generic types instead of a passed in a type to key an object factory

The new api to map and get a type instance
```dart
    // the new api
    final injector = Injector.getInstance();
    injector.map<SomeType>((i) => new SomeType())
    final instance = injector.get<SomeType>();
```

The old api to map and get a type instance
```dart
    // the old api
    final injector = Injector.getInstance();
    injector.map(SomeType, (i) => new SomeType())
    final instance = injector.get<SomeType>(SomeType);
```

## [0.0.2] - 28/06/2018.

* Fixed up linting and file formats

## [0.0.1] - 28/06/2018.

* Initial release
