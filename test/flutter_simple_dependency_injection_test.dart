import 'package:flutter_simple_dependency_injection/injector.dart';
import "package:test/test.dart";

class ObjectWithNoDependencies {
  String propertyOne = "Hello";
}

class ObjectWithOneDependency {
  ObjectWithNoDependencies dependencyOne;
  String propertyOne = "Hello Jon";

  ObjectWithOneDependency(this.dependencyOne);
}

class ObjectWithTwoDependencies {
  ObjectWithNoDependencies dependencyOne;
  ObjectWithOneDependency dependencyTwo;
  String propertyOne = "Hello Jon!";

  ObjectWithTwoDependencies(this.dependencyOne, this.dependencyTwo);
}

void main() {
  test("can get default injector instance", () async {
    final injector = Injector.getInjector();
    expect(injector != null, true);
  });

  test("can get named injector instance", () async {
    final injectorDefault = Injector.getInjector();
    final injectorNamed = Injector.getInjector("name");
    expect(injectorDefault != null, true);
    expect(injectorNamed != null, true);
    expect(injectorNamed != injectorDefault, true);
  });

  test("can have isolated injector instances", () async {
    final injectorOne = Injector.getInjector("one");
    final injectorTwo = Injector.getInjector("two");
    injectorOne.map(
        ObjectWithNoDependencies, (i) => new ObjectWithNoDependencies());
    final instance = injectorOne.get(ObjectWithNoDependencies);
    expect(instance is ObjectWithNoDependencies, true);
    expect(
        () => injectorTwo.get(ObjectWithNoDependencies),
        throwsA(predicate((e) =>
            e is InjectorException &&
            e.message ==
                "Cannot find object factory for 'ObjectWithNoDependencies::default'")));
  });

  test("can map class factory and get object instance", () async {
    final injector = Injector.getInjector();
    injector.map(
        ObjectWithNoDependencies, (injector) => new ObjectWithNoDependencies());
    final instance =
        injector.get<ObjectWithNoDependencies>(ObjectWithNoDependencies);
    expect(instance is ObjectWithNoDependencies, true);
    expect(instance.propertyOne, "Hello");
    injector.dispose();
  });

  test(
      "can map class factory for singleton and always get back the same object",
      () async {
    final injector = Injector.getInjector();
    injector.map(
        ObjectWithNoDependencies, (injector) => new ObjectWithNoDependencies(),
        isSingleton: true);
    final instanceOne = injector.get(ObjectWithNoDependencies);
    final instanceTwo = injector.get(ObjectWithNoDependencies);
    final instanceThree = injector.get(ObjectWithNoDependencies);
    expect(instanceOne is ObjectWithNoDependencies, true);
    expect(instanceTwo.hashCode, instanceOne.hashCode);
    expect(instanceThree.hashCode, instanceOne.hashCode);
    injector.dispose();
  });

  test("can map class factory and get object simple instance", () async {
    final injector = Injector.getInjector();
    injector.map(
        ObjectWithNoDependencies, (injector) => new ObjectWithNoDependencies());
    injector.map(
        ObjectWithOneDependency,
        (injector) => new ObjectWithOneDependency(
            injector.get(ObjectWithNoDependencies)));
    final instance = injector.get(ObjectWithOneDependency);
    expect(instance is ObjectWithOneDependency, true);
    expect(instance.dependencyOne is ObjectWithNoDependencies, true);
    expect(instance.propertyOne, "Hello Jon");
    injector.dispose();
  });

  test("can map same object with different keys and get instances", () async {
    final injector = Injector.getInjector();
    injector.map(
        ObjectWithNoDependencies, (injector) => new ObjectWithNoDependencies());
    injector.map(
        ObjectWithNoDependencies, (injector) => new ObjectWithNoDependencies(),
        key: "One");
    final instanceOne = injector.get(ObjectWithNoDependencies);
    final instanceTwo = injector.get(ObjectWithNoDependencies, "One");
    expect(instanceOne is ObjectWithNoDependencies, true);
    expect(instanceTwo is ObjectWithNoDependencies, true);
    expect(instanceOne != instanceTwo, true);
    injector.dispose();
  });

  test("can map simple named string type", () async {
    final injector = Injector.getInjector();
    injector.map(String, (injector) => "Jon", key: "MyName");
    final instanceOne = injector.get(String, "MyName");
    final instanceTwo = injector.get(String, "MyName");
    expect(instanceOne is String, true);
    expect(instanceOne, "Jon");
    expect(instanceTwo, instanceOne);
    injector.dispose();
  });

  test("exception thrown when type is not known", () async {
    final injector = Injector.getInjector();
    injector.map(
        ObjectWithOneDependency,
        (injector) => new ObjectWithOneDependency(
            injector.get(ObjectWithNoDependencies)));
    expect(
        () => injector.get(ObjectWithOneDependency),
        throwsA(predicate((e) =>
            e is InjectorException &&
            e.message ==
                "Cannot find object factory for 'ObjectWithNoDependencies::default'")));
    injector.dispose();
  });

  test("exception thrown when keyed type is not known", () async {
    final injector = Injector.getInjector();
    injector.map(
        ObjectWithOneDependency,
        (injector) => new ObjectWithOneDependency(
            injector.get(ObjectWithNoDependencies, "Key")));
    expect(
        () => injector.get(ObjectWithOneDependency),
        throwsA(predicate((e) =>
            e is InjectorException &&
            e.message ==
                "Cannot find object factory for 'ObjectWithNoDependencies::Key'")));
    injector.dispose();
  });
}
