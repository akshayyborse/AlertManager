import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var subscriptionService: SubscriptionService
    
    @State private var showOnboarding = true
    
    init() {
        let auth = AuthService()
        _authService = StateObject(wrappedValue: auth)
        _subscriptionService = StateObject(wrappedValue: SubscriptionService(authService: auth))
    }

    var body: some View {
        Group {
            if showOnboarding && !authService.isAuthenticated {
                OnboardingHomeView(onGetStarted: {
                    showOnboarding = false
                })
            } else if !authService.isAuthenticated {
                AuthNavigationStack(authService: authService, onAuthenticated: {
                    showOnboarding = false
                })
            } else {
                MainTabView(authService: authService, subscriptionService: subscriptionService)
            }
        }
    }
}

// MARK: - Auth Navigation
struct AuthNavigationStack: View {
    @ObservedObject var authService: AuthService
    var onAuthenticated: () -> Void
    
    @State private var navigationPath: [AuthScreen] = [.login]
    @State private var loginVM: LoginViewModel
    @State private var signupVM: SignupViewModel
    
    init(authService: AuthService, onAuthenticated: @escaping () -> Void) {
        self.authService = authService
        self.onAuthenticated = onAuthenticated
        _loginVM = State(initialValue: LoginViewModel(authService: authService))
        _signupVM = State(initialValue: SignupViewModel(authService: authService))
    }
    
    enum AuthScreen: Hashable {
        case login
        case signup
        case otp(identifier: String, type: String)
        case success(message: String, userName: String?)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            LoginView(
                viewModel: loginVM,
                onNavigateToSignup: {
                    navigationPath.append(.signup)
                }
            )
            .onChange(of: loginVM.otpSent) { newValue in
                if newValue {
                    navigationPath.append(.otp(identifier: loginVM.identifier, type: loginVM.identifierType))
                }
            }
            .navigationDestination(for: AuthScreen.self) { screen in
                switch screen {
                case .signup:
                    SignUpView(
                        viewModel: signupVM,
                        onNavigateToLogin: {
                            navigationPath.removeLast()
                        }
                    )
                    .onChange(of: signupVM.signupSuccess) { newValue in
                        if newValue {
                            navigationPath.removeAll()
                            navigationPath.append(.login)
                            signupVM.signupSuccess = false
                        }
                    }
                
                case .otp(let identifier, let type):
                    OTPScreenWrapper(
                        authService: authService,
                        identifier: identifier,
                        identifierType: type,
                        navigationPath: $navigationPath
                    )
                
                case .success(let message, let userName):
                    AuthSuccessView(
                        message: message,
                        userName: userName,
                        onContinue: onAuthenticated
                    )
                
                case .login:
                    LoginView(
                        viewModel: loginVM,
                        onNavigateToSignup: {
                            navigationPath.append(.signup)
                        }
                    )
                    .onChange(of: loginVM.otpSent) { newValue in
                        if newValue {
                            navigationPath.append(.otp(identifier: loginVM.identifier, type: loginVM.identifierType))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - OTP Screen Wrapper for Navigation
struct OTPScreenWrapper: View {
    @ObservedObject var authService: AuthService
    let identifier: String
    let identifierType: String
    @Binding var navigationPath: [AuthNavigationStack.AuthScreen]
    
    @StateObject private var viewModel: OTPViewModel
    
    init(authService: AuthService, identifier: String, identifierType: String, navigationPath: Binding<[AuthNavigationStack.AuthScreen]>) {
        self.authService = authService
        self.identifier = identifier
        self.identifierType = identifierType
        self._navigationPath = navigationPath
        _viewModel = StateObject(wrappedValue: OTPViewModel(authService: authService, identifier: identifier, identifierType: identifierType))
    }
    
    var body: some View {
        OTPVerificationView(viewModel: viewModel)
            .onChange(of: viewModel.verificationSuccess) { newValue in
                if newValue {
                    let successMessage = "Verification Successful"
                    let userName = authService.currentUser?.fullName
                    navigationPath.append(.success(message: successMessage, userName: userName))
                }
            }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @ObservedObject var authService: AuthService
    @ObservedObject var subscriptionService: SubscriptionService
    
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            DashboardView(
                viewModel: DashboardViewModel(subscriptionService: subscriptionService)
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            // Analytics tab
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie.fill")
                }
                .tag(1)

            // Settings tab
            SettingsView(authService: authService)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .tint(AppTheme.Colors.accent)
    }
}

// MARK: - Analytics View
struct AnalyticsView: View {
    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.lg) {
                Text("Yearly OTT Spending")
                    .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Spacing.lg)

                CardView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text("Total Spent in 2025:")
                                    .font(.system(size: AppTheme.FontSizes.sm))
                                    .foregroundColor(AppTheme.Colors.textMuted)

                                Text("$325.90")
                                    .font(.system(size: AppTheme.FontSizes.xl, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.accent)
                            }
                            Spacer()
                        }

                        // Simple chart placeholder
                        GeometryReader { _ in
                            Canvas { context, size in
                                let width = size.width
                                let height = size.height

                                // Draw grid lines
                                let step = max(1, Int(height / 4))
                                for i in stride(from: 0, to: Int(height), by: step) {
                                    var path = Path()
                                    path.move(to: CGPoint(x: 0, y: CGFloat(i)))
                                    path.addLine(to: CGPoint(x: width, y: CGFloat(i)))
                                    context.stroke(path, with: .color(AppTheme.Colors.textMuted.opacity(0.1)))
                                }
                            }
                        }
                        .frame(height: 150)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                Spacer()
            }
            .padding(.vertical, AppTheme.Spacing.lg)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.lg) {
                Text("Settings")
                    .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Spacing.lg)

                // Profile section
                CardView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            Circle()
                                .fill(AppTheme.Colors.accent)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Text("Z")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                )

                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text(authService.currentUser?.fullName ?? "User")
                                    .font(.system(size: AppTheme.FontSizes.md, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textPrimary)

                                Text(authService.currentUser?.email ?? "user@example.com")
                                    .font(.system(size: AppTheme.FontSizes.sm))
                                    .foregroundColor(AppTheme.Colors.textMuted)
                            }

                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Settings options
                VStack(spacing: AppTheme.Spacing.md) {
                    SettingRow(icon: "bell", title: "Notifications", subtitle: "Manage alerts")
                    SettingRow(icon: "lock", title: "Privacy", subtitle: "Security settings")
                    SettingRow(icon: "icloud", title: "Backup", subtitle: "iCloud sync")
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                Spacer()

                // Logout button
                PrimaryButton(
                    title: "Logout",
                    action: {
                        authService.logout()
                    }
                )
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
            }
            .padding(.vertical, AppTheme.Spacing.lg)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Setting Row
struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        CardView {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.accent)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(title)
                        .font(.system(size: AppTheme.FontSizes.md, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(subtitle)
                        .font(.system(size: AppTheme.FontSizes.sm))
                        .foregroundColor(AppTheme.Colors.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
        }
    }
}

#Preview {
    RootView()
}
