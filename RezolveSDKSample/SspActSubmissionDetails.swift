import Foundation

struct SspActSubmissionDetails {
    let title: String
    let details: String?
    
    init(title: String, details: String? = nil) {
        self.title = title
        self.details = details
    }
}

struct SspActUserDetails {
    let firstName: String?
    let lastName: String?
    let email: String?
    let phone: String?
    
    init(firstName: String? = nil, lastName: String? = nil, email: String? = nil, phone: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
    }
}
