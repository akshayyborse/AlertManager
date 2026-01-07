import SwiftUI

struct OnboardingHomeView: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.lg) {
                // Top icon
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 56))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.top, AppTheme.Spacing.xl)

                // Title
                VStack(spacing: AppTheme.Spacing.md) {
                    HStack(spacing: 0) {
                        Text("Manage your ")
                            .font(.system(size: AppTheme.FontSizes.xxl, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text("Subscriptions")
                            .font(.system(size: AppTheme.FontSizes.xxl, weight: .bold))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Seamless subscription management, simplified for your convenience.")
                        .font(.system(size: AppTheme.FontSizes.md))
                        .foregroundColor(AppTheme.Colors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Monthly spent card
                CardView {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "dollarsign")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.accent)

                        Text("XXX.XX")
                            .font(.system(size: AppTheme.FontSizes.xxl, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Text("Amount Spent this month")
                            .font(.system(size: AppTheme.FontSizes.sm))
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Sample subscription card
                CardView {
                    HStack(spacing: AppTheme.Spacing.md) {
                        // Netflix logo placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .fill(Color.red)
                            
                            Text("N")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Netflix")
                                .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Text("Due in 6 days")
                                .font(.system(size: AppTheme.FontSizes.sm))
                                .foregroundColor(AppTheme.Colors.textMuted)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                            Text("$8.44")
                                .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.accent)
                            Text("/Month")
                                .font(.system(size: AppTheme.FontSizes.sm))
                                .foregroundColor(AppTheme.Colors.textMuted)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                Spacer()

                PrimaryButton(title: "Get Started", action: onGetStarted)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.xl)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingHomeView(onGetStarted: {})
}
