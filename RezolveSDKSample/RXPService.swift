//
//  RXPService.swift
//  RezolveSDKSample
//
//  Created by Dennis Koluris on 9/5/22.
//  Copyright © 2022 Rezolve. All rights reserved.
//

import UIKit
import CoreLocation
import RezolveSDKLite

final class RXPService {
    
    var sessionAccessToken: String?
    
    init(monitoringCallback: @escaping ((Result<RXPCheckInSuccess, RezolveError>) -> Void)) {
        requestCheckIn(monitoringCallback: monitoringCallback)
    }
    
    func requestCheckIn(monitoringCallback: @escaping (Result<RXPCheckInSuccess, RezolveError>) -> Void) {
    
        let apnsToken = RezolveService.apnsToken
        let pushToken = apnsToken ?? ""
        #if DEBUG
        let tokenType = apnsToken != nil ? "APN_DEBUG" : "NONE"
        #else
        let tokenType = apnsToken != nil ? "APN_RELEASE" : "NONE"
        #endif
        
        let checkInPayload = RXPCheckIn(
            applicationId: UIApplication.appBundle(),
            version: UIApplication.appVersion(),
            os: "IOS",
            pushToken: pushToken,
            pushTokenType: tokenType,
            apiKey: Config.rezolveApiKey
        )
        RezolveService.session?.rxpManager.requestCheckIn(checkInPayload: checkInPayload, completionHandler: { [weak self] (result: Result<RXPCheckInSuccess, RezolveError>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let success):
                self.sessionAccessToken = success.sessionAccessToken
                monitoringCallback(result)
            case .failure(_):
                monitoringCallback(result)
            }
        })
    }
    
    func requestNearMe(_ location: CLLocationCoordinate2D, limit: Int, offset: Int, filter: RXPNearMeFilter, completion: @escaping (Result<RXPNearMeSuccess, RezolveError>) -> Void) {
        let locationPayload = RXPNearMeLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            radius: 20000,
            coordinateSystem: "WGS84"
        )
        RezolveService.session?.rxpManager.requestNearMe(locationPayload: locationPayload, filter: filter, limit: limit, offset: offset, completionHandler: completion)
    }
    
    func getAllTags(completionHandler: @escaping (Result<[RXPTag], RezolveError>) -> Void) {
        RezolveService.session?.rxpManager.getAllTags(completionHandler: { (result: Result<[RXPTag], RezolveError>) in
            completionHandler(result)
        })
    }
    
    func updateUserTags(with list: RXPSelectedTagList, completionHandler: @escaping (Result<[RXPTag], RezolveError>) -> Void) {
        RezolveService.session?.rxpManager.updateUserTags(tagsPayload: list, completionHandler: { (result: Result<[RXPTag], RezolveError>) in
            completionHandler(result)
        })
    }
}
