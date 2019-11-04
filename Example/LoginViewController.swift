//
//  LoginViewController.swift
//  Example
//
//  Created by Jakub Bogacki on 08/04/2019.
//  Copyright © 2019 Rezolve. All rights reserved.
//

import UIKit
import JWT
import RezolveSDK

class LoginViewController: UIViewController {
    
    private let rezolveSdk = RezolveSDK(apiKey: Config.rezolveApiKey,
                                        env: "sandbox-api-tw.rzlvtest.co",
                                        config: nil,
                                        subPartnerId: nil,
                                        dataClient: nil)
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSession()
    }
    
    // MARK: - Helper methods
    
    private func createBearer() -> String {
        let expirationTime: Double = 30
        
        // Claims
        let claims: [String: Any] = [
            "partner_entity_id": Config.partnerId,
            "rezolve_entity_id": Config.entityId,
            "exp": Date().timeIntervalSince1970 + (expirationTime * 60),
            "device_id": UIDevice.current.identifierForVendor!.uuidString
        ]
        
        // Headers
        let headers = [
            "auth": "v2",
            "alg": "HS512",
            "typ": "JWT"
        ]
        
        return JWT.encode(
            claims: claims,
            algorithm: .hs512(Config.tokenSecret.data(using: .utf8)!),
            headers: headers
        )
    }
    
    private func createSession() {
        rezolveSdk.createSession(accessToken: createBearer(), entityId: Config.entityId, partnerId: Config.partnerId, callback: { rezolveSession in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.rezolveSession = rezolveSession
            self.performSegue(withIdentifier: "loginSuccessful", sender: self)

            // Use the new `session` provided
            print("OK -> \(rezolveSession)")
        }, errorCallback: { error in
            // Handle potential error
            print("Error -> \(error)")
        })
    }
}
