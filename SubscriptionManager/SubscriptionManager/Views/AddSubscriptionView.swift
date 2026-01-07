import SwiftUI

struct AddSubscriptionSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: AddSubscriptionViewModel

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                HStack {
                    Text("Add Subscription")
                        .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()

                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)

                // Form fields
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Subscription name
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Subscription Name")
                                .font(.system(size: AppTheme.FontSizes.sm, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            CustomTextField(
                                placeholder: "e.g., Netflix",
                                text: $viewModel.name
                            )
                        }

                        // Category
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Category")
                                .font(.system(size: AppTheme.FontSizes.sm, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Picker("Category", selection: $viewModel.selectedCategory) {
                                ForEach(SubscriptionCategory.allCases, id: \.self) { category in
                                    Text(category.displayName).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(AppTheme.Colors.cardSurface)
                            .cornerRadius(AppTheme.CornerRadius.md)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        }

                        // Price
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Price")
                                .font(.system(size: AppTheme.FontSizes.sm, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            CustomTextField(
                                placeholder: "0.00",
                                text: $viewModel.price
                            )
                        }

                        // Billing Cycle
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Billing Cycle")
                                .font(.system(size: AppTheme.FontSizes.sm, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Picker("Billing Cycle", selection: $viewModel.selectedBillingCycle) {
                                ForEach(BillingCycle.allCases, id: \.self) { cycle in
                                    Text(cycle.displayName).tag(cycle)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(AppTheme.Colors.cardSurface)
                            .cornerRadius(AppTheme.CornerRadius.md)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        }

                        // Renewal date
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Renewal Date")
                                .font(.system(size: AppTheme.FontSizes.sm, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            DatePicker(
                                "Select date",
                                selection: $viewModel.renewalDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .tint(AppTheme.Colors.accent)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(AppTheme.Colors.cardSurface)
                            .cornerRadius(AppTheme.CornerRadius.md)
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text("Notes (Optional)")
                                .font(.system(size: AppTheme.FontSizes.sm, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            TextEditor(text: $viewModel.notes)
                                .frame(height: 80)
                                .padding(.horizontal, AppTheme.Spacing.md)
                                .padding(.vertical, AppTheme.Spacing.md)
                                .background(AppTheme.Colors.cardSurface)
                                .cornerRadius(AppTheme.CornerRadius.md)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                        }

                        // Error message
                        if let error = viewModel.errorMessage {
                            ErrorMessageView(message: error)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }

                // Save button
                PrimaryButton(
                    title: "Add Subscription",
                    action: viewModel.saveSubscription,
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.isFormValid
                )
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: viewModel.saveSuccess) { success in
            if success {
                isPresented = false
            }
        }
    }
}

#Preview {
    AddSubscriptionSheet(
        isPresented: .constant(true),
        viewModel: AddSubscriptionViewModel(
            subscriptionService: SubscriptionService(authService: AuthService())
        )
    )
}
