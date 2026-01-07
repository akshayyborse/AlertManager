import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignupViewModel
    var onNavigateToLogin: () -> Void

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.lg) {
                // Header icon
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.top, AppTheme.Spacing.lg)

                // Title
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("Create an")
                        .font(.system(size: AppTheme.FontSizes.xl, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    HStack(spacing: 0) {
                        Text("Account")
                            .font(.system(size: AppTheme.FontSizes.xl, weight: .bold))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Input fields
                VStack(spacing: AppTheme.Spacing.md) {
                    CustomTextField(
                        placeholder: "Full Name",
                        text: $viewModel.fullName,
                        icon: "person"
                    )

                    CustomTextField(
                        placeholder: "Email Address",
                        text: $viewModel.email,
                        icon: "envelope"
                    )

                    CustomTextField(
                        placeholder: "Mobile Number",
                        text: $viewModel.phoneNumber,
                        icon: "phone"
                    )

                    PasswordTextField(
                        placeholder: "Password",
                        text: $viewModel.password
                    )

                    PasswordTextField(
                        placeholder: "Confirm Password",
                        text: $viewModel.confirmPassword
                    )
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Error message
                if let error = viewModel.errorMessage {
                    ErrorMessageView(message: error)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                }

                // Sign Up button
                PrimaryButton(
                    title: "Sign Up",
                    action: viewModel.signup,
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.isFormValid
                )
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Divider
                HStack(spacing: AppTheme.Spacing.md) {
                    Rectangle()
                        .fill(AppTheme.Colors.textMuted.opacity(0.3))
                        .frame(height: 1)

                    Text("Or continue with")
                        .font(.system(size: AppTheme.FontSizes.sm))
                        .foregroundColor(AppTheme.Colors.textMuted)

                    Rectangle()
                        .fill(AppTheme.Colors.textMuted.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Social buttons
                HStack(spacing: AppTheme.Spacing.md) {
                    SocialAuthButton(title: "Google", icon: "globe")
                    SocialAuthButton(title: "Apple", icon: "apple.logo")
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                Spacer()

                // Login link
                HStack(spacing: AppTheme.Spacing.sm) {
                    Text("Already have an account?")
                        .font(.system(size: AppTheme.FontSizes.md))
                        .foregroundColor(AppTheme.Colors.textMuted)

                    Button(action: onNavigateToLogin) {
                        Text("Login")
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
}

// MARK: - Password TextField
struct PasswordTextField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure = true

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "lock")
                .foregroundColor(AppTheme.Colors.textMuted)
                .font(.system(size: 16))

            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }

            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardSurface)
        .cornerRadius(AppTheme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .stroke(AppTheme.Colors.accent, lineWidth: 1.5)
        )
    }
}

// MARK: - Social Auth Button
struct SocialAuthButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button(action: {}) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))

                Text(title)
                    .font(.system(size: AppTheme.FontSizes.md, weight: .semibold))
            }
            .foregroundColor(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardSurface)
            .cornerRadius(AppTheme.CornerRadius.md)
        }
    }
}

#Preview {
    SignUpView(
        viewModel: SignupViewModel(authService: AuthService()),
        onNavigateToLogin: {}
    )
}
