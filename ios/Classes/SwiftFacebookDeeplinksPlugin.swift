import Flutter
import UIKit
import FBSDKCoreKit

let MESSAGES_CHANNEL = "ru.proteye/facebook_deeplinks/channel"
let EVENTS_CHANNEL = "ru.proteye/facebook_deeplinks/events"

public class SwiftFacebookDeeplinksPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var latestLink: String?
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFacebookDeeplinksPlugin()

        let channel = FlutterMethodChannel(name: MESSAGES_CHANNEL, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)

        let streamChannel = FlutterEventChannel(name: EVENTS_CHANNEL, binaryMessenger: registrar.messenger())
        streamChannel.setStreamHandler(instance)

        registrar.addApplicationDelegate(instance)
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        if let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL {
            _ = self.handleLink(url.absoluteString)
        }
        ApplicationDelegate.initializeSDK(launchOptions as? [UIApplication.LaunchOptionsKey: Any])
        AppLinkUtility.fetchDeferredAppLink { (url, error) in
            if let error = error {
                print("Received error while fetching deferred app link %@", error)
            }
            if let url = url {
                _ = self.handleLink(url.absoluteString)
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        return true
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.handleLink(url.absoluteString)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initialUrl" {
            result(latestLink)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    private func handleLink(_ link: String) -> Bool {
        latestLink = link
        guard let eventSink = eventSink else {
            return false
        }
        eventSink(link)
        return true
    }
}
