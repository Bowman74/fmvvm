part of fmvvm;

/// Supports the publish/subscribe pattern.
///
/// in fmvvm there is only one instance of this service but multiple subscriptions can be
/// added to the same message name.
///
/// The [MessengeService] allows for loose coupling between objects where anything in the system can
/// send information of interest without being aware of what other parts of the system may use
/// that information.
class FmvvmMessageService extends MessageService {
  List<Subscription> _subscriptions = List<Subscription>();
  List<_Messenger> _messengers = List<_Messenger>();

  /// Publishes a message to be received by any subscribers.
  ///
  /// If there are no subscripbers to the messange name, this method will do nothing.
  @override
  void publish(Message message) {
    if (message == null) {
      throw ArgumentError('A message must be provided.');
    }

    if (_messengers.any((m) => m.name == message.name)) {
      var messenger = _messengers.singleWhere((m) => m.name == message.name);
      messenger.streamController.add(message.parameter);
    }
  }

  /// Adds a subscription to receive notifications when events occur.
  @override
  void subscribe(Subscription subscription) {
    if (subscription == null) {
      throw ArgumentError('A subscription must be provided.');
    }

    _subscriptions.add(subscription);
    if (!_messengers.any((m) => m.name == subscription.name)) {
      _messengers.add(_Messenger(subscription.name));
    }

    if (_messengers.any((m) => m.name == subscription.name)) {
      var messenger =
          _messengers.singleWhere((m) => m.name == subscription.name);

      messenger.streamController.stream
          .asBroadcastStream()
          .listen(subscription.messageHandler);
    }
  }

  /// Removes an existing subscription.
  ///
  /// If the subscription does not exist this method does nothing.
  @override
  void unsubscribe(Subscription subscription) {
    if (subscription == null) {
      throw ArgumentError('A subscription must be provided.');
    }

    _subscriptions.remove(subscription);

    if (!_subscriptions.any((s) => s.name == subscription.name)) {
      var messenger =
          _messengers.singleWhere((m) => m.name == subscription.name);

      _messengers.remove(messenger);
      messenger.close();
    }
  }

  /// Removes all existing subscriptions.
  @override
  void clearAllSubscriptions() {
    _messengers.forEach((m) {
      m.close();
    });

    _subscriptions = List<Subscription>();
    _messengers = List<_Messenger>();
  }
}

class _Messenger {
  _Messenger(String name) {
    this.name = name;
  }
  StreamController _streamController = StreamController.broadcast();

  String name;

  StreamController get streamController => _streamController;

  void close() {
    _streamController.close();
  }
}
