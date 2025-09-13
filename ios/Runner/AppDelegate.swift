import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, UNUserNotificationCenterDelegate {

    let CHANNEL_NAME = "com.example.native_counter_app/counter"

    static var counter = 0
    var flutterChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }

        flutterChannel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)

        flutterChannel?.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }

            switch call.method {
            case "startService":
                self.requestNotificationPermission()
                self.updateNotification()
                result(nil)
            case "getValue":
                result(AppDelegate.counter)
            case "increment":
                AppDelegate.counter += 1
                self.updateNotification()
                self.sendCounterUpdateToFlutter()
                result(nil)
            case "decrement":
                AppDelegate.counter -= 1
                self.updateNotification()
                self.sendCounterUpdateToFlutter()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        UNUserNotificationCenter.current().delegate = self

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification auth: \(error)")
            }
            if granted {
                print("Notification permission granted.")
                self.configureNotificationActions()
            } else {
                print("Notification permission denied.")
            }
        }
    }

    func configureNotificationActions() {
        let resetAction = UNNotificationAction(identifier: "RESET_ACTION", title: "Reset", options: [])
        let category = UNNotificationCategory(identifier: "COUNTER_ACTIONS", actions: [resetAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func updateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Native Counter"
        content.body = "Current value: \(AppDelegate.counter)"
        content.categoryIdentifier = "COUNTER_ACTIONS"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "counterNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["counterNotification"])
        UNUserNotificationCenter.current().add(request)
    }

    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "RESET_ACTION" {
            AppDelegate.counter = 0
            updateNotification() 
            sendCounterUpdateToFlutter() 
        }
        completionHandler()
    }

    func sendCounterUpdateToFlutter() {
        flutterChannel?.invokeMethod("updateCounter", arguments: AppDelegate.counter)
    }
}