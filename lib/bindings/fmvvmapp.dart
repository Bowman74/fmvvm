part of fmvvm.bindings;

/// Class to use for the main application in an fmvvm app.
abstract class FmvvmApp extends StatelessWidget {
  /// Constructor for fmvvmApp.
  ///
  /// [registrations] are optionally passed if you would like to
  /// override the default fmvvm behavior.
  @mustCallSuper
  FmvvmApp({Registrations registrations}) {
    Core.initialize(registrations: registrations);

    registerComponents(Core.componentResolver);
  }

  /// Called by the constructor to register any components to be resolved.
  ///
  /// Used for inversion of control.
  void registerComponents(ComponentResolver componentResolver) {}

  /// The title of the default app.
  String getTitle();

  /// The theme to use for the app.
  ///
  /// By default it uses a blue colored theme.
  ThemeData getTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
    );
  }

  /// The name of the initial route to display.
  String getInitialRoute();

  /// Returns a list of routes for the application.
  Route<dynamic> getRoutes(RouteSettings settings);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: getTitle(),
      theme: getTheme(),
      initialRoute: getInitialRoute(),
      onGenerateRoute: getRoutes,
    );
  }

  /// creates a route.
  ///
  /// This method is usually called within [getRoutes]
  MaterialPageRoute buildRoute<R extends Object>(
      RouteSettings settings, Widget builder) {
    return new MaterialPageRoute<R>(
      settings: settings,
      builder: (ctx) => builder,
    );
  }
}
