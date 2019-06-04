# fmvvm

A MVVM framework for creating Flutter apps.

# Backgorund

The MVVM model (Model - View - ViewModel) pattern is an alternate pattern to MVC. This framework takes many of the core features of MVVM frameworks and apply the to flutter. Main features include:

-   A structure for creating viewmodels.
-   A Flutter friendly implementation of data binding including value conversion
-   Inversion of control / dependency injection
-   viewmodel to view model navigation

A formal explanation of the MVVM pattern [can be found here](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel).

Implementing the MVVM pattern is about having a formal architecture in our applications and separation of concerns. When implementing MVVM in an app I adhere to the following design goals.

-   A viewmodel should have no idea how it is presented or have any presentation concepts.
-   Value conversion should be used to convert information in the viewmodel to a format needed by the Widget (view) and potentially back again.
-   Navigation should be done from viewmodel to viewmodel.
-   Viewmodels are primarily what is bound to, but models can be exposed by viewmodels and bound to as well.
-   Dependency injection can be used to pass required information to a viewmodel.

# Using fmvvm

## Bootstrapping fmvvm

Bootstrapping fmvvm is pretty easy. To get a reference to fmvvm add the following line to the dependencies section of the pubspec.yaml file:

```
fmvvm: ^0.9.3
```

If we need to reference fmvvm components in code, we can use the following import:

```
import 'package:fmvvm/bindings/fmvvm.dart';
```

The easiest way to start fmvvm is to extend the fmvvmapp. There are a few things we need to override:

-   registerComponents - method to register any dependencies for Inversion of Control / dependency injection.
-   getInitialRoute - the string route name for our app to display by default.
-   getTitle - The title for our app.
-   getRoutes - passes in a string route name and expects a Route to be returned that can be navigated to.

```
class MyApp extends FmvvmApp {
  @override
  void registerComponents(ComponentResolver componentResolver) {
    componentResolver.registerType<_HomePageViewModel>(() {
      return _HomePageViewModel(
          componentResolver.resolveType<NavigationService>());
    });
    componentResolver.registerType<_CounterViewModel>(() {
      return _CounterViewModel();
    });
  }

  @override
  String getInitialRoute() {
    return '_HomePageView';
  }

  @override
  String getTitle() {
    return 'fmvvm Demo';
  }

  @override
  Route getRoutes(RouteSettings settings) {
    if (settings.name == '_HomePageView') {
      var arguments = settings.arguments ??
          Core.componentResolver
              .resolveType<NavigationService>()
              .createViewModel<_HomePageViewModel>(null);
      return buildRoute(settings, new _HomePageView(arguments));
    } else if (settings.name == '_CounterView') {
      return buildRoute(settings, new _CounterView(settings.arguments));
    }
    return null;
  }
}
```

In the above case we have registered two viewmodels. The MyViewModel class is also having the NavigationService resolved and passed to it's constructor.

If we want a custom versions of the ComponentResolver, ViewLocator or NavigationService we can create our own versions that are returned from a custom Registrations class. An instance of the custom Registrations class is then passed in as a parameter to the constructor of the FmvvmApp class. What each of these classes do will be explained later in the documentation.

## Viewmodels

Viewmodels are the primary glue that backs a widget. Viewmodels should inherit from ViewModelBase.

```
import 'package:fmvvm/bindings/fmvvm.dart';

class SampleViewModel extends ViewModelBase {
}
```

### Adding properties

Properties that can be bound to should use the PropertyInfo object. Any object that inherits from BindableBase, including ViewModelBase, can create bindable properties.

Creating a new PropertyInfo object should:

-   Give a name to the propety that matches the getter and setter
-   Be static.
-   Define the type of the property.
-   Be 'public' so they can be used in data binding.

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

Calling setValue will call any listeners if the value did indeed change as it extends the ChangeNotifier class. This is used by data binding.

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

The viewmodel's init method is called after a viewmodel has been instantiated as part of navigation, but before it has been passed to a widget. A parameter is sent to this method through viewmodel to viewmodel navigation. If no parameter is sent, it will be null.

