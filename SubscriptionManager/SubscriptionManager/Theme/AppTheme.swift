import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        static let backgroundTop = Color(red: 0.027, green: 0.027, blue: 0.039) // #07070A
        static let backgroundBottom = Color(red: 0.047, green: 0.047, blue: 0.071) // #0C0C12
        static let cardSurface = Color(red: 0.055, green: 0.059, blue: 0.090) // #0E0F17
        static let accent = Color(red: 0.427, green: 0.388, blue: 1.0) // #6D63FF
        static let textPrimary = Color(red: 0.969, green: 0.973, blue: 0.988) // #F7F8FC
        static let textMuted = Color(red: 0.604, green: 0.627, blue: 0.698) // #9AA0B2
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4) // #33CC66
        static let error = Color(red: 0.92, green: 0.24, blue: 0.20) // #EB3D34
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Font Sizes
    struct FontSizes {
        static let xs: CGFloat = 12
        static let sm: CGFloat = 14
        static let md: CGFloat = 16
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
}

// MARK: - Gradient Background
struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                AppTheme.Colors.backgroundTop,
                AppTheme.Colors.backgroundBottom
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
