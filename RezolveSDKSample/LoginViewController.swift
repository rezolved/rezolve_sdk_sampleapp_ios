import UIKit
import JWT
import RezolveSDK

class LoginViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The device's UUID
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
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
                           password: String,
                           completionHandler: @escaping (Result<GuestResponse, Error>) -> Void) {
        
        var request = URLRequest(url: URL(string: Config.demoAuthServer + "/v2/credentials/login")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Config.rezolveApiKey, forHTTPHeaderField: "x-rezolve-partner-apikey")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "deviceId": deviceId,
            "username": username,
            "password": password
        ])
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        
        RezolveService.sdk?.createSession(accessToken: accessToken,
                                          username: Config.demoAuthUser,
                                          entityId: entityId,
                                          partnerId: partnerId) { [weak self] (session, error) in
            
            RezolveService.session = session
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
