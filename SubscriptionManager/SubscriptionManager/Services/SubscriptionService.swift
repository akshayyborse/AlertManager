import Foundation
import Combine

class SubscriptionService: NSObject, ObservableObject {
    @Published var subscriptions: [Subscription] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let baseURL = "https://api.subscriptionmanager.com"
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
        super.init()
    }
    
    // MARK: - Subscription Methods
    
    /// Fetch all subscriptions for current user
    func fetchSubscriptions() -> AnyPublisher<[Subscription], Error> {
        isLoading = true
        errorMessage = nil
        
        guard let token = authService.authToken else {
            let error = NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No auth token available"])
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: baseURL + "/subscriptions") else {
            return Fail(error: NSError(domain: "InvalidURL", code: -1))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "InvalidResponse", code: -1)
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode)
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let response = try decoder.decode([String: [Subscription]].self, from: data)
                return response["data"] ?? []
            }
            .handleEvents(
                receiveOutput: { [weak self] subscriptions in
                    self?.subscriptions = subscriptions
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /// Add new subscription
    func addSubscription(_ subscription: Subscription) -> AnyPublisher<Subscription, Error> {
        isLoading = true
        errorMessage = nil
        
        guard let token = authService.authToken else {
            let error = NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No auth token available"])
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: baseURL + "/subscriptions") else {
            return Fail(error: NSError(domain: "InvalidURL", code: -1))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try? encoder.encode(subscription)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "InvalidResponse", code: -1)
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode)
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let response = try decoder.decode([String: Subscription].self, from: data)
                return response["data"] ?? subscription
            }
            .handleEvents(
                receiveOutput: { [weak self] newSubscription in
                    self?.subscriptions.append(newSubscription)
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /// Update subscription
    func updateSubscription(_ subscription: Subscription) -> AnyPublisher<Subscription, Error> {
        isLoading = true
        errorMessage = nil
        
        guard let token = authService.authToken else {
            let error = NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No auth token available"])
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: baseURL + "/subscriptions/\(subscription.id)") else {
            return Fail(error: NSError(domain: "InvalidURL", code: -1))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try? encoder.encode(subscription)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "InvalidResponse", code: -1)
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode)
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let response = try decoder.decode([String: Subscription].self, from: data)
                return response["data"] ?? subscription
            }
            .handleEvents(
                receiveOutput: { [weak self] updatedSubscription in
                    if let index = self?.subscriptions.firstIndex(where: { $0.id == updatedSubscription.id }) {
                        self?.subscriptions[index] = updatedSubscription
                    }
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /// Delete subscription
    func deleteSubscription(id: String) -> AnyPublisher<Void, Error> {
        isLoading = true
        errorMessage = nil
        
        guard let token = authService.authToken else {
            let error = NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No auth token available"])
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: baseURL + "/subscriptions/\(id)") else {
            return Fail(error: NSError(domain: "InvalidURL", code: -1))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "InvalidResponse", code: -1)
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "HTTPError", code: httpResponse.statusCode)
                }
            }
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.subscriptions.removeAll { $0.id == id }
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    /// Calculate total monthly spending
    var totalMonthlyCost: Double {
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
    
    /// Get subscriptions grouped by category
    var subscriptionsByCategory: [SubscriptionCategory: [Subscription]] {
        Dictionary(grouping: subscriptions.filter { $0.isActive }, by: { $0.category })
    }
}
