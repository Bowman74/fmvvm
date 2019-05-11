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

## Bootstraping fmvvm
Bootstrapping fmvvm is pretty easy. To get a reference to fmvvm add the following line to the dependencies section of the pubspec.yaml file:

```
fmvvm:
```

Before you start you will want to call Core.Initialize() when creating the app and register any dependencies using the component resolver. By default the NavigationService and ViewLocator as registers with the component resolver.

```
class MyApp extends StatelessWidget {
  MyApp() {
    Core.initialize();

    var componentResolver = Core.componentResolver;

    componentResolver.registerType<MyViewModel>(() {
      return MyViewModel(
          componentResolver.resolveType<NavigationService>());
    });
    componentResolver.registerType<SomeOtherViewModel>(() {
      return SomeOtherViewModel();
    });
  }
}
```

In the above case we have initialized the fmvvm library and registered two viewmodels. The MyViewModel class is having the NavigationService resolved and passed to it's constructor.

If you want custom versions of the ComponentResolver, ViewLocator or NavigtationService you can create your own versions that are returned from a custom Registrations class that is passed as a parameter to the initialize method. What each of these do will be explianed later in the documentation.

How to set up what widget is displayed by default for your app is explained in the Navigation section.

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

calling setValue will raise an event if the value did indeed change through the NotifyChanges interface. This is used by data binding.

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

## Data binding
Data binding creates a relationship between a class that inherits from BindableBase and a stateful or stateless widget. To be bound to a viewmodel the widget must derive from FmvvmStatefulWidget using a state object the derives from FmvvmState or from FmvvmStatelessWidget.

The widgets can only be bound directly to viewmodel objects and any object that derives from BindableBase it may expose.

### StatelessWidgets
Stateless widgets cannot change, they can only get information out of a viewmodel and no changes are allowed.

Creating a stateless widget should look like this:

```
class MyStatelessWidget extends FmvvmStatelessWidget<SomeViewModel> {
  MyStatelessWidget(ViewModel viewModel, {Key key})
      : super(viewModel, true, key: key);
}
```

__Notice that it is required than an instance of a class that implements viewmodel must be passed to the constructor.__
__Notive that the second parameter passed to the super contructor defines if this widget is navacable. Pass true for something that is navigated to like a widget that is a page and false for a widget that would be part of a page, like a row in a list.__

Now the build method can be overriden to create the widget interface and used values supplied by the view model.

The getValueWithConversion method can be used to pull values out of the view model. To use this method pass it a reference to the view model and the value stored in the property that you want to use.

```
@override
Widget build(BuildContext context) {
  super.build(context);
  return Scaffold(
      appBar: AppBar(
        title: Text('Current Count'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Counter Value:',
            ),
            Text(getValueWithConversion(viewModel, viewModel.counter)),
            ],
          ),
        ));
  }
```

__Calling the super.build(context); method is reluired for navigation to work correctly.__

You can also set the value of the Text widget to the counter property in the view model, but then you would not be able to take advantage of value conversion. More on that later.

```
Text(viewModel.counter.toString())
```

### Stateful widgets
Stateful widget should inherit from FmvvmStatefulWidget.

```
class MyStatefulWidget extends FmvvmStatefulWidget<MyViewModel> {
  MyStatefulWidget(MyViewModel viewModel, {Key key, this.title})
      : super(viewModel, key: key);
}
```

Classes that inherit from FmvvmStatfulWidget should always use a State object that inherits from FmvvmState and pass the viewmodel to the state object.

```
@override
MyState createState() => MyState(viewModel);
```

To create the State object we simply extend from FmvvmState.

```
class MyState extends FmvvmState<MyStatefulWidget, MyViewModel> {
  MyState(MyViewModel viewModel) : super(viewModel, true);
}
```

Like the FmvvmStatlessWidget, the second parameter sent to the super class defines if this widget is navicable (like a page) or not (like a widget in a page). Pass true if it is navicable.

#### Bindings on stateful widgets
This is where things get more complex. With stateful widgets bindings can be bi-directional. That is to say, when values in the viewmodel change we want to update the widget and when values in the widget change we want to update the viewmodel.

Because many of the sub widgets do not have consistent change methods or are not persistent, binding is done a little differently than you may have experienced in other mvvm frameworks.

Inside your State class, create a binding.

```
Binding _myBinding;
```

This creates a reference to a persistent binding object. Now we can create an instance of the binding, this is normally done in the initState method.

