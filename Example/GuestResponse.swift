//
//  GuestResponse.swift
//  Example
//
//  Modified by Dennis Koluris on 27/04/2020.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import Foundation

public class GuestResponse: Codable {
    
    public var firstName: String?
    public var lastName: String?
    public var userName: String
    public var email: String?
    public var phone: String?
    public var language: String
    public var entityId: String
    public var partnerId: String
    public var accountNonExpired: Bool
    public var accountNonLocked: Bool
    public var credentialsNonExpired: Bool
    public var enabled: Bool
    
    public init(firstName: String, lastName: String, userName: String, email: String, phone: String, language: String,
                entityId: String, partnerId: String, accountNonExpired: Bool, accountNonLocked: Bool, credentialsNonExpired: Bool, enabled: Bool ) {
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.email = email
        self.phone = phone
        self.language = language
        self.entityId = entityId
        self.partnerId = partnerId
        self.accountNonExpired = accountNonExpired
        self.accountNonLocked = accountNonLocked
        self.credentialsNonExpired = credentialsNonExpired
        self.enabled = enabled
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case userName = "username"
        case email
        case phone
        case language
        case entityId = "sdkEntity"
        case partnerId = "sdkPartner"
        case accountNonExpired
        case accountNonLocked
        case credentialsNonExpired
        case enabled
    }
}