In many cases the init method is used to do any fetches or other data initialization for a viewmodel.

```
@override
void init(Object parameter) {
  // Some initialization code for the view model.
}
```

### Creating a viewmodel in code.

Viewmodels should not be created directly, instead there is a factory method in the NavigationService. Calling the factory method ensures that the init method is also called correctly. In this case the value 5 will be passed to the new viewmodel's init method.

```
var _viewModel = navigationService.createViewModel<SomeViewModel>(5);
```

**In order for this to work, all viewmodels must be registered with the component resolver.**

## Models

Models we want to bind to are written very similarly to ViewModels except they implement the BindableBase interface instead of ViewModel.

```
class MyModel extends BindableBase {
}
```

Bindable properties are created in the same way for models as they are for viewmodels using the PropertyInfo class.

The main difference between a viewmodel and a model that derives from BindableBase is that there is no init method. Models created this way can be instantiated directly using normal means or using the dependency resolver.

While commands are usually not used on models, there is no reason Commands cannot be added.

Models that do not need data binding can be created without extending BindableBase.

## Component resolver

The component resolver is a lightweight dependency injection framework. If we wish to use our own dependency injection framework we can by wrapping it in an instance of a class that implements the ComponentResolver interface and pass it into the Core.Initialize method.

### Registering components.

There are two types of registrations that can be done, an instance registration and a type registration.

#### Instance registration

An instance registration returns the same instance of the object each and every time it is called. This creates the equivalent of a singleton.

```
var myObject = CustomObject();
Core.componentResolver.registerInstance<CustomObject>(myObject);
```

#### Type registration

A type registration returns a new instance each time it is called based on the factory method we provide.

```
Core.componentResolver.registerType<MyViewModel>(() {
  return MyViewModel();
});
```

The component resolver can also register types that pass in parameters to the constructor that may also be registered with the component resolver. This code would pass the registered instance of the NavigationService to the constructor of the MyViewModel class.

```
Core.componentResolver.registerType<MyViewModel>(() {
  return MyViewModel(Core.componentResolver.resolveType<NavigationService>());
});
```

**Extreme care must be taken when resolving other components within a registerType method. If we make a circular dependency relationship, we will create a stack overflow situation.**

### Resolving components

Components are resolved from the componentResolver by type, either by passing their type as a parameter or as a generic.

#### Passing the type by parameter

```
var myClass = Core.ComponentResolver.resolve(MyClass);
```

#### Using a generic type

```
var myClass = Core.ComponentResolver.resolve<MyClass>();
```

## StatelessWidgets

Stateless widgets cannot change, as such they can only get information out of a viewmodel and do not refresh themselves.

Creating a stateless widget should look like this:

```
class MyStatelessWidget extends FmvvmStatelessWidget<SomeViewModel> {
  MyStatelessWidget(ViewModel viewModel, {Key key})
      : super(viewModel, true, key: key);
}
```

**Notice that it is required than an instance of a class that implements BindableBase must be passed to the constructor.**
**Notice that the second parameter passed to the super's constructor defines if this widget is navigable. Pass true for something that is navigated to like a widget that is a page and false for a widget that would be part of a page, like a row in a list. If the value of isNavigable is true, then the object passed to the constructor must derive from ViewModel**

Now the build method can be overridden to create the widget interface and used values supplied by the view model.

The getValueWithConversion method can be used to pull values out of the viewmodel. To use this method pass it a reference to the viewmodel and the value stored in the property that we want to use.

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
            Text('look at this later'),
            ],
          ),
        ));
  }
