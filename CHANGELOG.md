## [1.0.2+1] - 24/12/2019.
* Fixed various analyzer warnings

## [1.0.2] - 18/12/2019.
* Fixed some lint warnings

## [1.0.1] - 05/03/2019.
* Removed dependency on flutter
* Updated example to explain how to use dependency injection rather than service location

## [0.0.4] - 05/07/2018.
* Added ability to pass in additional arguments in the factory function with a new method call [mapWithParams].

```dart
    final injector = Injector.getInstance();
    injector.mapWithParams<SomeType>((i, p) => new SomeType(p["id"]))
    final instance = injector.get<SomeType>(additionalParameters: { "id": "some-id" });
    print(istance.id) // prints 'some-id'
```

* Added ability to get all objects of the same mapped type

```dart
    final injector = Injector.getInstance();
    injector.map<SomeType>((injector) => new SomeType("0"));
    injector.map<SomeType>((injector) => new SomeType("1"), key: "One");
    injector.map<SomeType>((injector) => new SomeType("2"), key: "Two");
    final instances = injector.getAll<SomeType>();
    print(instances.length); // prints '3'
```

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
