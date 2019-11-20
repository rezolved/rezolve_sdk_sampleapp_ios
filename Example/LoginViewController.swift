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

/*      This sample code comes configured to use a Rezolve-hosted authentication server, referred to by Rezolve as a RUA server (Rezolve User Authentication).
    You SHOULD NOT use this server for production apps, it is for testing and Sandbox use only. This sample auth configuration is provided so that:
 
    1) you may compile and test the sample code immediately upon receipt, without having to configure your own auth server
 
    2) so that the partner developer may see an example of how the SDK will utilize an external auth server to obtain permission to talk with the Rezolve APIs.
 
        If you have an existing app with an existing authenticating user base, you will want to utilize YOUR auth server to issue JWT tokens, which the Rezolve
    API will accept. Details on this process are available here:  http://docs.rezolve.com/docs/#jwt-authentication
 
        If you do not have an existing app, or do not have an existing app server, you have the option to either implement your own auth server and use JWT
    authentication as described above, or to have Rezolve install a RUA server for you (the same type auth server this sample code is configured to use).
    Please discuss authentication options with your project lead and/or your Rezolve representative.
*/

class LoginViewController: UIViewController {
    
    // A string containing a formatted UUID code of device.
    let deviceId = "\(UIDevice.current.identifierForVendor!.uuidString)"

    // An instance of Rezolve SDK
    private let rezolveSdk = Rezolve(apiKey: Config.rezolveApiKey,
                                     partnerId: Config.partnerId,
                                     subPartnerId: nil,
                                     environment: Config.env,
                                     config: nil)
    
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
            strongSelf.rezolveSdk.createSession(accessToken: accessToken, entityId: entityId, partnerId: partnerId) { (session, error) in
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
