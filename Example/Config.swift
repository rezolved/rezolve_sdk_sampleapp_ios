//
//  Config.swift
//  Example
//
//  Modified by Dennis Koluris on 27/04/2020.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import Foundation
import RezolveSDK

/*
This sample code comes configured to use a Rezolve-hosted authentication server, referred to by Rezolve as a RUA server (Rezolve User Authentication).

You SHOULD NOT use this server for production apps, it is for testing and Sandbox use only. This sample auth configuration is provided so that:
    1) You may compile and test the sample code immediately upon receipt, without having to configure your own auth server
    2) So that the partner developer may see an example of how the SDK will utilize an external auth server to obtain permission to talk with the Rezolve APIs.

If you have an app with an existing authenticating user base, you will want to utilize YOUR auth server to issue JWT tokens, which the Rezolve API will accept. Details on this process are available here: http://docs.rezolve.com/docs/#jwt-authentication

If you do not have an existing app, or do not have an existing authentication server, you have the option to either implement your own auth server and use JWT
    authentication as described above, or to have Rezolve install a RUA server for you (the same type auth server this sample code is configured to use).

Please discuss authentication options with your project lead and/or your Rezolve representative.
*/

class Config {
    // Data provided by Rezolve admin
    static let demoAuthServer = ""
    static let demoAuthUser = ""
    static let demoAuthPassword = ""
    
    static let env = RezolveEnv.sandbox
    static let rezolveApiKey = "08e2d4a4-c40f-4a63-b457-c1c7ef3e3d6c"
    static let partnerId = "2"
    static let entityId = "1c5e499c-efad-4902-a3c3-1878e8b3e4bc"
    static let tokenSecret = "rscOHnTWg239IFFNcMxzYWhCJqBXOQxX1nt2ENlUyzHTp5AYkIJTuJj5lMWsNhaETb1yJblC9Jr6UVXvsOU37A=="
    
    static let sspActManagerSettings = SspActManagerSettings(
        auth0ClientId: "",
        auth0Secret: "",
        auth0Audience: "",
        auth0Endpoint: "",
        sspEndpoint: "",
        sspWidth: ""
    )
}
