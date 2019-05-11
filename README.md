# fmvvm
A MVVM framework for creating Flutter apps.

# Backgorund
The MVVM model (Model - View - ViewModel) pattern is an alternate pattern to MVC. This framework takes many of the core features of MVVM frameworks and apply the to flutter. Main features include:

* A structure for creating viewmodels.
* A Flutter friendly implementation of data binding including value conversion
* Inversion of control / dependency injection
* viewmodel to view model navigation

A formal explanation of the MVVM pattern [can be found here](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel).

Implementing the MVVM pattern is about having a formal architecture in your application and separation of concerns. When implementing MVVM in an app I adhere to the following design goals.

* A viewmodel should have no idea how it is presented or have any presentaiton concepts.
* Value conversion should be used to convert from information in the viewmodel to the Widget (view)
* Navigation should be done from viewmodel to viewmodel.
* Viewmodels are primarily what is bound to, but models can be exposed by viewmodels and bound to as well.
* Dependancy injection can be used to pass required information to a viewmodel.

# Using fmvvm
## Viewmodels
Viewmodels are the primary glue that backs a widget. Viewmodels should inherit from ViewModelBase.

```
import 'package:fmvvm/bindings/bindings.dart';

class SampleViewModel extends ViewModelBase {
}
```

### Adding propties
Properties that can be bound to should use the PropertyInfo object. Any object that inherits from BindableBase, including ViewModelBase, can create bindable properties.

Creating a new PropertyInfo object should:

* Give a name to the propety that matches the getter and setter
* Be static.
* Define the type of the property.
* Be 'public' so they can be used in data binding.

```
static PropertyInfo someDateTimeProperty = PropertyInfo('someDateTime', DateTime);
```

Then a setter and/or getter can be created. 

```
DateTime get someDateTime => getValue(someDateTimeProperty);
set someDateTime(DateTime value) => {
      setValue(someDateTimeProperty, value),
};

```

Notice that the name given to the setter and getter is the same as what was used in the creation of the PropertyInfo. This is not required but the name given the PropertyInfo has to be unique for the class for data binding to work correctly.

Read only or set only properties can be created by leaving off the setter or getter respectively.

### Adding commands
Commands allow widgets to call functions on viewmodels in a generic way and also allow parameters to be passed to those functions. Commands are usually private to the class and exposed through a property getter.

Currently commands are fire and forget, that is to say they do not return a future.

Here is how a command can be created on a viewmodel that takes no parameters.

```
Command _doSomethingCommand;

Command get DoSomething {
  _doSomethingCommand ??= Command(() {
    /// Some code that should be run in the viewModel
  });
  return _doSomethingCommand;
}
```

A command that takes a parameter would be defined as:

```
Command _doSomethingCommand;

Command get DoSomething {
  _doSomethingCommand ??= Command((parameter) {
    // Some code that should be run in the viewModel
  });
  return _doSomethingCommand;
}
```

### The init function.
The viewmodel's init method is called after a viewmodel has been instantiated as part of navigaiton, but before it has been passed to a widget. A parameter is sent to this method through viewmodel to viewmodel navigation. If no paramter is sent, it will be null.

In many cases the init method is used to do any fetches or other data initilization for a viewmodel.

```
@override
void init(Object parameter) {
  // Some initilization code for the view model.
}
```

### Creating a viewmodel in code.
Viewmodels should not be created directly, instead there is a factory method in the NavigationService. Calling the factorymethod ensures that the init method is also called correctly. In this case the value 5 will be passed to the new viewmodel's init method. 

```
var _viewModel = navigationService.createViewModel<SomeViewModel>(5);
```

__In order for this to work, all viewmodels must be registered with the componenet resolver.__

## Component resolver
The component resolver is a lightweight dependency inject framework. If you wish to use your own dependency injectcion framework you can by wrapping it in an instace of a class the implements the ComponentResolver interface and pass it into the Core.Initialize method.

### Registering components.
There are two types of registrations that can be done, an instance registration and a type registration.  

#### Instance registration
An instance registration returns the same instance of the object each and every time it is called.

```
var myObject = CustomObject();
Core.componentResolver.registerInstance<CustomObject>(myObject);
```

#### Type registration
A type registration returns a new instance each time it is called based on the factory method you provide.

```
Core.componentResolver.registerType<MyViewModel>(() {
  return MyViewModel();
});
```

The component resolver can also register types that pass in parameters to the constructore that may alse be registered with the component resolver. This code would pass the registered instance of the NavigaitonService to the constructor of the MyViewModel class.

```
Core.componentResolver.registerType<MyViewModel>(() {
  return MyViewModel(Core.componentResolver.resolveType<NavigationService>());
});
```

__Extreme care must be taken when resolving other components within a registerType method. If you create a circular redependancy relationship you will create a stack overflow situation.__

### Resolving components
Components are resolved from the componentResolver by type, either by passing ther type as a parameter or as a generic.

####Passing the type by parameter

```
var myClass = Core.ComponentResolver.resolve(MyClass);
```

####Using a generic type

```
var myClass = Core.ComponentResolver.resolve<MyClass>();
```

## Data Binding
