import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var showAddSubscription = false

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Good morning")
                            .font(.system(size: AppTheme.FontSizes.md))
                            .foregroundColor(AppTheme.Colors.textMuted)

                        Text("Welcome back!")
                            .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }

                    Spacer()

                    Image(systemName: "gear")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)

                // Spending card
                CardView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text("Monthly Spending")
                                    .font(.system(size: AppTheme.FontSizes.sm))
                                    .foregroundColor(AppTheme.Colors.textMuted)

                                Text("$\(String(format: "%.2f", viewModel.totalMonthlyCost))")
                                    .font(.system(size: AppTheme.FontSizes.xl, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }

                            Spacer()

                            Image(systemName: "dollarsign.circle")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.Colors.accent)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Upcoming payments
                if !viewModel.upcomingPayments().isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("Upcoming Payments")
                            .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .padding(.horizontal, AppTheme.Spacing.lg)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.md) {
                                ForEach(viewModel.upcomingPayments().prefix(3), id: \.id) { sub in
                                    UpcomingPaymentCard(subscription: sub)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        }
                    }
                }

                // Subscriptions list
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("My Subscriptions")
                        .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.horizontal, AppTheme.Spacing.lg)

                    if viewModel.subscriptions.isEmpty {
                        EmptyStateView(
                            title: "No Subscriptions Yet",
                            message: "Add your first subscription to get started",
                            action: { showAddSubscription = true },
                            actionTitle: "Add Subscription"
                        )
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: AppTheme.Spacing.md) {
                                ForEach(viewModel.subscriptions.filter { $0.isActive }, id: \.id) { sub in
                                    SubscriptionCardView(
                                        subscription: sub,
                                        onTap: {}
                                    )
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        }
                    }
                }

                Spacer()
            }

            // FAB - Add subscription button
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Button(action: { showAddSubscription = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(AppTheme.Colors.accent))
                            .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 10, x: 0, y: 4)
                    }
                    .padding(AppTheme.Spacing.xl)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.loadSubscriptions()
        }
        .sheet(isPresented: $showAddSubscription) {
            AddSubscriptionSheet(isPresented: $showAddSubscription, viewModel: AddSubscriptionViewModel(subscriptionService: SubscriptionService(authService: AuthService())))
        }
    }
}

// MARK: - Upcoming Payment Card
struct UpcomingPaymentCard: View {
    let subscription: Subscription

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(subscription.name)
                    .font(.system(size: AppTheme.FontSizes.md, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Due in \(daysUntilRenewal()) days")
                    .font(.system(size: AppTheme.FontSizes.sm))
                    .foregroundColor(AppTheme.Colors.textMuted)

                Spacer()
                    .frame(height: AppTheme.Spacing.md)

                Text("$\(String(format: "%.2f", subscription.price))")
                    .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.accent)
            }
        }
        .frame(width: 160)
    }

    private func daysUntilRenewal() -> Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: subscription.renewalDate).day ?? 0
        return max(0, days)
    }
}

#Preview {
    DashboardView(
        viewModel: DashboardViewModel(
            subscriptionService: SubscriptionService(authService: AuthService())
        )
    )
}
