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

* A viewmodel should have no idea how it is presented or have any presentation concepts.
* Value conversion should be used to convert information in the viewmodel to a format needed by the Widget (view) and potentially back again.
* Navigation should be done from viewmodel to viewmodel.
* Viewmodels are primarily what is bound to, but models can be exposed by viewmodels and bound to as well.
* Dependancy injection can be used to pass required information to a viewmodel.

# Using fmvvm

## Bootstraping fmvvm
Bootstrapping fmvvm is pretty easy. To get a reference to fmvvm add the following line to the dependencies section of the pubspec.yaml file:

```
fmvvm: ^0.8.2
```

Before you start you will want to call Core.Initialize() when creating the app and register any dependencies using the component resolver. By default the NavigationService and ViewLocator are registered with the component resolver.

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

In the above case we have initialized the fmvvm library and registered two viewmodels. The MyViewModel class is also having the NavigationService resolved and passed to it's constructor.

If we need to reference fmvvm components in code, we can use the following import:

```
import 'package:fmvvm/bindings/fmvvm.dart';
```

If we want a custom versions of the ComponentResolver, ViewLocator or NavigtationService we can create our own versions that are returned from a custom Registrations class. An instance of the custom Registrations class is then passed in as a parameter to the initialize method. What each of these classes will be explianed later in the documentation.

Additionally, how to set up what starting widget is displayed by default for your app is explained in the Navigation section.

## Viewmodels
Viewmodels are the primary glue that backs a widget. Viewmodels should inherit from ViewModelBase.

```
import 'package:fmvvm/bindings/fmvvm.dart';

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

## Models
Models you want to bind to are written very similarly to ViewModels exept they implement the BindableBase interface instead of ViewModel.

```
class MyModel extends BindableBase {
}
```

Bindalbe properties are created in the same way for models as they are for viewmodels using the PropertyInfo class.

The main difference between a viewmodel and a model that derives from BindableBase is that there is no init method. Models created this way can be instantiated directly using normal means or using the dependency resolver.

While commands are usually not used on models, there is no reason Commands cannot be added.

Models that do not need data binding can be created without extending BindableBase.

## Component resolver
The component resolver is a lightweight dependency injection framework. If you wish to use your own dependency injection framework you can by wrapping it in an instace of a class that implements the ComponentResolver interface and pass it into the Core.Initialize method.

### Registering components.
There are two types of registrations that can be done, an instance registration and a type registration.  

#### Instance registration
An instance registration returns the same instance of the object each and every time it is called. This creates the equivalent of a singleton.

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

The component resolver can also register types that pass in parameters to the constructor that may also be registered with the component resolver. This code would pass the registered instance of the NavigaitonService to the constructor of the MyViewModel class.

```
Core.componentResolver.registerType<MyViewModel>(() {
  return MyViewModel(Core.componentResolver.resolveType<NavigationService>());
});
```

__Extreme care must be taken when resolving other components within a registerType method. If you make a circular dependancy relationship, you will create a stack overflow situation.__

### Resolving components
Components are resolved from the componentResolver by type, either by passing ther type as a parameter or as a generic.

#### Passing the type by parameter

```
var myClass = Core.ComponentResolver.resolve(MyClass);
```

#### Using a generic type

```
var myClass = Core.ComponentResolver.resolve<MyClass>();
```

## Data binding
Data binding creates a relationship between a class that inherits from BindableBase and a stateful or stateless widget. For the rest of this section we will use the term ViewModel but really it can refer to any class that derives from BindableBase. To be bound to a viewmodel, the widget must derive from FmvvmStatefulWidget using a state object that derives from FmvvmState or a FmvvmStatelessWidget.

fmvvmStateXXXWidgets can only be bound directly to BindableBase derived objects.

### StatelessWidgets
Stateless widgets cannot change, as such they can only get information out of a viewmodel and do not refresh themselves.

Creating a stateless widget should look like this:

```
class MyStatelessWidget extends FmvvmStatelessWidget<SomeViewModel> {
  MyStatelessWidget(ViewModel viewModel, {Key key})
      : super(viewModel, true, key: key);
}
```

__Notice that it is required than an instance of a class that implements BindableBase must be passed to the constructor.__
__Notice that the second parameter passed to the super's contructor defines if this widget is navagable. Pass true for something that is navigated to like a widget that is a page and false for a widget that would be part of a page, like a row in a list. If the value of isNavagable is true, then the object passed to the constructor must derive from ViewModel__

Now the build method can be overriden to create the widget interface and used values supplied by the view model.

The getValueWithConversion method can be used to pull values out of the viewmodel. To use this method pass it a reference to the view model and the value stored in the property that you want to use.

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

You can also set the value of the Text widget directly to the counter property in the view model, but then you would have to handle any required value conversion manually. More on that later.

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

Classes that inherit from FmvvmStatfulWidget should always use a State object that inherits from FmvvmState and pass class that derives from BindableBase to the state object.

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

Like the FmvvmStatlessWidget, the second parameter sent to the super class defines if this widget is navigable (like a page) or not (like a widget in a page). Pass true if it is navigable.

#### Bindings on stateful widgets
This is where things get more complex. With stateful widgets bindings can be bi-directional. That is to say, when values in the viewmodel change, we want to update the widget and when values in the widget change, we want to update the viewmodel.

Because many of the sub widgets do not have consistent change events or are not persistent, binding is done a little differently than you may have experienced in mvvm frameworks for other platforms.

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

We can also set the binding direction to one time. If set to one time the binding will always return the value that it was when first requested, regardless of any changes that may have happened to the value stored in the viewmodel.

In the build method we can use our binding to give values to some of the widgets we are using.

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

That handles getting value changes from the viewmodel to the widget, how about values that change in the widget back to the viewmodel? That gets a little more complicated. Let's look at a Switch.

```
Switch(
  value: getValue(_boolBinding) as bool,
  onChanged: getOnChanged(_boolBinding),
),
```

Here the value property is set the same as it was for the Text widget, using the getValue method. The getvalue method is for values coming back from the viewmodel to the widget. The onChanged event is for values from the Widget going to the viewModel. Here we use a method called getOnChanged that receives a reference to the binding and sets the value on the viewmodel based on the new value in the widget. If you don't want any changed values in the widget being sent back to the viewmodel, simply don't set the OnChanged even to call the getOnChanged() method.

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

### Commands
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
Many times the shape and type of information stored in your viewmodel may not be in the right format to be directly bound to a widget. Remember, the view model shouldn't know about any views that use it, their capabilities or their shape. So while a viewmodel wouldn't have a property to say if something like a button was enabled, it might have a isValid property and then create a binding to enable/disable a save button based on if the viewmodel's data is valid to save.

What does this have to do with value conversion? Simply that it is expected that the value in a viewmodel will not always be in a format needed by the widget for display. Take the following simple example, inside the viewmodel we have a counter property that is implemented as an int but we want to bind that to a Text widget that is expecting a string.

First we create a class that can convert back and forth:

```
class NumberValueConverter implements ValueConverter {
  Object convert(Object source, Object value, {Object parameter}) {
    return value.toString();
  }

