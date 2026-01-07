import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var selectedTab: LoginTab = .email
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var countryCode: String = "+62"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var otpSent = false
    @Published var identifier: String = ""
    @Published var identifierType: String = ""
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    enum LoginTab {
        case email
        case phone
    }
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: - Methods
    
    func sendOTP() {
        errorMessage = nil
        
        switch selectedTab {
        case .email:
            guard !email.isEmpty, isValidEmail(email) else {
                errorMessage = "Please enter a valid email"
                return
            }
            identifier = email
            identifierType = "email"
            
            authService.sendOTP(email: email)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                } receiveValue: { [weak self] in
                    self?.otpSent = true
                }
                .store(in: &cancellables)
            
        case .phone:
            guard !phoneNumber.isEmpty, isValidPhoneNumber(phoneNumber) else {
                errorMessage = "Please enter a valid phone number"
                return
            }
            identifier = phoneNumber
            identifierType = "phone"
            
            authService.sendOTP(phoneNumber: phoneNumber, countryCode: countryCode)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                } receiveValue: { [weak self] in
                    self?.otpSent = true
                }
                .store(in: &cancellables)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{9,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluate(with: phone)
    }
}

class SignupViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var signupSuccess = false
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: - Validation
    
    var isFormValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        !phoneNumber.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        isValidEmail(email) &&
        isValidPhoneNumber(phoneNumber) &&
        password.count >= 8
    }
    
    // MARK: - Methods
    
    func signup() {
        guard isFormValid else {
            if password != confirmPassword {
                errorMessage = "Passwords do not match"
            } else if password.count < 8 {
                errorMessage = "Password must be at least 8 characters"
            } else {
                errorMessage = "Please fill in all fields correctly"
            }
            return
        }
        
        authService.signup(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            password: password
        )
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] in
            self?.signupSuccess = true
        }
        .store(in: &cancellables)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{9,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluate(with: phone)
    }
}

class OTPViewModel: ObservableObject {
    @Published var otp: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var verificationSuccess = false
    @Published var canResend = true
    @Published var secondsRemaining = 0
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    private var resendTimer: Timer?
    
    let identifier: String
    let identifierType: String
    
    init(authService: AuthService, identifier: String, identifierType: String) {
        self.authService = authService
        self.identifier = identifier
        self.identifierType = identifierType
    }
    
    // MARK: - Validation
    
    var isOTPValid: Bool {
        otp.count == 6 && otp.allSatisfy { $0.isNumber }
    }
    
    // MARK: - Methods
    
    func verifyOTP() {
        guard isOTPValid else {
            errorMessage = "Please enter a valid 6-digit code"
            return
        }
        
        authService.verifyOTP(
            identifier: identifier,
            otp: otp,
            identifierType: identifierType
        )
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] user in
            self?.verificationSuccess = true
        }
        .store(in: &cancellables)
    }
    
    func resendOTP() {
        guard canResend else { return }
        
        canResend = false
        secondsRemaining = 30
        startResendTimer()
        
        if identifierType == "email" {
            authService.sendOTP(email: identifier)
                .sink { _ in } receiveValue: { }
                .store(in: &cancellables)
        } else {
            authService.sendOTP(phoneNumber: identifier)
                .sink { _ in } receiveValue: { }
                .store(in: &cancellables)
        }
    }
    
    private func startResendTimer() {
        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.secondsRemaining -= 1
            if self.secondsRemaining <= 0 {
                self.canResend = true
                self.secondsRemaining = 0
                self.resendTimer?.invalidate()
                self.resendTimer = nil
            }
        }
    }
    
    deinit {
        resendTimer?.invalidate()
    }
}

class DashboardViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    @Published var totalMonthlyCost: Double = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let subscriptionService: SubscriptionService
    private var cancellables = Set<AnyCancellable>()
    
    init(subscriptionService: SubscriptionService) {
        self.subscriptionService = subscriptionService
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        subscriptionService.$subscriptions
            .assign(to: &$subscriptions)
        
        subscriptionService.$isLoading
            .assign(to: &$isLoading)
        
        subscriptionService.$errorMessage
            .assign(to: &$errorMessage)
        
        subscriptionService.$subscriptions
            .map { subscriptions in
                subscriptions.filter { $0.isActive }.reduce(0) { total, sub in
                    let monthlyCost: Double
                    switch sub.billingCycle {
                    case .monthly:
                        monthlyCost = sub.price
                    case .yearly:
                        monthlyCost = sub.price / 12
                    case .quarterly:
                        monthlyCost = sub.price / 3
                    case .weekly:
                        monthlyCost = sub.price * 4.33
                    }
                    return total + monthlyCost
                }
            }
            .assign(to: &$totalMonthlyCost)
    }
    
    // MARK: - Methods
    
    func loadSubscriptions() {
        subscriptionService.fetchSubscriptions()
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func deleteSubscription(id: String) {
        subscriptionService.deleteSubscription(id: id)
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func upcomingPayments() -> [Subscription] {
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        return subscriptions
            .filter { $0.isActive && $0.renewalDate <= nextWeek }
            .sorted { $0.renewalDate < $1.renewalDate }
    }
    
    func subscriptionsByCategory() -> [SubscriptionCategory: [Subscription]] {
        Dictionary(grouping: subscriptions.filter { $0.isActive }, by: { $0.category })
    }
}

class AddSubscriptionViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var selectedCategory: SubscriptionCategory = .streaming
    @Published var selectedBillingCycle: BillingCycle = .monthly
    @Published var price: String = ""
    @Published var renewalDate: Date = Date()
    @Published var notes: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var saveSuccess = false
    
    private let subscriptionService: SubscriptionService
    private var cancellables = Set<AnyCancellable>()
    
    init(subscriptionService: SubscriptionService) {
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - Validation
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !price.isEmpty &&
        Double(price) ?? 0 > 0
    }
    
    // MARK: - Methods
    
    func saveSubscription() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        guard let priceValue = Double(price) else {
            errorMessage = "Please enter a valid price"
            return
        }
        
        let subscription = Subscription(
            id: UUID().uuidString,
            userId: "", // This should come from AuthService
            name: name,
            category: selectedCategory,
            price: priceValue,
            billingCycle: selectedBillingCycle,
            renewalDate: renewalDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        subscriptionService.addSubscription(subscription)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.saveSuccess = true
            }
            .store(in: &cancellables)
    }
}