```

**Calling the super.build(context); method is required for navigation to work correctly.**

We can also set the value of the Text widget directly to the counter property in the view model, but then we would have to handle any required value conversion manually. More on that later.

```
Text(viewModel.counter.toString())
```

## Stateful widgets

Stateful widget should inherit from FmvvmStatefulWidget.

```
class MyStatefulWidget extends FmvvmStatefulWidget<MyViewModel> {
  MyStatefulWidget(MyViewModel viewModel, {Key key, this.title})
      : super(viewModel, key: key);
}
```

Classes that inherit from FmvvmStatefulWidget should always use a State object that inherits from FmvvmState and pass class that derives from BindableBase to the state object.

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

Like the FmvvmStatelessWidget, the second parameter sent to the super class defines if this widget is navigable (like a page) or not (like a widget in a page). Pass true if it is navigable.

## Data binding

Data binding creates a relationship between a class that inherits from BindableBase and a stateful or stateless widget. For the rest of this section we will use the term ViewModel but really it can refer to any class that derives from BindableBase. Any widget that has a reference to an object that derives from BindingBase can use databinding that the BindingWidget.

### Creating a BindingWidget

To create bindings we need to use the BindingWidget. The BindingWidget is part of the widget hierarchy. All child widgets are part of its context and when properties of viewmodels bound to within the change, the children are updated through setState.

A single BindingWidget can contain one or more bindings. Consider the following code inside of a build method.

```
BindingWidget<_HomePageViewModel>(
  bindings: <Binding>[Binding('counter', bindableBase, _HomePageViewModel.counterProperty, bindingDirection: BindingDirection.TwoWay)],
  builder: (bc) => Hero(
    tag: 'countHero',
    child: Text('More on this in a bit'),
    ),
),
```

Here we have a BindingWidget with a generic pointing to the \_HomePageViewModel. BindingWidgets are expected only to be bound to a single BindableBase object. All bindings within the BindingWidget should point to that object.

The bindings property is a collection of bindings. Each binding has a key. The key is used to look up bindings when trying to get or set values. This key must be unique within the BindingWidget. This means that the same property on the BindableBase object can be bound to multiple times using different value converters.

The BindableBase object and the PropertyInfo must also be passed along with the binding. Optionally the binding direction can be set.We have also stated that the binding direction is two way. This will allow changes in the viewmodel's property or the entire viewmodel to call setState() and redraw the BindingWidget at its descendants.

We can also set the binding direction to one time. If set to one time the binding will always return the value that it was when first requested, regardless of any changes that may have happened to the value stored in the viewmodel.

We can also pass a ValueConverter which will be discussed later.

### Getting values from the BindingWidget

We saw how to setup a binding widget, but how do we get information from it. For that we are going to use two methods on the BindingWidget: of and getValue. The of method will find the BindingWidget in the tree and the getValue method will return the value. Here is that same binding code again, but this time we'll be setting the value of the text widget.

```
BindingWidget<_HomePageViewModel>(
  bindings: <Binding>[Binding('counter', bindableBase, _HomePageViewModel.counterProperty, bindingDirection: BindingDirection.TwoWay, valueConverter: _NumberValueConverter())],
  builder: (bc) => Hero(
    tag: 'countHero',
    child: Text(BindingWidget.of<_HomePageViewModel>(bc).getValue('counter')),
  ),
),
```

Here the Text widget is a child the BindingWidget. The builder: property provides us with the BuildContext we need to find the BindingWidget. To get a reference to that binding widget from the Text widget we use the .of operator passing in the BindableBase type as a generic and it will find the nearest ancestor BindingWidget using that type. This is why multiple bindings can be specified in a single BindingWidget.

Once we have a reference to that BindingWidget we call getValue. To this method we need to pass in the key to the binding we set up, in this case 'counter'.

### Handling when a widget changes

That handles getting value changes from the viewmodel to the widget, how about values that change in the widget back to the viewmodel? That gets a little more complicated. Let's look at a Switch.

```
BindingWidget<_HomePageViewModel>(
  bindings: <Binding>[Binding('testBool', bindableBase, _HomePageViewModel.testBoolProperty, bindingDirection: BindingDirection.TwoWay)],
  builder: (c) => Switch(
    value: BindingWidget.of<_HomePageViewModel>(c).getValue('testBool') as bool,
    onChanged: BindingWidget.of<_HomePageViewModel>(c).getOnChanged('testBool'),
  ),
),
```

Here the value property is set the same as it was for the Text widget, using the getValue method. The getValue method is for values coming back from the viewmodel to the widget. The onChanged event is for values from the Widget going to the viewModel. Here we use a method called getOnChanged that take a binding key and returns a reference to a function that sets the value on the viewmodel based on the new value in the widget. If we don't want any changed values in the widget being sent back to the viewmodel, simply don't set the OnChanged even to call the getOnChanged() method.

But what about things that use a controller like a TextField?

To do this we first create the controller in the State object.

```
TextEditingController _myController;
```

Then create an instance of it in the initState method.

```
@override
void initState() {
  super.initState();

  _myController = TextEditingController();
  }
