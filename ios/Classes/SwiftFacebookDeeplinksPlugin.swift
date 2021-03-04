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

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if let url = launchOptions?[.url] as? URL {
      let link = url.absoluteString
      handleLink(link)
    }

    Settings.isAutoInitEnabled = true
    ApplicationDelegate.initializeSDK(launchOptions)
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    AppLinkUtility.fetchDeferredAppLink { (url, error) in
      if let error = error {
        print("Received error while fetching deferred app link %@", error)
      }
      if let url = url {
        if #available(iOS 10, *) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
          UIApplication.shared.openURL(url)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
    handleLink(url.absoluteString)
    return super.application(app, open: url, options: options)
  }

  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
      let link = userActivity.webpageURL?.absoluteString
      if let link = link {
        handleLink(link)
      }
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
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

  private func handleLink(_ link: String) {
    latestLink = link
    guard let eventSink = eventSink else {
      return
    }
    eventSink(link)
  }
}
