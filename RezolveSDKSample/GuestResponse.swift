//
//  GuestResponse.swift
//  Example
//
//  Modified by Dennis Koluris on 27/04/2020.
//  Copyright © 2019 Rezolve. All rights reserved.
//

import Foundation

class GuestResponse: Codable {
    
    let entityId: String
    let partnerId: String
    
    enum CodingKeys: String, CodingKey {
        case entityId = "sdkEntity"
        case partnerId = "sdkPartner"
    }
}