```

Then in the build method we can use our BindingWidget:

```
BindingWidget<_HomePageViewModel>(
  bindings: <Binding>[Binding('counter', bindableBase, _HomePageViewModel.counterProperty, bindingDirection: BindingDirection.TwoWay, valueConverter: _NumberValueConverter())],
  builder: (bc) {
    controller.text = BindingWidget.of<_HomePageViewModel>(bc).getValue('counter');
    return TextField(
      style: Theme.of(context).textTheme.display1,
      controller: controller,
      onChanged: BindingWidget.of<_HomePageViewModel>(bc).getOnChanged('counter'),
    );
  }
),
```

Here in our builder property of the BindingWidget we create a function and in that function we can set the text property of the controller. This ensured that the TextField is always in sync with what is in the BindableBase property it is bound to. Then we handle the onChanged event just like we did with the Switch.

**In order to send widget values back to the viewmodel there needs to be a way, usually an event, that you can use to know the change occurred.**

### Commands

Commands are functions that we want to call on our viewmodel. In the viewmodels section we went over how a Command can be set up in a view model. Here is an example of calling that command from a FloatingActionButton widget in the build method.

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
  onPressed: () {viewModel.navigate.execute(BindingWidget.of<_SomeViewModel>(bc).getValue('someBindingName'));})
```

In this case the value from a binding would be passed as a parameter to the command.

### Value conversion

Many times the shape and type of information stored in our viewmodel may not be in the right format to be directly bound to a widget. Remember, the view model shouldn't know about any views that use it, their capabilities or their shape. So while a viewmodel wouldn't have a property to say if something like a button was enabled, it might have a isValid property and then create a binding to enable/disable a save button based on if the viewmodel's data is valid to save.

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

The convert function is used by a binding to go from the value in the viewmodel or model to the widget. The convert back method is information coming from the widget back to the view model or model. If this were used on a binding to a TextField and the user entered a 'g' character, the try parse will fail and a 0 sent to the viewmodel and suddenly the TextField would display a value of 0.

Value converters are sent to bindings when they are created and used automatically after that on calls to getValue and setValue.

```
BindingWidget<_HomePageViewModel>(
  bindings: <Binding>[Binding('counter', bindableBase, _HomePageViewModel.counterProperty, bindingDirection: BindingDirection.TwoWay, valueConverter: _NumberValueConverter())],
  builder: (bc) => Hero(
    tag: 'countHero',
    child: ...child widgets...
    ),
),
```

Now these are simple conversions that may have been easier to simply call .toString(). However, value conversion can be more complex. For example, a isFieldValid method that returns false may text the border color of a Text widget to red if invalid. Converting between those states is what value converters are for.

The final option for value converters is that they can accept an parameter to help in the conversion. The parameter should be sent to the binding using the various getValue and getOnChanged methods on the BindingWidget.

## Navigation

fmvvm allows us to do viewmodel to viewmodel navigation. That is to say that when we want to navigate, that is application logic that should happen in the viewmodel, usually within a Command. Since the viewmodel doesn't know anything about the presentation layer, it just states what other viewmodel in the system it wants to navigation to. Fmvvm uses that to figure out what widget to display. Consider the following code:

```
navigationService.navigate<Object, SomeOtherViewModel>(parameter: "58");
```

