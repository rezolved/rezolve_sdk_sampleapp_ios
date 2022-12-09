import UIKit
import SwifterSwift
import RezolveSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // Class variables
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Instance of RezolveSDK & Engagements Service
        RezolveService.setupSDK()
        RezolveService.setupNotifications(application)
        RezolveService.setupBackgroundTask()
        
        RezolveService.notificationCenter?.delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        RezolveService.geofence?.performFetchWithCompletionHandler(completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.badge, .banner, .sound, .list])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        fetchRXPNotification(response.notification) { notification in
            NotificationsHandler.handle(userInfo: notification.asDictionary ?? [:])
        }
       
        completionHandler()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
        DeepLinkHandler.handle(url: url)
        return true
    }
    
    func fetchRXPNotification(_ notification: UNNotification, engagementCallback: @escaping (EngagementNotification) -> Void) {
        if let engagementId = notification.request.content.userInfo["ForeignID"] as? String {
            RezolveService.geofence?.ssp?.nearbyEngagementResolver.fetchItems(engagementId: engagementId,
                                                                               clicked: true,
                                                                               imageWidths: 300) { result in
                switch result {
                case .success(let engagement):
                    let notification = EngagementNotification(engagement: engagement)
                    engagementCallback(notification)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

// MARK: - Push Notifications

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        RezolveService.apnsToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Push Notifications: Success registering Device Token -> \(RezolveService.apnsToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error))")
    }
}

struct Platform {
    static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}
