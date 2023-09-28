//
//  RZLocationManager.swift
//  RezolveSDKSample
//
//  Created by Dennis on 28/9/23.
//  Copyright © 2023 Rezolve. All rights reserved.
//

import Foundation
import CoreLocation

internal final class Observable<ObservedType> {
    public typealias Observer = (_ observable: Observable<ObservedType>, ObservedType) -> Void

    private var observers: [Observer]

    public var value: ObservedType? {
        didSet {
            if let value = value {
                notifyObservers(value)
            }
        }
    }

    public init(_ value: ObservedType? = nil) {
        self.value = value
        observers = []
    }

    public func bind(observer: @escaping Observer) {
        self.observers.append(observer)
    }

    private func notifyObservers(_ value: ObservedType) {
        self.observers.forEach { [unowned self](observer) in
            observer(self, value)
        }
    }
}

internal protocol RZLocationManagerProtocol: NSObjectProtocol {
    var currentLocation: Observable<CLLocation?> { get }
    func startUpdating()
    func stopUpdating()
}

internal final class RZLocationManager: NSObject, RZLocationManagerProtocol, CLLocationManagerDelegate {
    
    var currentLocation: Observable<CLLocation?> = Observable(nil)
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Checking if user allows to use his location in the application.
        checkAuthorizationStatus()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        currentLocation.value = nil
    }
    
    func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            locationManager.requestAlwaysAuthorization()
        default:
            genericUpdateLocation()
        }
    }
    
    func genericUpdateLocation() {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func startUpdating() {
        genericUpdateLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        genericUpdateLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation.value = location
        }
    }
}
