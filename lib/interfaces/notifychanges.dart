part of fmvvm.interfaces;

/// Interface to be used by objects that can be subscribed to in order to get notified when a change occurs.
abstract class NotifyChanges {
  /// The stream that can be subscribed to for change notifications.
  ///
  /// This is used primarily by fmvvm for data binding.
  Stream get onChanged;
}
