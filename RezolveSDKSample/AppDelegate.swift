import UIKit
import SwifterSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Class variables
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Instance of RezolveSDK & Engagements Service
        RezolveService.setupSDK()
        RezolveService.setupGeofence()
        RezolveService.setupNotifications()
        RezolveService.setupBackgroundTask()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        RezolveService.geofence?.performFetchWithCompletionHandler(completionHandler)
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
