//
//  AuthenticationController.swift
//  Example
//
//  Created by Dennis Koluris on 4/11/19.
//  Copyright © 2019 Rezolve. All rights reserved.
//

import Foundation
import JWT
import RezolveSDK

// Example usage
//
// let auth = RezolveAuthentication()
// auth.registerUser(email: "sample_email_1@example.com", callback: {
//     print("User registered, session initiated")
// })

/*
 
 # RezolveConstants
 
    - Persistent variables for session
 
 */

class RezolveConstants {
    // Constants
    static let apiKey = "08e2d4a4-c40f-4a63-b457-c1c7ef3e3d6c"
    static let secret = "rscOHnTWg239IFFNcMxzYWhCJqBXOQxX1nt2ENlUyzHTp5AYkIJTuJj5lMWsNhaETb1yJblC9Jr6UVXvsOU37A=="
    static let env = "sandbox-api-tw.rzlvtest.co"
    
    // Variables
    static var partnerId = "2"
    static var entityId: String?
    static var session: RezolveSession?
}

/*
 
 # RezolveRegistrationResponse
 
    - Registration model
 
 */

class RezolveRegistrationResponse: Codable {
    public let partnerId: String
    public let entityId: String
    
    enum CodingKeys: String, CodingKey {
        case partnerId = "partner_id"
        case entityId = "entity_id"
    }
}

/*
 
 # RezolveAuthentication
 
    - Provides methods for authentication & session
 
 */

class RezolveAuthentication {
    // Initialize Rezolve SDK
    let sdk = RezolveSDK(
        apiKey: RezolveConstants.apiKey,
        env: RezolveConstants.env,
        config: nil,
        subPartnerId: nil,
        dataClient: nil
    )
    
    // Create Bearer
    func createBearer(partnerId: String, entityId: String) -> String {
        let expirationTime: Double = 30
        
        // Claims
        let claims: [String: Any] = [
            "partner_entity_id": partnerId,
            "rezolve_entity_id": entityId,
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
            algorithm: .hs512(RezolveConstants.secret.data(using: .utf8)!),
            headers: headers
        )
    }
    
    // Register User
    func registerUser(email: String, callback: @escaping () -> Void) {
        let accessToken = createBearer(
            partnerId: "\(Date().timeIntervalSince1970)",
            entityId: ":NONE:"
        )
        
        // Get default Http Client
        var httpClient = sdk.getHttpClient()
        httpClient.headers["authorization"] = "Bearer \(accessToken)"
        
        // API POST call
        httpClient.httpPost(url: "/api/v1/authentication/register", json: ["email": email], callback: { (success: HttpResponse) in
            // Get JSON data
            guard
                let json = success.response,
                let registrationResponse = try? JSONDecoder().decode(RezolveRegistrationResponse.self, from: json) else {
                    return
            }
            
            RezolveConstants.partnerId = registrationResponse.partnerId
            RezolveConstants.entityId = registrationResponse.entityId
            self.createSession(callback: callback)
                    
        }, errorCallback: { error in
            // Handle potential error
            print("Error -> \(error)")
        })
    }
    
    // Create Session
    func createSession(callback: @escaping () -> Void) {
        guard let entityId = RezolveConstants.entityId else {
            return
        }
        
        let accessToken = createBearer(
            partnerId: RezolveConstants.partnerId,
            entityId: entityId
        )
        
        sdk.createSession(accessToken: accessToken, entityId: entityId, partnerId: RezolveConstants.partnerId, callback: { session in
            // Setup session and token expiration callback
            RezolveConstants.session = session
            RezolveConstants.session?.authorizationCallback = self.authorizationCallback
            callback()
            
        }, errorCallback: { error in
            // Handle potential error
            print("Error -> \(error)")
        })
    }
    
    // Handle expired token
    func authorizationCallback(response: HttpResponse, next: @escaping () -> Void) {
        createSession(callback: next)
    }
}
