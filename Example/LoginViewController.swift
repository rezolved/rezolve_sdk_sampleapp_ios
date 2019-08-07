//
//  ViewController.swift
//  Example
//
//  Created by Jakub Bogacki on 08/04/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit
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
    
    private func createSession() {
        // Create a new Device Initializer
        let device = DeviceProfile(
            deviceId: UIDevice.current.identifierForVendor!.uuidString,
            make: "Apple",
            osType: "iOS",
            osVersion: UIDevice.current.systemVersion,
            locale: TimeZone.current.abbreviation()!
        )
        
        rezolveSdk.createSession(entityId: Config.entityId, partnerId: Config.partnerId, device: device, callback: { rezolveSession in
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
