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

    private let rezolveSdk = Rezolve(apiKey: Config.rezolveApiKey,
                                     partnerId: Config.partnerId,
                                     subPartnerId: nil,
                                     environment: Config.env,
                                     config: nil)
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSession()
//        let authenticationmanager = rezolveSdk.authenticationManager
//        authenticationmanager.login(entityId: Config.entityId, partnerId: Config.partnerId, device: DeviceProfile.current) { (result: Result<LoginResponse?, Error>) in
//            switch result {
//            case .success(let result):
//                self.createSession(accessToken: result!.accessToken)
//            case .failure(let error):
//                print("\(error)")
//            }
//        }
    }
    
    // MARK: - Helper methods
    
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
        rezolveSdk.createSession(accessToken: createBearer(), entityId: Config.entityId, partnerId: Config.partnerId) { (session, error) in
            if let session = session {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.session = session
                self.performSegue(withIdentifier: "loginSuccessful", sender: self)

                // Use the new `session` provided
                print("OK -> \(session)")
            }
        }
    }
}