  Object convertBack(Object source, Object value, {Object parameter}) {
    return int.tryParse(value) ?? 0;
  }
}
```

The convert function is used by a binding to go from the value in the viewmodel or model to the widget. The convert back method is information coming from the widget back to the view model or model. If this were used on a binding to a TextField and the user entered a 'g' charater, the try parse will fail and a 0 sent to the viewmodel and suddenly the TextField would display a value of 0.

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

Now these are simple conversions that may have been easier to simply call .toString(). However, value conversion can be more complex. For example, a isFieldValid method that returns false may text the border color of a Text widget to red if invalid. Converting between those states is what value converters are for.

The final option for value converters is that they can accept an parameter to help in the conversion. The parameter should be sent to the binding using the various getValue and setValue methods on the fmvvmState and fmvvmStatelessWidget classes.

## Navigation
fmvvm allows you to do viewmodel to viewmodel navigation. That is to say that when you want to navigate, that is application business logic that should happen in the viewmodel, usually within a command. Since the viewmodel doesn't know anything about the presentation layer, it just states what other viewmodel in the system it wants to navigation to. Fmvvm uses that to figure out what widget to display. Consider the following code:

```
navigationService.navigate<SomeOtherViewModel>(parameter: "58");
```

In this case the viewmodel will try to navigate to some otehr viewmodel of the type, SomeOtherViewModel. Additionally, a value of "58" will be sent to the SomeOtherViewModel's init method.

So how does it tell what widget to use for that view? By default it used a naming convention. It assumes that all viewmodels are named xyzViewModel and its associated widget has a route named xyzView. This default convention to resolve widgets from views can be overriden by creating your own instance of the ViewLocator class and passing it in to the core.initilaze method.

In order for all this to work a couple of things need to be true.

* The widget diplaying the viewmodel needs to have its isNavigable property set to true.
* The widget that is displaying the viewmodel we are navigating to needs to have its isNavigable property set to true.
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

## Lists
For two way binding to work correctly there is a class that you can use called NotificationList. For any PropertyInfo object passed to a two way binding that refers to a NotificationList object, not only changes to the pointer to this list will cause the UI to be rebuilt, but items added or removed from the list will cause it as well.

Here is how to use the notification list in a class:

```
class _ListViewModel extends ViewModel {
  _ListViewModel() {
    myList = NotificationList();
    myList.add(_ListItem("First", "Item"));
    myList.add(_ListItem("Second", "Item"));
  }
  static PropertyInfo myListProperty = PropertyInfo('myList', NotificationList);

