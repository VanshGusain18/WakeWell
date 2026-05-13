import Foundation

struct UserSession: Codable, Equatable {
    let userID: Int
    let authProvider: AuthProvider
    let email: String
    let displayName: String
    let profilePhotoURL: String?
    let memberSince: Date
}
