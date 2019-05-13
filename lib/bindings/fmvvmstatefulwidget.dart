part of fmvvm.bindings;

/// Class to expend for all StatefulWidgets that plan to use databinding and be bound to a viewmodel.
abstract class FmvvmStatefulWidget<V extends BindableBase>
    extends StatefulWidget implements BindableBaseHolder<V> {
  /// Creates the StatefulWidget.
  ///
  /// [_bindableBase] - A reference to the BindableBase to be used.
  @mustCallSuper
  FmvvmStatefulWidget(this._bindableBase, {Key key}) : super(key: key);

  final V _bindableBase;

  /// The class's bindablebase reference.
  V get bindableBase => _bindableBase;
}
