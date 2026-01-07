import SwiftUI

// This view is no longer used - Auth flow is handled in RootView with NavigationStack
struct AuthChoiceView: View {
    var onLogin: () -> Void
    var onSignUp: () -> Void

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.xl) {
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 56))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.top, AppTheme.Spacing.xl)

                Text("Welcome")
                    .font(.system(size: AppTheme.FontSizes.xxl, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Login to continue or create a new account")
                    .font(.system(size: AppTheme.FontSizes.md))
                    .foregroundColor(AppTheme.Colors.textMuted)

                Spacer()

                VStack(spacing: AppTheme.Spacing.md) {
                    PrimaryButton(title: "Login", action: onLogin)
                    SecondaryButton(title: "Create an Account", action: onSignUp)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AuthChoiceView(onLogin: {}, onSignUp: {})
}
