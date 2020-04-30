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

class LoginViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The device's UUID
        let deviceId = "\(UIDevice.current.identifierForVendor!.uuidString)"
        loginUser(deviceId: deviceId,
                  username: Config.demoAuthUser,
                  password: Config.demoAuthPassword) { [weak self] (result: Result<GuestResponse, Error>) in
                                                
            switch result {
            case .success(let result):
                self?.createSession(entityId: result.entityId, partnerId: result.partnerId)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func loginUser(deviceId: String,
                           username: String,
                           password: String, completionHandler: @escaping (Result<GuestResponse, Error>) -> Void) {
        
        let urlSession = URLSession.shared
        let urlString = Config.demoAuthServer + "/v2/credentials/login"
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("0", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Config.rezolveApiKey, forHTTPHeaderField: "x-rezolve-partner-apikey")
        
        let paramsDict = [
            "deviceId": deviceId,
            "username": username,
            "password": password
        ]
        
        let paramsData = try? JSONSerialization.data(withJSONObject: paramsDict)
        request.httpBody = paramsData
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                completionHandler(.failure(error!))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GuestResponse.self, from: dataResponse)
                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(error))
            }
        }
        task.resume()
    }
    
    private func createSession(entityId: String, partnerId: String) {
        let accessToken = createBearer(entityId: entityId, partnerId: partnerId)
        
        RezolveShared.sdk?.createSession(accessToken: accessToken,
                                         username: Config.demoAuthUser,
                                         entityId: entityId,
                                         partnerId: partnerId) { [weak self] (session, error) in
            
            RezolveShared.session = session
            self?.performSegue(withIdentifier: "loginSuccessful", sender: self)
            print("New session started -> \(session.debugDescription)")
        }
    }
    
    private func createBearer(entityId: String, partnerId: String) -> String {
        let claims: [String: Any] = [
            "rezolve_entity_id": entityId,
            "partner_entity_id": partnerId,
            "exp": Date().timeIntervalSince1970 + (30 * 60),
            "device_id": UIDevice.current.identifierForVendor!.uuidString
        ]
        
        let headers = [
            "auth": "v2",
            "alg": "HS512",
            "typ": "JWT"
        ]
        
        return JWT.encode(claims: claims,
                          algorithm: .hs512(Config.tokenSecret.data(using: .utf8)!),
                          headers: headers)
    }
}
