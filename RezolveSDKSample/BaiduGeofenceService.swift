//
//  BaiduGeofenceService.swift
//  RezolveSDKSample
//
//  Created by Dennis Koluris on 30/4/20.
//  Copyright © 2020 Rezolve. All rights reserved.
//

import Foundation

class BaiduGeofenceService: NSObject {
    
    private let manager = BMKGeoFenceManager()
    private let maxDistance: CLLocationDistance = 10000
    
    weak var engagementsService: EngagementsService?
    
    override init() {
        super.init()
        
        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: "nRciTWqM3R3uGnOV6VBIc1IH6RevTKuK", authDelegate: self)
        manager.activeAction = [.stayed, .inside, .outside]
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
    }
    
    func replaceAllRegions(with circularRegions: [CLCircularRegion], centerCoordinate: CLLocationCoordinate2D) {
        removeAllRegions()
        circularRegions.forEach { region in
            let distance = region.center.distance(from: centerCoordinate)
            if distance <= maxDistance {
                manager.addCircleRegionForMonitoring(withCenter: region.center, radius: region.radius + 5, coorType: .WGS84, customID: region.identifier)
            }
        }
    }
    
    func removeAllRegions() {
        manager.removeAllGeoFenceRegions()
    }
}

extension BaiduGeofenceService: BMKLocationAuthDelegate {
    
    func onCheckPermissionState(_ iError: BMKLocationAuthErrorCode) {
        print("onCheckPermissionState error: \(iError.rawValue)")
    }
}

extension BaiduGeofenceService: BMKGeoFenceManagerDelegate {
    
    func bmkGeoFenceManager(_ manager: BMKGeoFenceManager, doRequestAlwaysAuthorization locationManager: CLLocationManager) {
        locationManager.requestAlwaysAuthorization()
    }
    
    func bmkGeoFenceManager(_ manager: BMKGeoFenceManager, didAddRegionForMonitoringFinished regions: [BMKGeoFenceRegion]?, customID: String?, error: Error?) {
    }
    
    func bmkGeoFenceManager(_ manager: BMKGeoFenceManager, didGeoFencesStatusChangedFor region: BMKGeoFenceRegion?, customID: String?, error: Error?) {
        if let region = region, let customID = customID, error == nil {
            if region.fenceStatus == .inside {
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 0, identifier: customID)
                engagementsService?.rezolveSsp?.nearbyEngagementsManager.handle(enteringTo: region, systemGeofenceRegion: false, debugLabel: "Ba")
            }
        }
    }
}
