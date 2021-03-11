import Foundation

class Storage {
    
    static func save(guestUser: GuestResponse?) {
        if let encoded = try? JSONEncoder().encode(guestUser) {
            UserDefaults.standard.set(encoded, forKey: "user_details")
        }
    }
    
    static func load() -> GuestResponse? {
        if let data = UserDefaults.standard.object(forKey: "user_details") as? Data {
            if let userDetails = try? JSONDecoder().decode(GuestResponse.self, from: data) {
                return userDetails
            }
        }
        return nil
    }
}
