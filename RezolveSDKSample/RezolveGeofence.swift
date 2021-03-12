import UIKit
import CoreLocation
import RezolveSDK

class RezolveGeofence {
    
    var ssp: RezolveSsp?
    
    init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            self.ssp?.nearbyEngagementsManager.refreshLocation()
        }
    }
    
    private var engagementsManager: NearbyEngagementsManager? {
        return ssp?.nearbyEngagementsManager
    }
    
    func startMonitoring() {
        engagementsManager?.startMonitoringForNearbyEngagements()
        engagementsManager?.debugNotifications = false
        engagementsManager?.delegate = self
    }
    
    func stopMonitoring() {
        engagementsManager?.stopMonitoringForNearbyEngagements()
        engagementsManager?.stopUpdatingDistanceFromNearbyEngagements()
        engagementsManager?.resetNotificationSuppressData()
        engagementsManager?.delegate = nil
    }
    
    func performFetchWithCompletionHandler(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let ssp = ssp else {
            completionHandler(.noData)
            return
        }
        ssp.performFetchWithCompletionHandler(completionHandler)
    }
}

extension RezolveGeofence: NearbyEngagementsManagerDelegate {
    
    func didStartMonitoring(for circularRegions: [CLCircularRegion], coordinate: CLLocationCoordinate2D, radius: Int) {
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
    
    func didReceiveInAppNotification(engagement: EngagementNotification) {
        print("didReceiveInAppNotification")
    }
}
