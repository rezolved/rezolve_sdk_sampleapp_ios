import UIKit
import RezolveSDK

class RezolveService {
    static var sdk: Rezolve?
    static var session: RezolveSession?
    static var geofence: RezolveGeofence?
    static var notificationCenter: UNUserNotificationCenter?
    
    // Rezolve SDK setup
    class func setupSDK() {
        RezolveService.sdk = Rezolve(apiKey: Config.rezolveApiKey,
                                     partnerId: Config.partnerId,
                                     subPartnerId: nil,
                                     environment: Config.env,
                                     config: nil,
                                     sspActManagerSettings: Config.sspActManagerSettings,
                                     coordinatesConverter: CoordinatesConverter.default)
    }
    
    // Geofence engine setup
    class func setupGeofence() {
        RezolveService.geofence = RezolveGeofence()
        RezolveService.geofence?.ssp = RezolveService.sdk?.createRezolveSsp{
            // Start monitoring engagements
        }
        RezolveService.geofence?.startMonitoring()
    }
    
    // For receiving Local Notifications based on Geofencing Areas
    class func setupNotifications() {
        RezolveService.notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert]
        
        RezolveService.notificationCenter?.requestAuthorization(options: options) { (success, error) in
            if !success {
                print("Notifications permission not granted")
            }
        }
    }
    
    // Used for refreshing Geofencing Areas, provides more accurate tracking
    class func setupBackgroundTask() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }
}