```
@override
void initState() {
  super.initState();

  _myBinding = createBinding(
      viewModel, MyViewModel.someProperty,
      bindingDirection: BindingDirection.TwoWay);
}
```

__Calls to the super class's initState method are required__

Here we create a binding. It gets a reference to the view model and a reference to a static PropertyInfo object that has the information about the property we are bound to.

We have also stated that the binding direction is two way. This will allow changes in the viewmodel's property or the entire viewmodel to call setState() and redraw the widget.

We can also set the binding direction to one time. If set to one time the binding will always return the value that it was when first queried, regardless of any changes that may have happened to the value stored in the viewmodel.

In the build method we can use our binding to give values to some of the widgets are are using.

```
@override
Widget build(BuildContext context) {
  super.build(context);

  return Scaffold(
    appBar: AppBar(
      title: Text('Counter'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('You have pushed the button this many times:'),
          Text(getValue(_myBinding)),
          ],
      ),
    )
  );
}
```
In this case we are setting the value of the Text widget to the return value of the getValue method. This method takes a reference to a binding object we created. If it returns the current value for the property stored in the viewmodel, or the first value returned, depends on the binding direction parameter with the binding was created.

That handles getting value changes from the viewmodel to the widget, how about values that change in the widget back to the viewmodel. That gets a little more complicated. Let's look at a Switch.

```
Switch(
  value: getValue(_boolBinding1) as bool,
  onChanged: getOnChanged(_boolBinding1),
),
```

Here the value property is set the same as it was for the Text widget, using the getValue method. The getvalue method is for values coming back from the viewmodel to the widget. The onChanged event is for values from the Widget going to the viewModel. Here we use a method called getOnChanged that receives a reference to the binding and sets the value on the viewmodel based on the new value in the widget. If you don't want and changed values in the widget being sent back to the viewmodel, simply don't set the OnChanged even to call the getOnChanged() method.

But what about things that use a controller like a TextField?

To do this we first create the controller in the State object.

```
TextEditingController _myController;
```

Then create an instance of it in the initState method and add a listener to the binding.

```
@override
void initState() {
  super.initState();

  _myController = TextEditingController();
  _myBinding = createBinding(
      viewModel, MyViewModel.someProperty,
      bindingDirection: BindingDirection.TwoWay);
  _myController.addListener(getTargetValuedTextChanged(_myBinding, _myController));
  }
```

Then in the build method:

```
@override
Widget build(BuildContext context) {
  super.build(context);
  myController.text = getValue(_myBinding);

  return Scaffold(
    appBar: AppBar(
      title: Text('Counter'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('You have pushed the button this many times:'),
          TextField(
            style: Theme.of(context).textTheme.display1,
            controller: controller,
          ),
          ],
      ),
    )
  );
}
```

Another posisbility for the TextField would be to leave the addListener off in the initState method and instead in the build method use the onChanged event of the TextField widget.

__In order to send widget values back to the viewmodel there needs to be a way, usually an event, that you can use to know the change occurred.__

### Calling commands
Commands are functions that you want to call on your viewmodel. In the viewmodels section we went over how a Command can be set up in a view model. Here is an example of calling that command from a FloatingActionButton widget in the build method.

```
floatingActionButton: FloatingActionButton(
  onPressed: viewModel.incrementCounter.execute,
  tooltip: 'Increment',
  child: Icon(Icons.add),
)
```

Commands can also take parameters. Here is an example using a FlatButton widget.

```
FlatButton(
  child: Text('Navigate'),
  onPressed: () {viewModel.navigate.execute(getValue(_someBinding));})
```

In this case the value from a binding would be passed as a parameter to the command.

### Value conversion
Many times the shape and type of information stored in your viewmodel may not be in the right format to be directly bound to a widget. Remember, the view model shouldn't know about any views that use it, or their capabilities or shape. So while a viewmodel wouldn't have a property to say if something like a button was enabled, it might have a isValid property and then create a binding to enable/disable a save button based on if the viewmodel's data is valid to save.

What does this have to do with value conversion? Simply that it is expected that the value in a viewmodel will not always be in a format needed by the widget. Take the following simple example, inside the viewmodel we have a counter property that is implemented as an int but we want to bind that to a Text widget that is expecting a string.

First we create a class that can convert back and forth:

