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
      return _CounterViewModel();
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
      return buildRoute(settings, new _CounterView(settings.arguments));
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
                  controller2.text = BindingWidget.of<_HomePageViewModel>(bc)
                      .getValue('counter');
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
              builder: (c) => Switch(
                    value: BindingWidget.of<_HomePageViewModel>(c)
                        .getValue('testBool') as bool,
                    onChanged: BindingWidget.of<_HomePageViewModel>(c)
                        .getOnChanged('testBool'),
                  ),
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
