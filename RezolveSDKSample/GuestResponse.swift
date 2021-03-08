import Foundation

class GuestResponse: Codable {
    
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let email: String
    let phone: String?
    let entityId: String
    let partnerId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName
        case lastName
        case email
        case phone
        case entityId = "sdkEntity"
        case partnerId = "sdkPartner"
    }
}
