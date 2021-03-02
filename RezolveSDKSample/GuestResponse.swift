import Foundation

class GuestResponse: Codable {
    
    let entityId: String
    let partnerId: String
    
    enum CodingKeys: String, CodingKey {
        case entityId = "sdkEntity"
        case partnerId = "sdkPartner"
    }
}
