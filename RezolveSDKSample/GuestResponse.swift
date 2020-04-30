//
//  GuestResponse.swift
//  Example
//
//  Modified by Dennis Koluris on 27/04/2020.
//  Copyright © 2019 Rezolve. All rights reserved.
//

import Foundation

public class GuestResponse: Codable {
    
    public var entityId: String
    public var partnerId: String
    
    enum CodingKeys: String, CodingKey {
        case entityId = "sdkEntity"
        case partnerId = "sdkPartner"
    }
}