```
class NumberValueConverter implements ValueConverter {
  Object convert(Object source, Object value) {
    return value.toString();
  }

  Object convertBack(Object source, Object value) {
    return int.tryParse(value) ?? 0;
  }
}
```

The convert function is used by a binding to go from the value in the viewmodel to the widget. The convert back method is information coming from the widget back to the view model. It this were used on a binding to a TextField and the user entered a 'g' charater, the try parse will fail and a 0 sent to the viewmodel.

Value converters are sent to bindings when they are created and used automatically after that on calls to getValue and setValue.

```
@override
void initState() {
  super.initState();

  _myBinding = createBinding(
      viewModel, MyViewModel.someProperty,
      bindingDirection: BindingDirection.TwoWay,
      valueConverter: NumberValueConverter());
}
```

Value conversion can also be used by FmvvmStatelessWidgets when calling the getValueWithConversion method.

```
getValueWithConversion(viewModel, viewModel.counter, NumberValueConverter());
```

## Navigation
fmvvm allows you to do viewmodel to viewmodel navigation. That is to say that when you want to navigate, that is application business logic that should happen in the viewmodel, usually within a command. Since the viewmodel doesn't know anything about the presentation layer, it just states what other viewmodel in the system to navigation to. Consider the following code:

```
navigationService.navigate<SomeOtherViewModel>(parameter: "58");
```

In this case the viewmodel will try to navigate to some otehr viewmodel of the type, SomeOtherViewModel. Additionally, a value of "58" will be sent to the SomeOtherViewModel's init method.

So how does it tell what widget to use for that view? By default it used a naming convention. It assumes that all viewmodels are named xyzViewModel and its associated widget has a route named xyzView. This default convention to resolve widgets from views can be overriden by creating your own instance of the ViewLocator class and passing it in to the core.initilaze method.

In order for all this to work a couple of things need to be true.

* The widget diplaying the viewmodel needs to have its isNavicable property set to true.
* The widget that is displaying the viewmodel we are navigating to needs to have its isNavicable property set to true.
* The viewmodel we are navigating to needs to be registered in the component resolver.
* The viewmodel and associated route need to be named appropriately or another method of viewmodel resolution needs to be provided.

Here is how those routes can be set up:

```
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'fmvvm Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    initialRoute: 'HomePageView',
    onGenerateRoute: _getRoute,
  );
}

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name == 'HomePageView') {
      var arguments = settings.arguments ??
          Core.componentResolver
              .resolveType<NavigationService>()
              .createViewModel<HomePageViewModel>(null);
      return _buildRoute(settings, new HomePageView(arguments));
    } else if (settings.name == 'SomeOtherView') {
      return _buildRoute(settings, new SomeOtherView(settings.arguments));
    }
    return null;
  }
```

A few things to notice, we don't normally do anything to create or pass an instance of the viewmodel to the widget in the route. This is done for us by the NavigationService's navigate method. It is sent with the settings.arguments. The exception to this is the initialRoute, when the app first starts. This isn't navigated to using the NavigationService.navigate method. For this we have to check and see that the settings.arguments are null and if so set it to an instance of the viewmodel using the NavigationService's createViewModel method.

__The NavigationService's navigate method returns a Future so the calling viewmodel can await the navigation operation being completed.__

Navigating back is as simple as calling:

```
NaivgationService.navigateBack();
```

## Putting it all together
Here is a sample app that puts together the concepts we have discussed.