In this case the viewmodel will try to navigate to some other viewmodel of the type, SomeOtherViewModel. Additionally, a value of "58" will be sent to the SomeOtherViewModel's init method. The first type of the generic

So how does it tell what widget to use for that view? By default it used a naming convention. It assumes that all viewmodels are named xyzViewModel and its associated widget has a route named xyzView. This default convention to resolve widgets from views can be overridden by creating our own instance of the ViewLocator class and passing it in to the FmvvmApp constructor.

In order for all this to work a couple of things need to be true.

-   The widget displaying the viewmodel needs to have its isNavigable property set to true.
-   The widget that is displaying the viewmodel we are navigating to needs to have its isNavigable property set to true.
-   The viewmodel we are navigating to needs to be registered in the component resolver.
-   The viewmodel and associated route need to be named appropriately or another method of viewmodel resolution needs to be provided.

Here is how those routes can be set up in a class that extends FmvvmApp:

```
  @override
  Route getRoutes(RouteSettings settings) {
    if (settings.name == '_HomePageView') {
      var arguments = settings.arguments ??
          Core.componentResolver
              .resolveType<NavigationService>()
              .createViewModel<_HomePageViewModel>(null);
      return buildRoute(settings, new _HomePageView(arguments));
    } else if (settings.name == '_CounterView') {
      return buildRoute(settings, new _CounterView(settings.arguments));
    } else if (settings.name == '_ListView') {
      return buildRoute(settings, new _RWListView(settings.arguments));
    }
    return null;
  }
```

A few things to notice, we don't normally do anything to create or pass an instance of the viewmodel to the widget in the route. This is done for us by the NavigationService's navigate method. It is sent with the settings.arguments. The exception to this is the initialRoute, when the app first starts. This isn't navigated to using the NavigationService.navigate method. For this we have to check and see that the settings.arguments are null and if so set it to an instance of the viewmodel using the NavigationService's createViewModel method.

The buildRoute method is provided for us as part of the FmvvmApp base class.

**The NavigationService's navigate method returns a Future so the calling viewmodel can await the navigation operation being completed.**

Navigating back is as simple as calling:

```
NavigationService.navigateBack();
```

### Navigating to a viewmodel for a result

Fmvvm's navigation service also allows you to navigate to another viewmodel and wait for a result using a Future<T> where T can be any object. There are two methods that can help with this, navigateForResult and navigateBackWithResult.

The navigateForResult method is made from the calling viewmodel and takes an additional generic type to specify a return value. Take the following code:

```
int someMethod() async {
  return await _navigationService.navigateForResult<int, SomeOtherViewModel>();
}
```

In some method we are using the navigationService to navigate to the SomeOtherViewModel and we expect a result back as an integer. Since the navigateForResult method returns a Promise<R> we and use the async/await operators.

In SomeOtherViewModel we might also have code like this:

```
Command _navigateBack;

Command get navigateBack {
  _navigateBack ??= Command(() {
    _navigationService.navigateBackWithResult(55);
  });
  return _navigateBack;
}
```

In this case the navigateBack Command would pop the current viewmodel off the stack (SomeOtherViewModel) and return back the value of 55 to the calling view model.

Often there may be a view with a back button or a hardware back button that is pressed on an Android device. To handle this we can use a WillPopScope widget as shown here:

```
WillPopScope(
  onWillPop: () async {
    await bindableBase.navigateBack.execute();
    return false;
  },
  child: ''' Some child widget structure
),
```

In this case we use the onWillPop event of the WillPopScope widget to determine that the user pressed the navigation bar back button or a hardware back button. In the event handler we call the navigate back method that in our viewmodel will call navigateBackWithResult. We then return false in the onWillPop event handler because our navigateBack Command already did the back navigation and we don't want to do it again.

## Lists

