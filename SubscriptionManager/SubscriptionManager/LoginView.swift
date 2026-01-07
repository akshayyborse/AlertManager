import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    var onNavigateToSignup: () -> Void

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.lg) {
                // Back button
                HStack {
                    // Placeholder for back button - will be handled by navigation
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)

                // Header icon
                Image(systemName: "faceid")
                    .font(.system(size: 56))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.top, AppTheme.Spacing.lg)

                // Title
                Text("Login to Your Account")
                    .font(.system(size: AppTheme.FontSizes.xl, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                // Toggle tabs
                TabToggle(selectedTab: $viewModel.selectedTab)
                    .padding(.horizontal, AppTheme.Spacing.lg)

                // Input fields
                if viewModel.selectedTab == .email {
                    CustomTextField(
                        placeholder: "Email Address",
                        text: $viewModel.email,
                        icon: "envelope"
                    )
                    .padding(.horizontal, AppTheme.Spacing.lg)
                } else {
                    HStack(spacing: AppTheme.Spacing.md) {
                        CustomTextField(
                            placeholder: countryCode,
                            text: $viewModel.countryCode
                        )
                        .frame(maxWidth: 80)

                        CustomTextField(
                            placeholder: "Phone Number",
                            text: $viewModel.phoneNumber,
                            icon: "phone"
                        )
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }

                // Error message
                if let error = viewModel.errorMessage {
                    ErrorMessageView(message: error)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                }

                // Send OTP button
                PrimaryButton(
                    title: "Send OTP",
                    action: viewModel.sendOTP,
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.selectedTab == .email ? !viewModel.email.isEmpty : !viewModel.phoneNumber.isEmpty
                )
                .padding(.horizontal, AppTheme.Spacing.lg)

                Spacer()

                // Sign up link
                HStack(spacing: AppTheme.Spacing.sm) {
                    Text("Don't have an account?")
                        .font(.system(size: AppTheme.FontSizes.md))
                        .foregroundColor(AppTheme.Colors.textMuted)

                    Button(action: onNavigateToSignup) {
                        Text("Sign Up")
                            .font(.system(size: AppTheme.FontSizes.md, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var countryCode: String {
        viewModel.countryCode
    }
}

#Preview {
    LoginView(
        viewModel: LoginViewModel(authService: AuthService()),
        onNavigateToSignup: {}
    )
}