  NotificationList<_ListItem> get myList => getValue(myListProperty);
  set myList(NotificationList<_ListItem> value) => setValue(myListProperty, value);
}

class _ListItem extends BindableBase {
  _ListItem(String lineOne, String lineTwo) {
    this.lineOne = lineOne;
    this.lineTwo = lineTwo;
  }
  static PropertyInfo lineOneProperty = PropertyInfo('lineOne', String);

  String get lineOne => getValue(lineOneProperty);
  set lineOne(String value) => setValue(lineOneProperty, value);

  static PropertyInfo lineTwoProperty = PropertyInfo('lineTwo', String);

  String get lineTwo => getValue(lineTwoProperty);
  set lineTwo(String value) => setValue(lineTwoProperty, value);
}
```

Here we have a viewmodel that uses a NotificationList to expose out a bunch of list times.

Now that same list viewmodel may also have a Command like this:

```
Command get addRow {
  _addRow ??= Command(() {
    myList.add(_ListItem("Another", "Item"));
  });
  return _addRow;
}
```

We can now create a binding to the myList property and then if the addRow Command is called, a new item will be added to the list and the UI will be updated. To do this we can use the following UI code for the list:

```
class _RWListState extends FmvvmState<_RWListView, _ListViewModel> {
  _RWListState(_ListViewModel viewModel) : super(viewModel, true);

  Binding _listBinding;

  @override
  void initState() {
    super.initState();

    _listBinding = createBinding(
        bindableBase, _ListViewModel.myListProperty,
        bindingDirection: BindingDirection.TwoWay);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('RW List'),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20.0),
        itemCount: (getValue(_listBinding) as NotificationList).length,
        itemBuilder: (context, position) {
          return _ListRowWidget((getValue(_listBinding) as NotificationList<_ListItem>)[position]);
        },
      ),
      floatingActionButton: FloatingActionButton(
                    onPressed: () => bindableBase.addRow.execute(),
                    child: Icon(Icons.add),
      ),
    );
  }
}
```

For each line item in the list we are binding to a widget as well and passing in the row class that implements BindableBase. 

```
class _ListRowWidget extends FmvvmStatelessWidget<_ListItem> {
  _ListRowWidget(_ListItem bindableBase) : super(bindableBase, false);


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListTile(title: Text(bindableBase.lineOne), 
            subtitle: Text(bindableBase.lineTwo));
  }
}
```

In this case we are using a StatelessWidget so the binding doesn't matter as much. However, if changes could be made to the list items in the model and we wanted that widget to automatically refresh itself, we could have made the widget for the row derive from FmvvmStatefulWidget and bind to the properties on the model to the row.

## Putting it all together
Here is a sample app that puts together the concepts we have discussed.

```
import 'package:flutter/material.dart';

