import Foundation

struct AppConfig {
    // MARK: - API Configuration
    static let apiBaseURL = "https://api.subscriptionmanager.com"
    static let apiTimeout: TimeInterval = 30
    
    // MARK: - Feature Flags
    static let enableOfflineMode = true
    static let enableLocalPersistence = true
    static let enableAnalytics = true
    
    // MARK: - Defaults
    static let defaultCurrency = "USD"
    static let defaultLanguage = "en"
    
    // MARK: - Validation Rules
    struct Validation {
        static let minPasswordLength = 8
        static let maxNameLength = 100
        static let maxNotesLength = 500
        
        static func isValidEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return predicate.evaluate(with: email)
        }
        
        static func isValidPhoneNumber(_ phone: String) -> Bool {
            let phoneRegex = "^[0-9]{9,15}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return predicate.evaluate(with: phone)
        }
        
        static func isValidPassword(_ password: String) -> Bool {
            return password.count >= minPasswordLength
        }
    }
    
    // MARK: - Analytics Events
    enum Analytics {
        case appLaunched
        case onboardingCompleted
        case loginAttempted
        case signupCompleted
        case subscriptionAdded
        case subscriptionDeleted
        case dashboardViewed
    }
}
