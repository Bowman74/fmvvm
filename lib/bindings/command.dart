part of fmvvm.bindings;

class Command {
  Command(Function function) {
    _function = function;
  }

  Function _function;

  Function get execute => _function;
}
