import 'package:flutter/material.dart';

import 'package:fmvvm/fmvvm.dart';

void main() => runApp(MyApp());

class MyApp extends FmvvmApp {
  @override
  void registerComponents(ComponentResolver componentResolver) {
    componentResolver.registerType<_HomePageViewModel>(() {
      return _HomePageViewModel(componentResolver
          .resolveType<NavigationService>() as NavigationService);
    });
    componentResolver.registerType<_CounterViewModel>(() {
      return _CounterViewModel(componentResolver
          .resolveType<NavigationService>() as NavigationService);
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
              .resolveType<NavigationService>()!
              .createViewModel<_HomePageViewModel>(null);
      return buildRoute(
          settings, _HomePageView(arguments as _HomePageViewModel));
    } else if (settings.name == '_CounterView') {
      return buildRoute<int>(
          settings, _CounterView(settings.arguments as _CounterViewModel));
    } else if (settings.name == '_ListView') {
      return buildRoute(
          settings, _RWListView(settings.arguments as _ListViewModel));
    }
    throw Exception('No route defined for ${settings.name}');
  }
}

class _HomePageView extends FmvvmStatefulWidget<_HomePageViewModel> {
  _HomePageView(_HomePageViewModel viewModel, {Key? key})
      : super(viewModel, key: key);

  @override
  _HomePageViewState createState() => _HomePageViewState(bindableBase);
}

class _HomePageViewState extends FmvvmState<_HomePageView, _HomePageViewModel> {
  _HomePageViewState(_HomePageViewModel viewModel) : super(viewModel, true);

  TextEditingController? controller;
  TextEditingController? controller2;

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
                    .getGenericValue<String>('counter')),
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
                  controller!.text = BindingWidget.of<_HomePageViewModel>(bc)
                      .getGenericValue<String>('counter');
                  controller!.selection =
                      TextSelection.collapsed(offset: controller!.text.length);
                  return TextField(
                    style: Theme.of(context).textTheme.headlineMedium,
                    controller: controller,
                    onChanged: BindingWidget.of<_HomePageViewModel>(bc)
                        .getOnChanged('counter') as void Function(String),
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
                      .getGenericValue<String>('counter');
                  controller2!.text = controllerText;
                  controller2!.selection =
                      TextSelection.collapsed(offset: controllerText.length);
                  return TextField(
                    style: Theme.of(context).textTheme.headlineMedium,
                    controller: controller2,
                    onChanged: BindingWidget.of<_HomePageViewModel>(bc)
                        .getOnChanged('counter') as void Function(String),
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
                    .getGenericValue<bool>('testBool'),
                onChanged: BindingWidget.of<_HomePageViewModel>(c)
                    .getOnChanged('testBool') as void Function(bool),
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
                      .getGenericValue<bool>('testBool'),
                  onChanged: BindingWidget.of<_HomePageViewModel>(c)
                      .getOnChanged('testBool') as void Function(bool),
                ),
              ),
            ),
            TextButton(
                child: const Text(
                  'Go to Count and add 1',
                ),
                onPressed: () {
                  bindableBase.viewValueAddOne.execute();
                }),
            TextButton(
                child: const Text(
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
  _CounterView(_CounterViewModel viewModel, {Key? key})
      : super(viewModel, true, key: key);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Current Count'),
        ),
        body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) {
                return;
              }
              if (context.mounted) {
                bindableBase.navigateBack.execute();
              }
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
                          .getGenericValue<String>('counter')),
                    ),
                  ),
                ],
              ),
            )));
  }
}

class _RWListView extends FmvvmStatefulWidget<_ListViewModel> {
  _RWListView(_ListViewModel viewModel, {Key? key})
      : super(viewModel, key: key);

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
          itemCount: (BindingWidget.of<_ListViewModel>(bc)
                  .getGenericValue<NotificationList>('list'))
              .length,
          itemBuilder: (context, position) {
            return _ListRowWidget((BindingWidget.of<_ListViewModel>(bc)
                .getGenericValue<NotificationList>('list'))[position]);
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

  int get counter => getGenericValue<int>(counterProperty);
  set counter(int value) => setGenericValue<int>(counterProperty, value);

  static PropertyInfo currentDateProperty = PropertyInfo('currentDate', int);

  DateTime get currentDate => getGenericValue<DateTime>(currentDateProperty);
  set currentDate(DateTime value) =>
      setGenericValue<DateTime>(currentDateProperty, value);

  static PropertyInfo testBoolProperty = PropertyInfo('testBool', bool, false);

  bool get testBool => getGenericValue<bool>(testBoolProperty);
  set testBool(bool value) => setGenericValue<bool>(testBoolProperty, value);

  Command? _incrementCounter;

  Command get incrementCounter {
    _incrementCounter ??= Command(() {
      counter++;
    });
    return _incrementCounter!;
  }

  Command? _navigate;

  Command get viewValueAddOne {
    _navigate ??= Command(() async {
      counter = await _navigationService
          .navigateForResult<int, _CounterViewModel>(parameter: counter) as int;
    });
    return _navigate!;
  }

  Command? _goToRWList;

  Command get goToRWList {
    _goToRWList ??= Command(() {
      _navigationService.navigate<_ListViewModel>();
    });
    return _goToRWList!;
  }
}

class _CounterViewModel extends ViewModel {
  _CounterViewModel(this._navigationService);

  final NavigationService _navigationService;

  @override
  void init(Object? parameter) {
    setValue(counterProperty, parameter);
  }

  static PropertyInfo counterProperty = PropertyInfo('counter', int);
  int get counter => getGenericValue<int>(counterProperty);

  Command? _navigateBack;

  Command get navigateBack {
    _navigateBack ??= Command(() {
      _navigationService.navigateBackWithResult(counter + 1);
    });
    return _navigateBack!;
  }
}

class _ListViewModel extends ViewModel {
  _ListViewModel() {
    myList = NotificationList();
    myList.add(_ListItem("First", "Item"));
    myList.add(_ListItem("Second", "Item"));
  }
  static PropertyInfo myListProperty = PropertyInfo('myList', NotificationList);

  NotificationList<_ListItem> get myList =>
      getGenericValue<NotificationList<_ListItem>>(myListProperty);
  set myList(NotificationList<_ListItem> value) =>
      setGenericValue<NotificationList<_ListItem>>(myListProperty, value);

  Command? _addRow;

  Command get addRow {
    _addRow ??= Command(() {
      myList.add(_ListItem("Another", "Item"));
    });
    return _addRow!;
  }
}

class _ListItem extends BindableBase {
  _ListItem(String lineOne, String lineTwo) {
    this.lineOne = lineOne;
    this.lineTwo = lineTwo;
  }
  static PropertyInfo lineOneProperty = PropertyInfo('lineOne', String);

  String get lineOne => getGenericValue<String>(lineOneProperty);
  set lineOne(String value) => setGenericValue<String>(lineOneProperty, value);

  static PropertyInfo lineTwoProperty = PropertyInfo('lineTwo', String);

  String get lineTwo => getGenericValue<String>(lineTwoProperty);
  set lineTwo(String value) => setGenericValue<String>(lineTwoProperty, value);
}

class _NumberValueConverter implements ValueConverter {
  Object convert(Object source, Object? value, {Object? parameter}) {
    return value.toString();
  }

  Object convertBack(Object source, Object? value, {Object? parameter}) {
    return int.tryParse(value as String) ?? 0;
  }
}
