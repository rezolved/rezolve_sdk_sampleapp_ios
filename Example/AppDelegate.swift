//
//  AppDelegate.swift
//  Example
//
//  Modified by Dennis Koluris on 27/04/2020.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit
import RezolveSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Class variables
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Instance of RezolveSDK & Engagements Service
        RezolveShared.setupSDK()
        RezolveShared.setupGeofence()
        RezolveShared.setupNotifications()
        RezolveShared.setupBackgroundTask()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        RezolveShared.geofence?.performFetchWithCompletionHandler(completionHandler)
    }
}

class RezolveShared {
    static var sdk: Rezolve?
    static var session: RezolveSession?
    static var geofence: EngagementsService?
    static var notificationCenter: UNUserNotificationCenter?
    
    // Rezolve SDK setup
    class func setupSDK() {
        RezolveShared.sdk = Rezolve(apiKey: Config.rezolveApiKey,
                                    partnerId: Config.partnerId,
                                    subPartnerId: nil,
                                    environment: Config.env,
                                    config: nil,
                                    sspActManagerSettings: Config.sspActManagerSettings,
                                    coordinatesConverter: CoordinatesConverter.default)
    }
    
    // Geofence engine setup
    class func setupGeofence() {
        RezolveShared.geofence = EngagementsService()
        RezolveShared.geofence?.rezolveSsp = RezolveShared.sdk?.createRezolveSsp()
        RezolveShared.geofence?.startMonitoring()
    }
    
    // For receiving Local Notifications based on Geofencing Areas
    class func setupNotifications() {
        RezolveShared.notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert]
        
        RezolveShared.notificationCenter?.requestAuthorization(options: options) { (success, error) in
            if !success {
                print("Notifications permission not granted")
            }
        }
    }
    
    // Used for refreshing Geofencing Areas, more accurate tracking
    class func setupBackgroundTask() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }
}
