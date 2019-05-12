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
        bindingDirection: BindingDirection.TwoWay,
        valueConverter: _NumberValueConverter());
    controller
        .addListener(getTargetValuedTextChanged(_counterBinding, controller));
    _boolBinding = createBinding(viewModel, _HomePageViewModel.testBoolProperty,
        bindingDirection: BindingDirection.TwoWay);
    _boolBinding1 = createBinding(
        viewModel, _HomePageViewModel.testBoolProperty,
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
}

class _CounterViewModel extends ViewModel {
  @override
  void init(Object parameter) {
    setValue(counterProperty, parameter);
  }

  static PropertyInfo counterProperty = PropertyInfo('counter', int);
  int get counter => getValue(counterProperty);
}

class _NumberValueConverter implements ValueConverter {
  Object convert(Object source, Object value) {
    return value.toString();
  }

  Object convertBack(Object source, Object value) {
    return int.tryParse(value) ?? 0;
  }
}