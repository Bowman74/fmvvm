part of fmvvm.bindings;

/// Used by ViewModels and other BindableBase objects to execute a command/function.
///
/// A command object should be returned by a property get statement.
class Command {
  Command(void Function() function, [bool Function()? canExecuteFunction]):
    _function = function {
    _canExecuteFunction = canExecuteFunction ?? () => true;
  }
  
  final void Function() _function;
  bool Function() _canExecuteFunction = () => true;

  /// Execute's the function on the BindableBase object.
  void Function() get execute => _function;
  /// Execute's the function on the BindableBase object if allowed.
  void Function() get executeIf => _canExecuteFunction() ? _function : (){};
  /// Checks if function can be executed on the BindableBase object.
  bool Function() get canExecute => _canExecuteFunction;
}