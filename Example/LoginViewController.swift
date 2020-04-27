//
//  LoginViewController.swift
//  Example
//
//  Modified by Dennis Koluris on 27/04/2020.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit
import JWT
import RezolveSDK
import CoreLocation

class LoginViewController: UIViewController {
    // A string containing a formatted UUID code of device.
    let deviceId = "\(UIDevice.current.identifierForVendor!.uuidString)"
    
    // An instance of Rezolve SDK
    private let rezolveSdk = Rezolve(apiKey: Config.rezolveApiKey,
                                     partnerId: Config.partnerId,
                                     subPartnerId: nil,
                                     environment: Config.env,
                                     config: nil,
                                     sspActManagerSettings: nil,
                                     coordinatesConverter: CoordinatesConverter.default)
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginUser(deviceId: deviceId,
                       userName: Config.DemoAuthUser,
                       password: Config.DemoAuthPassword) { (result: Result<GuestResponse?, Error>) in
                                                
            switch result {
            case .success(let result):
                self.createSession(entityId: result!.entityId, partnerId: result!.partnerId)
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Login method
    
    func loginUser(deviceId: String,
                   userName: String,
                   password: String, completionHandler: @escaping (Result<GuestResponse?, Error>) -> Void) {
        
        let urlSession = URLSession.shared
        let urlString = Config.DemoAuthServer + "/v2/credentials/login"
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("0", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Config.rezolveApiKey, forHTTPHeaderField: "x-rezolve-partner-apikey")
        
        let paramsDict: [String: Any] = ["deviceId":"\(deviceId)",
                                         "username":"\(userName)",
                                         "password":"\(password)"]
        
        let paramsData = try? JSONSerialization.data(withJSONObject: paramsDict)
        request.httpBody = paramsData
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data, error == nil else { completionHandler(.failure(error!)); return }
            do {
                let response = try JSONDecoder().decode(GuestResponse.self, from: dataResponse)
                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Helper methods
    
    private func createSession(entityId: String, partnerId: String) {
        let accessToken = createBearer(entityId: entityId, partnerId: partnerId)
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.rezolveSdk.createSession(accessToken: accessToken, username: Config.DemoAuthUser, entityId: entityId, partnerId: partnerId) { (session, error) in
                if let session = session {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.session = session
                    strongSelf.performSegue(withIdentifier: "loginSuccessful", sender: self)
                    
                    // Use the new `session` provided
                    print("OK -> \(session)")
                }
            }
        }
    }
    
    private func createBearer(entityId: String, partnerId: String) -> String {
        let KEY_AUTH = "v2"
        let KEY_ALG = "alg"
        let KEY_TYPE = "typ"
        let KEY_REZOLVE_ENTITY_ID = "rezolve_entity_id"
        let KEY_PARTNER_ENTITY_ID = "partner_entity_id"
        let KEY_EXPIRATION_TIME = "exp"
        let KEY_DEVICE_ID = "device_id"
        let EXPIRATION_TIME_MIN: Double = 30
        
        let claims: [String: Any] = [
            KEY_REZOLVE_ENTITY_ID: entityId,
            KEY_PARTNER_ENTITY_ID: partnerId,
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
}
