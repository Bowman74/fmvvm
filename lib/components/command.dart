part of fmvvm_components;

class Command {
  Command(Function function) {
    _function = function;
  }

  Function _function;

  Function get execute => _function;
}
