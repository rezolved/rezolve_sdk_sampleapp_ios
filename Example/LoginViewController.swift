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

    private let rezolveSdk = Rezolve(apiKey: Config.rezolveApiKey, partnerId: Config.partnerId, subPartnerId: nil, environment: Config.env, config: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        let authenticationmanager = rezolveSdk.authenticationManager
        authenticationmanager.login(entityId: Config.entityId, partnerId: Config.partnerId, device: DeviceProfile.current) { (result: Result<LoginResponse?, Error>) in
            switch result {
            case .success(let result):
                self.createSession(accessToken: result!.accessToken)
            case .failure(let error):
                print("\(error)")
            }
        }
    }

    func createSession(accessToken: String) {
        rezolveSdk.createSession(accessToken: accessToken, entityId: Config.entityId, partnerId: Config.partnerId) { (session, error) in
            if let session = session {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.session = session
                self.performSegue(withIdentifier: "loginSuccessful", sender: self)
            } else if let error = error {
                print("\(error)")
            }
        }
    }
}
