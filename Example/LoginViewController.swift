//
//  ViewController.swift
//  Example
//
//  Created by Jakub Bogacki on 08/04/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
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
    
    private func registerUser() {
        
        // Initialize Authentication Manager
        let dataClient = rezolveSdk.getHttpClient()
        let authenticationManager = AuthenticationManager(httpClient: dataClient)
        
        // Form the SignUp Request (Mock data, replace with real values)
        let signUpRequest = SignUpRequest(
            email: "test_email_1@example.com",
            firtName: "John",
            lastName: "Doe",
            name: "John Doe",
            device: DeviceProfile (
                deviceId: "123",
                make: "Apple",
                osType: "iOS",
                osVersion: "10.0",
                locale: "Europe/London"
            )
        )
        
        // Register user
        authenticationManager.register(request: signUpRequest, callback: { (partnerId, entityId) in
            
            // Success, proceed providing these values for creating a new session
            print("Success: partnerId -> \(partnerId) | entityId -> \(entityId)")
        }, errorCallback: { error in
            
            // Error
            print("Error: status code -> \(String(describing: error.statusCode))")
            print(String(describing: error.responseString))
        })
    }
    
    private func createBearer() -> String {
        let KEY_AUTH = "v2"
        let KEY_ALG = "alg"
        let KEY_TYPE = "typ"
        let KEY_REZOLVE_ENTITY_ID = "rezolve_entity_id"
        let KEY_PARTNER_ENTITY_ID = "partner_entity_id"
        let KEY_EXPIRATION_TIME = "exp"
        let KEY_DEVICE_ID = "device_id"
        let EXPIRATION_TIME_MIN: Double = 30
        
        let claims: [String: Any] = [
            KEY_REZOLVE_ENTITY_ID: Config.entityId,
            KEY_PARTNER_ENTITY_ID: Config.partnerId,
            KEY_EXPIRATION_TIME: Date().timeIntervalSince1970 + (EXPIRATION_TIME_MIN * 60),
            KEY_DEVICE_ID: UIDevice.current.identifierForVendor!.uuidString
        ]
        
        let headers = [
            KEY_AUTH: "v2",
            KEY_ALG: "HS512",
            KEY_TYPE: "JWT"
        ]
        
        return JWT.encode(claims: claims, algorithm: .hs512(Config.tokenSecret.data(using: .utf8)!), headers: headers)
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
