part of fmvvm.interfaces;

/// Supports the publish/subscribe pattern.
///
/// in fmvvm there is only one instance of this service but multiple subscriptions can be
/// added to the same message name.
///
/// The [MessengeService] allows for loose coupling between objects where anything in the system can
/// send information of interest without being aware of what other parts of the system may use
/// that information.
abstract class MessageService {
  /// Adds a subscription to receive notifications when events occur.
  void subscribe(Subscription subscription);

  /// Removes an existing subscription.
  ///
  /// If the subscription does not exist this method does nothing.
  void unsubscribe(Subscription subscription);

  /// Publishes a message to be received by any subscribers.
  ///
  /// If there are no subscripbers to the messange name, this method will do nothing.
  void publish(Message message);

  /// Removes all existing subscriptions.
  void clearAllSubscriptions();
}

/// A subscription to be used with the MessageService.
class Subscription {
  Subscription(String name, Function(Object parameter) messageHandler) {
    _name = name;
    _messageHandler = messageHandler;
  }

  String _name;
  Function(Object parameter) _messageHandler;

  /// The name of the subscription to listen to messages for.
  ///
  /// Any messages sent with this name will be delivered to the message handler.
  String get name => _name;

  /// The method to call when a message is recieved for the name. The [parameter]
  /// containes the payload of the message.
  Function(Object parameter) get messageHandler => _messageHandler;
}

/// A message to send to the subscription service.
class Message {
  Message(String name, Object parameter) {
    _name = name;
    _parameter = parameter;
  }

  String _name;
  Object _parameter;

  /// The name of the messager to send.
  ///
  /// Messages will be delived to subscriptions with a matching name.
  String get name => _name;

  /// A parameter to send with the message.
  ///
  /// the parameter will be deliverd to the messageHandler of any matching subscriptions.
  Object get parameter => _parameter;
}
