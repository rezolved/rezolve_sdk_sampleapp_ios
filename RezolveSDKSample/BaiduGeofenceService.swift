//
//  BaiduGeofenceService.swift
//  RezolveSDKSample
//
//  Created by Dennis Koluris on 30/4/20.
//  Copyright © 2020 Rezolve. All rights reserved.
//

import Foundation
import RezolveSDK

class BaiduGeofenceService: NSObject {
    
    private let manager = BMKGeoFenceManager()
    private let maxDistance: CLLocationDistance = 10000
    
    weak var engagementsService: EngagementsService?
    
    override init() {
        super.init()
        
        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: "6SgDo9iiXSISzKywa0uw34XyoiFwzxGK", authDelegate: self)
        manager.activeAction = [.stayed, .inside, .outside]
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
    }
    
    func replaceAllRegions(with circularRegions: [CLCircularRegion], centerCoordinate: CLLocationCoordinate2D) {
        removeAllRegions()
        circularRegions.forEach { region in
            if region.center.distance(from: centerCoordinate) <= maxDistance {
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
        print("Baidu AK error -> \(iError.rawValue)")
    }
}

extension BaiduGeofenceService: BMKGeoFenceManagerDelegate {
    
    func bmkGeoFenceManager(_ manager: BMKGeoFenceManager, doRequestAlwaysAuthorization locationManager: CLLocationManager) {
        locationManager.requestAlwaysAuthorization()
    }
    
    func bmkGeoFenceManager(_ manager: BMKGeoFenceManager, didGeoFencesStatusChangedFor region: BMKGeoFenceRegion?, customID: String?, error: Error?) {
        
        if error == nil {
            guard
                let region = region,
                let customID = customID else {
                    return
            }
            
            if region.fenceStatus == .inside {
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                              radius: 0,
                                              identifier: customID)
                
                engagementsService?.rezolveSsp?.nearbyEngagementsManager.handle(enteringTo: region,
                                                                                systemGeofenceRegion: false,
                                                                                debugLabel: "Ba")
            }
        }
    }
}