import 'package:fmvvm/bindings/bindings.dart';
import 'package:fmvvm/fmvvm.dart';
import 'package:fmvvm/interfaces/interfaces.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    Core.initialize();

    var componentResolver = Core.componentResolver;

    componentResolver.registerType<_HomePageViewModel>(() {
      return _HomePageViewModel(
          componentResolver.resolveType<NavigationService>());
    });
    componentResolver.registerType<_CounterViewModel>(() {
      return _CounterViewModel();
    });
    componentResolver.registerType<_ListViewModel>(() {
      return _ListViewModel();
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
              .resolveType<NavigationService>()
              .createViewModel<_HomePageViewModel>(null);
      return _buildRoute(settings, new _HomePageView(arguments));
    } else if (settings.name == '_CounterView') {
      return _buildRoute(settings, new _CounterView(settings.arguments));
    } else if (settings.name == '_ListView') {
      return _buildRoute(settings, new _RWListView(settings.arguments));
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
  _HomePageView(ViewModel viewModel, {Key key, this.title})
      : super(viewModel, key: key);

  final String title;

  @override
  _HomePageViewState createState() => _HomePageViewState(bindableBase);
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
        bindableBase, _HomePageViewModel.counterProperty,
        bindingDirection: BindingDirection.TwoWay,
        valueConverter: _NumberValueConverter());
    controller
        .addListener(getTargetValuedTextChanged(_counterBinding, controller));
    _boolBinding = createBinding(
        bindableBase, _HomePageViewModel.testBoolProperty,
        bindingDirection: BindingDirection.TwoWay);
    _boolBinding1 = createBinding(
        bindableBase, _HomePageViewModel.testBoolProperty,
        bindingDirection: BindingDirection.TwoWay);
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
                  'Go to Count',
                ),
                onPressed: () {
                  bindableBase.navigate.execute();
                }),
            FlatButton(
                child: Text(
                  'Go to Read/Write List',
                ),
                onPressed: () {
                  bindableBase.goToRWList.execute();
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: bindableBase.incrementCounter.execute,
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
                child: Text(getValueWithConversion(
                    bindableBase, bindableBase.counter, _valueConverter)),
              ),
            ],
          ),
        ));
  }
}

class _RWListView extends FmvvmStatefulWidget<_ListViewModel> {
  _RWListView(ViewModel viewModel, {Key key, this.title})
      : super(viewModel, key: key);

  final String title;

  @override
  _RWListState createState() => _RWListState(bindableBase);
}

class _RWListState extends FmvvmState<_RWListView, _ListViewModel> {
  _RWListState(_ListViewModel viewModel) : super(viewModel, true);

  Binding _listBinding;

  @override
  void initState() {
    super.initState();

    _listBinding = createBinding(bindableBase, _ListViewModel.myListProperty,
        bindingDirection: BindingDirection.TwoWay);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('RW List'),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20.0),
        itemCount: (getValue(_listBinding) as NotificationList).length,
        itemBuilder: (context, position) {
          return _ListRowWidget((getValue(_listBinding)
              as NotificationList<_ListItem>)[position]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => bindableBase.addRow.execute(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class _ListRowWidget extends FmvvmStatelessWidget<_ListItem> {
  _ListRowWidget(_ListItem bindableBase) : super(bindableBase, false);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListTile(
        title: Text(bindableBase.lineOne),
        subtitle: Text(bindableBase.lineTwo));
  }
}

class _HomePageViewModel extends ViewModel {
  _HomePageViewModel(this._navigationService);

  final NavigationService _navigationService;

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

  Command _goToRWList;

  Command get goToRWList {
    _goToRWList ??= Command(() {
      _navigationService.navigate<_ListViewModel>();
    });
    return _goToRWList;
  }
}

class _CounterViewModel extends ViewModel {
  @override
  void init(Object parameter) {
    setValue(counterProperty, parameter);
  }

  static PropertyInfo counterProperty = PropertyInfo('counter', int);
  int get counter => getValue(counterProperty);
}

class _ListViewModel extends ViewModel {
  _ListViewModel() {
    myList = NotificationList();
    myList.add(_ListItem("First", "Item"));
    myList.add(_ListItem("Second", "Item"));
  }
  static PropertyInfo myListProperty = PropertyInfo('myList', NotificationList);

  NotificationList<_ListItem> get myList => getValue(myListProperty);
  set myList(NotificationList<_ListItem> value) =>
      setValue(myListProperty, value);

  Command _addRow;

  Command get addRow {
    _addRow ??= Command(() {
      myList.add(_ListItem("Another", "Item"));
    });
    return _addRow;
  }
}

class _ListItem extends BindableBase {
  _ListItem(String lineOne, String lineTwo) {
    this.lineOne = lineOne;
    this.lineTwo = lineTwo;
  }
  static PropertyInfo lineOneProperty = PropertyInfo('lineOne', String);

  String get lineOne => getValue(lineOneProperty);
  set lineOne(String value) => setValue(lineOneProperty, value);

  static PropertyInfo lineTwoProperty = PropertyInfo('lineTwo', String);

  String get lineTwo => getValue(lineTwoProperty);
  set lineTwo(String value) => setValue(lineTwoProperty, value);
}

class _NumberValueConverter implements ValueConverter {
  Object convert(Object source, Object value, {Object parameter}) {
    return value.toString();
  }

  Object convertBack(Object source, Object value, {Object parameter}) {
    return int.tryParse(value) ?? 0;
  }
}
```