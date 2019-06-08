import 'package:flutter_test/flutter_test.dart';

import 'package:fmvvm/fmvvm.dart';
import "dart:async";

void main() {
  test('Subscribe to Message and receive it', () {
    var messageName = "testMessage";
    var messageService = FmvvmMessageService();
    var expectedMessage = "This is the message";

    Timer t;

    var subscription = Subscription(messageName, expectAsync1((e) {
      expect(e, equals(expectedMessage));
      if (t != null) {
        t.cancel();
      }
    }));

    messageService.subscribe(subscription);

    var message = Message(messageName, expectedMessage);

    t = new Timer(new Duration(seconds: 3), () {
      fail('event not fired in time');
    });

    messageService.publish(message);
  });

  test('Subscribe to message and unsubscribe, expect not to receive it', () {
    var messageName = "testMessage";
    var messageService = FmvvmMessageService();
    var expectedMessage = "This is the message";
    var notCalledMessage = "Not called";

    Timer t;

    var subscription = Subscription(messageName, expectAsync1((e) {
      if (t != null) {
        t.cancel();
      }
      expect(e, equals(notCalledMessage));
    }));

    messageService.subscribe(subscription);

    messageService.unsubscribe(subscription);

    var message = Message(messageName, expectedMessage);

    t = new Timer(new Duration(seconds: 1), () {
      subscription.messageHandler(notCalledMessage);
    });

    messageService.publish(message);
  });

    test('Subscribe to message and unsubscribe all, expect not to receive it', () {
    var messageName = "testMessage";
    var messageService = FmvvmMessageService();
    var expectedMessage = "This is the message";
    var notCalledMessage = "Not called";

    Timer t;

    var subscription = Subscription(messageName, expectAsync1((e) {
      if (t != null) {
        t.cancel();
      }
      expect(e, equals(notCalledMessage));
    }));

    messageService.subscribe(subscription);

    messageService.clearAllSubscriptions();

    var message = Message(messageName, expectedMessage);

    t = new Timer(new Duration(seconds: 1), () {
      subscription.messageHandler(notCalledMessage);
    });

    messageService.publish(message);
  });
}