import 'package:awesome_notifications/awesome_notifications.dart';

/// A service class for handling notification-related operations.
class NotificationService {
  /// Method called when a notification is created.
  ///
  /// [receivedNotification]: The notification that was created.
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // print('Notification created');
  }


  /// Method called when a notification is displayed.
  ///
  /// [receivedNotification]: The notification that was displayed.
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Method called when a notification is dismissed.
  ///
  /// [receivedAction]: The action that dismissed the notification.
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {}

  /// Method called when an action is received from a notification.
  ///
  /// [receivedAction]: The action received from the notification.
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {}
}
