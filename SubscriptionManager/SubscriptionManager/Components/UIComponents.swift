import SwiftUI

// MARK: - Custom Text Field
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let isSecure: Bool
    
    init(
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .font(.system(size: 16))
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppTheme.Colors.textPrimary)
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

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
                    .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(AppTheme.Colors.accent)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .opacity(isEnabled ? 1.0 : 0.5)
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: AppTheme.FontSizes.md, weight: .medium))
                .foregroundColor(AppTheme.Colors.accent)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .stroke(AppTheme.Colors.accent, lineWidth: 1.5)
        )
    }
}

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.Colors.cardSurface)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Error Message View
struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(AppTheme.Colors.error)
                
                Text(message)
                    .font(.system(size: AppTheme.FontSizes.sm))
                    .foregroundColor(AppTheme.Colors.error)
                    .lineLimit(2)
                
                Spacer()
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.error.opacity(0.1))
        .cornerRadius(AppTheme.CornerRadius.md)
    }
}

// MARK: - OTP Input View
struct OTPInputView: View {
    @Binding var otp: String
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            HStack(spacing: AppTheme.Spacing.md) {
                ForEach(0..<6, id: \.self) { index in
                    OTPDigitBox(
                        digit: index < otp.count ? String(otp[otp.index(otp.startIndex, offsetBy: index)]) : "",
                        isFocused: index == otp.count
                    )
                }
            }
            
            TextField("", text: $otp)
                .keyboardType(.numberPad)
                .hidden()
                .onChange(of: otp) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count > 6 {
                        otp = String(filtered.prefix(6))
                    } else {
                        otp = filtered
                    }
                    
                    if otp.count == 6 {
                        onComplete()
                    }
                }
        }
        .onAppear {
            // Focus the hidden text field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // In a real app, you'd use UITextView to focus
            }
        }
    }
}

struct OTPDigitBox: View {
    let digit: String
    let isFocused: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .stroke(isFocused ? AppTheme.Colors.accent : AppTheme.Colors.textMuted, lineWidth: 2)
                .background(AppTheme.Colors.cardSurface.cornerRadius(AppTheme.CornerRadius.md))
            
            Text(digit)
                .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .frame(height: 56)
    }
}

// MARK: - Subscription Card
struct SubscriptionCardView: View {
    let subscription: Subscription
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            CardView {
                HStack(spacing: AppTheme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text(subscription.name)
                            .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text("Due in \(daysUntilRenewal()) days")
                            .font(.system(size: AppTheme.FontSizes.sm))
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                        Text("$\(String(format: "%.2f", subscription.price))")
                            .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.accent)
                        
                        Text(subscription.billingCycle.abbreviation)
                            .font(.system(size: AppTheme.FontSizes.sm))
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                }
            }
        }
    }
    
    private func daysUntilRenewal() -> Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: subscription.renewalDate).day ?? 0
        return max(0, days)
    }
}

// MARK: - Loading Spinner
struct LoadingSpinnerView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .tint(AppTheme.Colors.accent)
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(.system(size: AppTheme.FontSizes.md))
                .foregroundColor(AppTheme.Colors.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientBackground())
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let title: String
    let message: String
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        title: String,
        message: String,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.title = title
        self.message = message
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "inbox")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textMuted)
            
            Text(title)
                .font(.system(size: AppTheme.FontSizes.lg, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(message)
                .font(.system(size: AppTheme.FontSizes.sm))
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
            
            if let action = action, let actionTitle = actionTitle {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.top, AppTheme.Spacing.md)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Tab Toggle
struct TabToggle: View {
    @Binding var selectedTab: LoginViewModel.LoginTab
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = .email }) {
                Text("Email")
                    .font(.system(size: AppTheme.FontSizes.md, weight: .semibold))
                    .foregroundColor(selectedTab == .email ? .white : AppTheme.Colors.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(selectedTab == .email ? AppTheme.Colors.accent : Color.clear)
            }
            
            Button(action: { selectedTab = .phone }) {
                Text("Phone")
                    .font(.system(size: AppTheme.FontSizes.md, weight: .semibold))
                    .foregroundColor(selectedTab == .phone ? .white : AppTheme.Colors.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(selectedTab == .phone ? AppTheme.Colors.accent : Color.clear)
            }
        }
        .background(AppTheme.Colors.cardSurface)
        .cornerRadius(AppTheme.CornerRadius.md)
    }
}
