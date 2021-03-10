import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:test/test.dart';

class ObjectWithNoDependencies {
  String propertyOne = 'Hello';
}

class ObjectWithOneDependency {
  ObjectWithNoDependencies dependencyOne;
  String propertyOne = 'Hello Jon';

  ObjectWithOneDependency(this.dependencyOne);
}

class ObjectWithTwoDependencies {
  ObjectWithNoDependencies dependencyOne;
  ObjectWithOneDependency dependencyTwo;
  String propertyOne = 'Hello Jon!';

  ObjectWithTwoDependencies(this.dependencyOne, this.dependencyTwo);
}

class ObjectWithGenerics<T> {
  T propertyOfType;

  ObjectWithGenerics(this.propertyOfType);
}

class ObjectWithSomeConstructorArgDependencies {
  final String id;

  ObjectWithSomeConstructorArgDependencies(this.id);
}

class ObjectC extends ObjectB {
  final String idC;

  ObjectC(this.idC, String idB) : super(idB);
}

class ObjectB {
  final String idB;

  ObjectB(this.idB);
}

void main() {
  test('a not found non-generic map test', () async {
    final injector = Injector();
    injector.map((i) => ObjectC('C', 'B'));
    expect(()=>injector.get<ObjectB>(), throwsException);
  });

  test('can get named injector instance', () async {
    final injectorDefault = Injector();
    final injectorNamed = Injector('name');
    expect(injectorDefault != null, true);
    expect(injectorNamed != null, true);
    expect(injectorNamed != injectorDefault, true);
  });

  test('can have isolated injector instances', () async {
    final injectorOne = Injector('one');
    final injectorTwo = Injector('two');
    injectorOne
        .map<ObjectWithNoDependencies>((i) => ObjectWithNoDependencies());
    final instance = injectorOne.get<ObjectWithNoDependencies>();
    expect(instance is ObjectWithNoDependencies, true);
    expect(
        () => injectorTwo.get<ObjectWithNoDependencies>(),
        throwsA(predicate((e) =>
            e is InjectorException &&
            e.message ==
                "Cannot find object factory for 'ObjectWithNoDependencies::default'")));
  });

  test('can override a mapped value, using overriding', () async {
    final injector = Injector();
    injector.map<ObjectWithGenerics<String>>(
        (injector) => ObjectWithGenerics('Hello-one'));

    injector.map<ObjectWithGenerics<String>>(
        (injector) => ObjectWithGenerics('Hello-one-with-key'), key: 'hello');


    injector.map<ObjectWithGenerics<String>>(
        (injector) => ObjectWithGenerics('Hello-two'),
        overriding: true);

    injector.map<ObjectWithGenerics<String>>(
        (injector) => ObjectWithGenerics('Hello-two-with-key'), key: 'hello', overriding: true);

    final stringInstance = injector.get<ObjectWithGenerics<String>>();
    final stringInstanceWithKey = injector.get<ObjectWithGenerics<String>>(key: 'hello');

    expect(stringInstance.propertyOfType, 'Hello-two');
    expect(stringInstanceWithKey.propertyOfType, 'Hello-two-with-key');
  });


  test('can\'t override a mapped value, by default', () async {
    final injector = Injector();
    injector.map<ObjectWithGenerics<String>>(
        (injector) => ObjectWithGenerics('Hello-one'), overriding: true);


    expect(() => injector.map<ObjectWithGenerics<String>>(
        (injector) => ObjectWithGenerics('Hello-one')), throwsException);
  });

  test('can map generic types', () async {
    final injector = Injector();
    injector.map<ObjectWithGenerics<String>>(
        (injector) => ObjectWithGenerics('Hello'), overriding: true);
    injector.map<ObjectWithGenerics<int>>((injector) => ObjectWithGenerics(10));
    injector
        .map<ObjectWithGenerics<bool>>((injector) => ObjectWithGenerics(true));
    final stringInstance = injector.get<ObjectWithGenerics<String>>();
    final intInstance = injector.get<ObjectWithGenerics<int>>();
    final boolInstance = injector.get<ObjectWithGenerics<bool>>();
    expect(stringInstance is ObjectWithGenerics, true);
    expect(intInstance is ObjectWithGenerics, true);
    expect(boolInstance is ObjectWithGenerics, true);
    expect(stringInstance.propertyOfType, 'Hello');
    expect(intInstance.propertyOfType, 10);
    expect(boolInstance.propertyOfType, true);
    injector.dispose();
  });

  test('can map class factory and get object instance', () async {
    final injector = Injector();
    injector.map<ObjectWithNoDependencies>(
        (injector) => ObjectWithNoDependencies());
    final instance = injector.get<ObjectWithNoDependencies>();
    expect(instance is ObjectWithNoDependencies, true);
    expect(instance.propertyOne, 'Hello');
    injector.dispose();
  });

  test(
      'can map class factory for singleton and always get back the same object',
      () async {
    final injector = Injector();
    injector.map<ObjectWithNoDependencies>(
        (injector) => ObjectWithNoDependencies(),
        isSingleton: true);
    final instanceOne = injector.get<ObjectWithNoDependencies>();
    final instanceTwo = injector.get<ObjectWithNoDependencies>();
    final instanceThree = injector.get<ObjectWithNoDependencies>();
    expect(instanceOne is ObjectWithNoDependencies, true);
    expect(instanceTwo.hashCode, instanceOne.hashCode);
    expect(instanceThree.hashCode, instanceOne.hashCode);
    injector.dispose();
  });

  test('can map class factory and get object simple instance', () async {
    final injector = Injector();
    injector.map<ObjectWithNoDependencies>(
        (injector) => ObjectWithNoDependencies());
    injector.map<ObjectWithOneDependency>((injector) =>
        ObjectWithOneDependency(injector.get<ObjectWithNoDependencies>()));
    final instance = injector.get<ObjectWithOneDependency>();
    expect(instance is ObjectWithOneDependency, true);
    expect(instance.dependencyOne is ObjectWithNoDependencies, true);
    expect(instance.propertyOne, 'Hello Jon');
    injector.dispose();
  });

  test('can map same object with different keys and get instances', () async {
    final injector = Injector();
    injector.map<ObjectWithNoDependencies>(
        (injector) => ObjectWithNoDependencies());
    injector.map<ObjectWithNoDependencies>(
        (injector) => ObjectWithNoDependencies(),
        key: 'One');
    final instanceOne = injector.get<ObjectWithNoDependencies>();
    final instanceTwo = injector.get<ObjectWithNoDependencies>(key: 'One');
    expect(instanceOne is ObjectWithNoDependencies, true);
    expect(instanceTwo is ObjectWithNoDependencies, true);
    expect(instanceOne != instanceTwo, true);
    injector.dispose();
  });

  test('can map simple named string type', () async {
    final injector = Injector();
    injector.map<String>((injector) => 'Jon', key: 'MyName');
    final instanceOne = injector.get<String>(key: 'MyName');
    final instanceTwo = injector.get<String>(key: 'MyName');
    expect(instanceOne is String, true);
    expect(instanceOne, 'Jon');
    expect(instanceTwo, instanceOne);
    injector.dispose();
  });

  test('can construct type with additional give parameters', () async {
    final injector = Injector();
    injector.mapWithParams<ObjectWithSomeConstructorArgDependencies>(
        (injector, p) => ObjectWithSomeConstructorArgDependencies(p['id']));
    final instanceOne = injector.get<ObjectWithSomeConstructorArgDependencies>(
        additionalParameters: {'id': 'some-id'});
    expect(instanceOne is ObjectWithSomeConstructorArgDependencies, true);
    expect(instanceOne.id, 'some-id');
    injector.dispose();
  });

  test('can get all instances of type', () async {
    final injector = Injector();
    injector.map<ObjectWithSomeConstructorArgDependencies>(
        (injector) => ObjectWithSomeConstructorArgDependencies('0'));
    injector.map<ObjectWithNoDependencies>(
        (injector) => ObjectWithNoDependencies());
    injector.map<ObjectWithSomeConstructorArgDependencies>(
        (injector) => ObjectWithSomeConstructorArgDependencies('1'),
        key: 'One');
    injector.map<ObjectWithSomeConstructorArgDependencies>(
        (injector) => ObjectWithSomeConstructorArgDependencies('2'),
        key: 'Two');
    final instances =
        injector.getAll<ObjectWithSomeConstructorArgDependencies>();
    expect(instances.length, 3);
    expect(instances.elementAt(0).id, '0');
    expect(instances.elementAt(1).id, '1');
    expect(instances.elementAt(2).id, '2');
    injector.dispose();
  });

  test('exception thrown when type is not known', () async {
    final injector = Injector();
    injector.map<ObjectWithOneDependency>((injector) =>
        ObjectWithOneDependency(injector.get<ObjectWithNoDependencies>()));
    expect(
        () => injector.get<ObjectWithOneDependency>(),
        throwsA(predicate((e) =>
            e is InjectorException &&
            e.message ==
                "Cannot find object factory for 'ObjectWithNoDependencies::default'")));
    injector.dispose();
  });

  test('exception thrown when keyed type is not known', () async {
    final injector = Injector();
    injector.map<ObjectWithOneDependency>((injector) => ObjectWithOneDependency(
        injector.get<ObjectWithNoDependencies>(key: 'Key')));
    expect(
        () => injector.get<ObjectWithOneDependency>(),
        throwsA(predicate((e) =>
            e is InjectorException &&
            e.message ==
                "Cannot find object factory for 'ObjectWithNoDependencies::Key'")));
    injector.dispose();
  });

  test('can remove mapping and map again', () async {
    final injector = Injector();
    injector.map<ObjectWithNoDependencies>(
        (injector) => ObjectWithNoDependencies());

    expect(injector.isMapped<ObjectWithNoDependencies>(), true);
    injector.removeMapping<ObjectWithNoDependencies>();
    expect(injector.isMapped<ObjectWithNoDependencies>(), false);

    injector.map<ObjectWithNoDependencies>(
        (injector) => ObjectWithNoDependencies());
    expect(injector.isMapped<ObjectWithNoDependencies>(), true);

    expect(injector.get<ObjectWithNoDependencies>() is ObjectWithNoDependencies,
        true);

    injector.dispose();
  });

  test('can remove all mappings of type', () async {
    final injector = Injector();
    injector.map<ObjectWithNoDependencies>(
        (injector) => ObjectWithNoDependencies());
    injector.map<ObjectWithNoDependencies>(
      (injector) => ObjectWithNoDependencies(),
      key: 'one',
    );
    injector.map<ObjectWithNoDependencies>(
      (injector) => ObjectWithNoDependencies(),
      key: 'two',
    );

    expect(injector.isMapped<ObjectWithNoDependencies>(), true);
    expect(injector.isMapped<ObjectWithNoDependencies>(key: 'one'), true);
    expect(injector.isMapped<ObjectWithNoDependencies>(key: 'two'), true);
    injector.removeAllMappings<ObjectWithNoDependencies>();
    expect(injector.isMapped<ObjectWithNoDependencies>(), false);
    expect(injector.isMapped<ObjectWithNoDependencies>(key: 'one'), false);
    expect(injector.isMapped<ObjectWithNoDependencies>(key: 'two'), false);

    injector.dispose();
  });
}
