import Foundation
import Combine

class AuthService: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authToken: String?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let baseURL = "https://api.subscriptionmanager.com"
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        loadAuthState()
    }
    
    // MARK: - Authentication Methods
    
    /// Send OTP to email or phone
    func sendOTP(
        email: String? = nil,
        phoneNumber: String? = nil,
        countryCode: String = "+62"
    ) -> AnyPublisher<Void, Error> {
        isLoading = true
        errorMessage = nil
        
        let request = AuthRequest(
            email: email,
            phoneNumber: phoneNumber,
            countryCode: countryCode
        )
        
        return sendRequestNoResponse(endpoint: "/auth/send-otp", body: request)
            .handleEvents(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Verify OTP code
    func verifyOTP(identifier: String, otp: String, identifierType: String) -> AnyPublisher<User, Error> {
        isLoading = true
        errorMessage = nil
        
        let request = OTPVerifyRequest(
            identifier: identifier,
            otp: otp,
            identifierType: identifierType
        )
        
        return sendRequest(endpoint: "/auth/verify-otp", body: request)
            .tryMap { (response: OTPResponse) -> User in
                if !response.success {
                    throw NSError(domain: "OTPVerificationError", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message])
                }
                
                if let token = response.data?.token {
                    self.authToken = token
                    self.saveAuthToken(token)
                }
                
                if let user = response.data?.user {
                    self.currentUser = user
                    self.isAuthenticated = true
                    return user
                }
                
                throw NSError(domain: "OTPVerificationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user data returned"])
            }
            .handleEvents(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Sign up with credentials
    func signup(
        fullName: String,
        email: String,
        phoneNumber: String,
        password: String
    ) -> AnyPublisher<Void, Error> {
        isLoading = true
        errorMessage = nil
        
        let request = SignupRequest(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            password: password
        )
        
        return sendRequestNoResponse(endpoint: "/auth/signup", body: request)
            .handleEvents(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Logout
    func logout() {
        isAuthenticated = false
        currentUser = nil
        authToken = nil
        clearAuthToken()
    }
    
    // MARK: - Private Methods
    
    private func sendRequest<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T
    ) -> AnyPublisher<R, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: NSError(domain: "InvalidURL", code: -1))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "InvalidResponse", code: -1)
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] ?? "Request failed"
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage ?? "Request failed"])
                }
                
                return try JSONDecoder().decode(R.self, from: data)
            }
            .eraseToAnyPublisher()
    }

    // Variant for endpoints that return no body (204/empty) and should map to Void
    private func sendRequestNoResponse<T: Encodable>(
        endpoint: String,
        body: T
    ) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: NSError(domain: "InvalidURL", code: -1))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONEncoder().encode(body)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "InvalidResponse", code: -1)
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] ?? "Request failed"
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage ?? "Request failed"])
                }

                return ()
            }
            .eraseToAnyPublisher()
    }
    
    private func loadAuthState() {
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            authToken = token
            isAuthenticated = true
        }
    }
    
    private func saveAuthToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    private func clearAuthToken() {
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}
