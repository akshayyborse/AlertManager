import SwiftUI

struct OTPVerificationView: View {
    @ObservedObject var viewModel: OTPViewModel

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.lg) {
                // Header icon
                Image(systemName: "faceid")
                    .font(.system(size: 56))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.top, AppTheme.Spacing.lg)

                // Title
                Text("Phone Verification")
                    .font(.system(size: AppTheme.FontSizes.xl, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                // Subtitle
                Text("Enter 6 digit verification code sent to your \(viewModel.identifierType == "email" ? "email" : "phone")")
                    .font(.system(size: AppTheme.FontSizes.md))
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)

                // OTP Input
                OTPInputView(otp: $viewModel.otp) {
                    viewModel.verifyOTP()
                }
                .padding(.top, AppTheme.Spacing.lg)

                // Error message
                if let error = viewModel.errorMessage {
                    ErrorMessageView(message: error)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                }

                // Verify button
                PrimaryButton(
                    title: "Verify",
                    action: viewModel.verifyOTP,
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.isOTPValid
                )
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Resend button
                Button(action: viewModel.resendOTP) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("Resend Code")
                            .font(.system(size: AppTheme.FontSizes.md, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.accent)

                        if !viewModel.canResend {
                            Text("(\(viewModel.secondsRemaining)s)")
                                .font(.system(size: AppTheme.FontSizes.sm))
                                .foregroundColor(AppTheme.Colors.textMuted)
                        }
                    }
                }
                .disabled(!viewModel.canResend)
                .opacity(viewModel.canResend ? 1.0 : 0.5)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Success Screen
struct AuthSuccessView: View {
    let message: String
    let userName: String?
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()

                // Success animation circle
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.accent.opacity(0.1))
                        .frame(width: 160, height: 160)

                    Circle()
                        .stroke(AppTheme.Colors.accent, lineWidth: 3)
                        .frame(width: 140, height: 140)

                    Image(systemName: "checkmark")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.accent)
                }
                .padding(.vertical, AppTheme.Spacing.xl)

                // Success message
                Text(message)
                    .font(.system(size: AppTheme.FontSizes.xl, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                if let userName = userName {
                    Text("Welcome aboard, \(userName)! You can now manage your subscriptions.")
                        .font(.system(size: AppTheme.FontSizes.md))
                        .foregroundColor(AppTheme.Colors.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                }

                Spacer()

                // Continue button
                PrimaryButton(
                    title: "Continue to Dashboard",
                    action: onContinue
                )
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    OTPVerificationView(
        viewModel: OTPViewModel(
            authService: AuthService(),
            identifier: "user@example.com",
            identifierType: "email"
        )
    )
}

#Preview {
    AuthSuccessView(
        message: "Verification Successful",
        userName: "John Doe",
        onContinue: {}
    )
}

#Preview {
    OTPVerificationView(
        viewModel: OTPViewModel(
            authService: AuthService(),
            identifier: "+62 81313782626",
            identifierType: "phone"
        )
    )
}
