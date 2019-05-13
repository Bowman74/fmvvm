part of fmvvm.bindings;

/// Used by ViewModels and other BindableBase objects to execute a command/function.
///
/// A command object should be returned by a property get statement.
class Command {
  Command(Function function) {
    _function = function;
  }

  Function _function;

  /// Execute's the function on the BindableBase object.
  Function get execute => _function;
}
