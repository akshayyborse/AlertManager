import Foundation
import Combine

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    var email: String
    var phoneNumber: String
    var fullName: String
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, fullName, createdAt, updatedAt
        case phoneNumber = "phone_number"
    }
}

// MARK: - Subscription Model
struct Subscription: Codable, Identifiable, Hashable {
    var id: String
    var userId: String
    var name: String
    var category: SubscriptionCategory
    var price: Double
    var billingCycle: BillingCycle
    var renewalDate: Date
    var notes: String?
    var logoURL: String?
    var isActive: Bool = true
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case category
        case price
        case billingCycle = "billing_cycle"
        case renewalDate = "renewal_date"
        case notes
        case logoURL = "logo_url"
        case isActive
        case createdAt
        case updatedAt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Subscription, rhs: Subscription) -> Bool {
        lhs.id == rhs.id
    }
}

enum SubscriptionCategory: String, Codable, CaseIterable {
    case streaming = "Streaming"
    case music = "Music"
    case gaming = "Gaming"
    case productivity = "Productivity"
    case software = "Software"
    case education = "Education"
    case health = "Health"
    case other = "Other"
    
    var displayName: String {
        self.rawValue
    }
}

enum BillingCycle: String, Codable, CaseIterable {
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    case weekly = "Weekly"
    
    var displayName: String {
        self.rawValue
    }
    
    var abbreviation: String {
        switch self {
        case .monthly: return "/Month"
        case .yearly: return "/Year"
        case .quarterly: return "/Quarter"
        case .weekly: return "/Week"
        }
    }
}

// MARK: - Authentication Models
struct AuthRequest: Codable {
    let email: String?
    let phoneNumber: String?
    let countryCode: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case phoneNumber = "phone_number"
        case countryCode = "country_code"
    }
}

struct OTPVerifyRequest: Codable {
    let identifier: String // email or phone
    let otp: String
    let identifierType: String // "email" or "phone"
    
    enum CodingKeys: String, CodingKey {
        case identifier, otp
        case identifierType = "identifier_type"
    }
}

struct SignupRequest: Codable {
    let fullName: String
    let email: String
    let phoneNumber: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case email, password
        case fullName = "full_name"
        case phoneNumber = "phone_number"
    }
}

struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let data: AuthData?
    
    struct AuthData: Codable {
        let token: String
        let refreshToken: String?
        let user: User?
        let requiresOTP: Bool?
        
        enum CodingKeys: String, CodingKey {
            case token, user
            case refreshToken = "refresh_token"
            case requiresOTP = "requires_otp"
        }
    }
}

struct OTPResponse: Codable {
    let success: Bool
    let message: String
    let data: OTPData?
    
    struct OTPData: Codable {
        let token: String?
        let refreshToken: String?
        let user: User?
        
        enum CodingKeys: String, CodingKey {
            case token, user
            case refreshToken = "refresh_token"
        }
    }
}