```
import 'package:flutter/material.dart';

import 'package:fmvvm/bindings/bindings.dart';
import 'package:fmvvm/fmvvm.dart';
import 'package:fmvvm/interfaces/interfaces.dart' as fmvvm_interfaces;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    Core.initialize();

    var componentResolver = Core.componentResolver;

    componentResolver.registerType<_HomePageViewModel>(() {
      return _HomePageViewModel(
          componentResolver.resolveType<fmvvm_interfaces.NavigationService>());
    });
    componentResolver.registerType<_CounterViewModel>(() {
      return _CounterViewModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fmvvm Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '_HomePageView',
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name == '_HomePageView') {
      var arguments = settings.arguments ??
          Core.componentResolver
              .resolveType<fmvvm_interfaces.NavigationService>()
              .createViewModel<_HomePageViewModel>(null);
      return _buildRoute(settings, new _HomePageView(arguments));
    } else if (settings.name == '_CounterView') {
      return _buildRoute(settings, new _CounterView(settings.arguments));
    }
    return null;
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return new MaterialPageRoute(
      settings: settings,
      builder: (ctx) => builder,
    );
  }
}

class _HomePageView extends FmvvmStatefulWidget<_HomePageViewModel> {
  _HomePageView(fmvvm_interfaces.ViewModel viewModel, {Key key, this.title})
      : super(viewModel, key: key);

  final String title;

  @override
  _HomePageViewState createState() => _HomePageViewState(viewModel);
}

class _HomePageViewState extends FmvvmState<_HomePageView, _HomePageViewModel> {
  _HomePageViewState(_HomePageViewModel viewModel) : super(viewModel, true);

  TextEditingController controller;
  TextEditingController controller2;
  Binding _counterBinding;
  Binding _boolBinding;
  Binding _boolBinding1;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
    controller2 = TextEditingController();
    _counterBinding = createBinding(
        viewModel, _HomePageViewModel.counterProperty,
        bindingDirection: fmvvm_interfaces.BindingDirection.TwoWay,
        valueConverter: _NumberValueConverter());
    controller
        .addListener(getTargetValuedTextChanged(_counterBinding, controller));
    _boolBinding = createBinding(viewModel, _HomePageViewModel.testBoolProperty,
        bindingDirection: fmvvm_interfaces.BindingDirection.TwoWay);
    _boolBinding1 = createBinding(
        viewModel, _HomePageViewModel.testBoolProperty,
        bindingDirection: fmvvm_interfaces.BindingDirection.TwoWay);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    controller.text = getValue(_counterBinding);
    controller2.text = getValue(_counterBinding);

    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Hero(
              tag: 'countHero',
              child: Text(getValue(_counterBinding)),
            ),
            TextField(
              style: Theme.of(context).textTheme.display1,
              controller: controller,
            ),
            TextField(
              style: Theme.of(context).textTheme.display1,
              controller: controller2,
              onChanged: getOnChanged(_counterBinding),
            ),
            Switch(
              value: getValue(_boolBinding) as bool,
              onChanged: getOnChanged(_boolBinding),
            ),
            Switch(
              value: getValue(_boolBinding1) as bool,
              onChanged: getOnChanged(_boolBinding1),
            ),
            FlatButton(
                child: Text(
                  'Navigate',
                ),
                onPressed: () {
                  viewModel.navigate.execute();
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.incrementCounter.execute,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _CounterView extends FmvvmStatelessWidget<_CounterViewModel> {
  _CounterView(_CounterViewModel viewModel, {Key key})
      : super(viewModel, true, key: key);

  final _NumberValueConverter _valueConverter = _NumberValueConverter();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Current Count'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Counter Value:',
              ),
              Hero(
                tag: 'countHero',
                child: Text(getValueWithConversion(viewModel, viewModel.counter, _valueConverter)),
              ),
            ],
          ),
        ));
  }
}

class _HomePageViewModel extends ViewModelBase {
  _HomePageViewModel(this._navigationService);

  final fmvvm_interfaces.NavigationService _navigationService;

  static PropertyInfo counterProperty = PropertyInfo('counter', int);

  int get counter => getValue(counterProperty);
  set counter(int value) => setValue(counterProperty, value);

  static PropertyInfo currentDateProperty = PropertyInfo('currentDate', int);

  DateTime get currentDate => getValue(currentDateProperty);
  set currentDate(DateTime value) => setValue(currentDateProperty, value);

  static PropertyInfo testBoolProperty = PropertyInfo('testBool', bool, false);

  bool get testBool => getValue(testBoolProperty);
  set testBool(bool value) => setValue(testBoolProperty, value);

  Command _incrementCounter;

  Command get incrementCounter {
    _incrementCounter ??= Command(() {
      counter++;
    });
    return _incrementCounter;
  }

  Command _navigate;

  Command get navigate {
    _navigate ??= Command(() {
      _navigationService.navigate<_CounterViewModel>(parameter: counter);
    });
    return _navigate;
  }
}

class _CounterViewModel extends ViewModelBase {
  @override
  void init(Object parameter) {
    setValue(counterProperty, parameter);
  }

  static PropertyInfo counterProperty = PropertyInfo('counter', int);
  int get counter => getValue(counterProperty);
}

class _NumberValueConverter implements fmvvm_interfaces.ValueConverter {
  Object convert(Object source, Object value) {
    return value.toString();
  }

  Object convertBack(Object source, Object value) {
    return int.tryParse(value) ?? 0;
  }
}
```