For two way binding to work correctly there is a class that we can use called NotificationList. For any PropertyInfo object passed to a two way binding that refers to a NotificationList object, not only changes to the pointer to this list will cause the UI to be rebuilt, but items added or removed from the list will cause it as well. This is because the NotificationList uses the ChangeNotifier class as a mixin and notifyListeners() is called when items are added or removed from the list.

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
@override
Widget build(BuildContext context) {
  super.build(context);

  return Scaffold(
    appBar: AppBar(
      title: Text('RW List'),
    ),
    body: BindingWidget<_ListViewModel>(
            bindings: <Binding>[Binding('list', bindableBase, _ListViewModel.myListProperty)],
            builder: (bc) => ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              itemCount: (BindingWidget.of<_ListViewModel>(bc).getValue('list') as NotificationList).length,
              itemBuilder: (context, position) {
                return _ListRowWidget((BindingWidget.of<_ListViewModel>(bc).getValue('list') as NotificationList)[position]);
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => bindableBase.addRow.execute(),
      child: Icon(Icons.add),
    ),
  );
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

In this case we are using properties of the BindableBase object directly. However, if changes could be made to the list items in the model and we wanted that widget to automatically refresh itself, we could have used a BindingWidget.

## Putting it all together

Here is a sample app that puts together the concepts we have discussed.

```
import 'package:flutter/material.dart';

import 'package:fmvvm/bindings/bindings.dart';
import 'package:fmvvm/fmvvm.dart';
import 'package:fmvvm/interfaces/interfaces.dart';

void main() => runApp(MyApp());

class MyApp extends FmvvmApp {
  @override
  void registerComponents(ComponentResolver componentResolver) {
    componentResolver.registerType<_HomePageViewModel>(() {
      return _HomePageViewModel(
          componentResolver.resolveType<NavigationService>());
    });
    componentResolver.registerType<_CounterViewModel>(() {
      return _CounterViewModel(
          componentResolver.resolveType<NavigationService>());
    });
    componentResolver.registerType<_ListViewModel>(() {
      return _ListViewModel();
    });
  }

  @override
  String getInitialRoute() {
    return '_HomePageView';
  }

  @override
  String getTitle() {
    return 'fmvvm Demo';
  }

  @override
  Route getRoutes(RouteSettings settings) {
    if (settings.name == '_HomePageView') {
      var arguments = settings.arguments ??
          Core.componentResolver
              .resolveType<NavigationService>()
              .createViewModel<_HomePageViewModel>(null);
      return buildRoute(settings, new _HomePageView(arguments));
    } else if (settings.name == '_CounterView') {
      return buildRoute<int>(settings, new _CounterView(settings.arguments));
    } else if (settings.name == '_ListView') {
      return buildRoute(settings, new _RWListView(settings.arguments));
    }
    return null;
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

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
    controller2 = TextEditingController();
  }

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
            Text(
              'You have pushed the button this many times:',
            ),
            BindingWidget<_HomePageViewModel>(
              bindings: <Binding>[
                Binding(
                    'counter', bindableBase, _HomePageViewModel.counterProperty,
                    bindingDirection: BindingDirection.TwoWay,
                    valueConverter: _NumberValueConverter())
              ],
              builder: (bc) => Hero(
                    tag: 'countHero',
                    child: Text(BindingWidget.of<_HomePageViewModel>(bc)
                        .getValue('counter')),
                  ),
            ),
            BindingWidget<_HomePageViewModel>(
                bindings: <Binding>[
                  Binding('counter', bindableBase,
                      _HomePageViewModel.counterProperty,
                      bindingDirection: BindingDirection.TwoWay,
                      valueConverter: _NumberValueConverter())
                ],
                builder: (bc) {
                  controller.text = BindingWidget.of<_HomePageViewModel>(bc)
                      .getValue('counter');
                  controller.selection = new TextSelection.collapsed(
                      offset: controller.text.length);
                  return TextField(
                    style: Theme.of(context).textTheme.display1,
                    controller: controller,
                    onChanged: BindingWidget.of<_HomePageViewModel>(bc)
                        .getOnChanged('counter'),
                  );
                }),
            BindingWidget<_HomePageViewModel>(
                bindings: <Binding>[
                  Binding('counter', bindableBase,
                      _HomePageViewModel.counterProperty,
                      bindingDirection: BindingDirection.TwoWay,
                      valueConverter: _NumberValueConverter())
                ],
                builder: (bc) {
                  var controllerText = BindingWidget.of<_HomePageViewModel>(bc)
                      .getValue('counter') as String;
                  controller2.text = controllerText;
                  controller2.selection = new TextSelection.collapsed(
                      offset: controllerText.length);
                  return TextField(
                    style: Theme.of(context).textTheme.display1,
                    controller: controller2,
                    onChanged: BindingWidget.of<_HomePageViewModel>(bc)
                        .getOnChanged('counter'),
                  );
                }),
            BindingWidget<_HomePageViewModel>(
              bindings: <Binding>[
                Binding('testBool', bindableBase,
                    _HomePageViewModel.testBoolProperty,
                    bindingDirection: BindingDirection.TwoWay)
              ],
              builder: (c) => Switch(
                    value: BindingWidget.of<_HomePageViewModel>(c)
                        .getValue('testBool') as bool,
                    onChanged: BindingWidget.of<_HomePageViewModel>(c)
                        .getOnChanged('testBool'),
                  ),
            ),
            BindingWidget<_HomePageViewModel>(
              bindings: <Binding>[
                Binding('testBool', bindableBase,
                    _HomePageViewModel.testBoolProperty,
                    bindingDirection: BindingDirection.TwoWay)
              ],
              builder: (c) => Expanded(
                    child: Switch(
                      value: BindingWidget.of<_HomePageViewModel>(c)
                          .getValue('testBool') as bool,
                      onChanged: BindingWidget.of<_HomePageViewModel>(c)
                          .getOnChanged('testBool'),
                    ),
                  ),
            ),
            FlatButton(
                child: Text(
                  'Go to Count and add 1',
                ),
                onPressed: () {
                  bindableBase.viewValueAddOne.execute();
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
      ),
    );
  }
}

class _CounterView extends FmvvmStatelessWidget<_CounterViewModel> {
  _CounterView(_CounterViewModel viewModel, {Key key})
      : super(viewModel, true, key: key);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Current Count'),
        ),
        body: WillPopScope(
            onWillPop: () async {
              await bindableBase.navigateBack.execute();
              return false;
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Counter Value:',
                  ),
                  BindingWidget<_CounterViewModel>(
                    bindings: <Binding>[
                      Binding('counter', bindableBase,
                          _CounterViewModel.counterProperty,
                          valueConverter: _NumberValueConverter())
                    ],
                    builder: (bc) => Hero(
                          tag: 'countHero',
                          child: Text(BindingWidget.of<_CounterViewModel>(bc)
                              .getValue('counter')),
                        ),
                  ),
                ],
              ),
            )));
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('RW List'),
      ),
      body: BindingWidget<_ListViewModel>(
        bindings: <Binding>[
          Binding('list', bindableBase, _ListViewModel.myListProperty)
        ],
        builder: (bc) => ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              itemCount: (BindingWidget.of<_ListViewModel>(bc).getValue('list')
                      as NotificationList)
                  .length,
              itemBuilder: (context, position) {
                return _ListRowWidget((BindingWidget.of<_ListViewModel>(bc)
                    .getValue('list') as NotificationList)[position]);
              },
            ),
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

  Command get viewValueAddOne {
    _navigate ??= Command(() async {
      counter = await _navigationService
          .navigateForResult<int, _CounterViewModel>(parameter: counter);
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
  _CounterViewModel(this._navigationService);

  final NavigationService _navigationService;

  @override
  void init(Object parameter) {
    setValue(counterProperty, parameter);
  }

  static PropertyInfo counterProperty = PropertyInfo('counter', int);
  int get counter => getValue(counterProperty);

  Command _navigateBack;

  Command get navigateBack {
    _navigateBack ??= Command(() {
      _navigationService.navigateBackWithResult(counter + 1);
    });
    return _navigateBack;
  }
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
