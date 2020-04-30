//
//  EngagementsService.swift
//  Example
//
//  Created by Dennis Koluris on 27/4/20.
//  Copyright © 2020 Rezolve. All rights reserved.
//

import UIKit
import CoreLocation
import RezolveSDK

class EngagementsService {
    
    var rezolveSsp: RezolveSsp?
    private let baiduGeofenceService = BaiduGeofenceService() /* Baidu */
    private var nearbyEngagementsManager: NearbyEngagementsManager? {
        return rezolveSsp?.nearbyEngagementsManager
    }
    
    init() {
        baiduGeofenceService.engagementsService = self /* Baidu */
    }
    
    func startMonitoring() {
        nearbyEngagementsManager?.startMonitoringForNearbyEngagements()
        nearbyEngagementsManager?.debugNotifications = false
        nearbyEngagementsManager?.delegate = self
    }
    
    func stopMonitoring() {
        nearbyEngagementsManager?.stopMonitoringForNearbyEngagements()
        nearbyEngagementsManager?.stopUpdatingDistanceFromNerbyEngagements()
        nearbyEngagementsManager?.resetNotificationSuppressData()
        nearbyEngagementsManager?.delegate = nil
        
        baiduGeofenceService.removeAllRegions() /* Baidu */
    }
    
    func performFetchWithCompletionHandler(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let rezolveSsp = rezolveSsp else {
            completionHandler(.noData)
            return
        }
        rezolveSsp.performFetchWithCompletionHandler(completionHandler)
    }
}

extension EngagementsService: NearbyEngagementsManagerDelegate {
    
    func didStartMonitoring(for circularRegions: [CLCircularRegion], coordinate: CLLocationCoordinate2D, radius: Int) {
        baiduGeofenceService.replaceAllRegions(with: circularRegions, centerCoordinate: coordinate) /* Baidu */
        print("didStartMonitoring")
    }
    
    func didStartMonitoring(for beaconRegion: [CLBeaconRegion], coordinate: CLLocationCoordinate2D, radius: Int) {
    }
    
    func didEnter(circularRegion: GeofenceData) {
        print("didEnter")
    }
    
    func didEnter(beaconRegion: BeaconData) {
    }
    
    func didFail(with error: Error) {
        print("didFail -> \(error.localizedDescription)")
    }
    
    func didUpdateCurrentDistanceFrom(location: CLLocationCoordinate2D, geofences: [GeofenceData], beacons: [BeaconData]) {
        print("didUpdateCurrentDistanceFrom")
    }
    
    func didReceiveInAppNotification(act: SspResolverAct?) {
        print("didReceiveInAppNotification")
    }
}
