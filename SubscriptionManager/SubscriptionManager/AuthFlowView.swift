import SwiftUI

// This view is no longer used - Auth flow is now handled in RootView with NavigationStack
struct AuthFlowView: View {
    enum Step { case choose, login, signup, otp, success }

    @State private var step: Step
    var onAuthenticated: () -> Void

    init(initialStep: Step = .choose, onAuthenticated: @escaping () -> Void) {
        self._step = State(initialValue: initialStep)
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        ZStack {
            GradientBackground()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AuthFlowView(onAuthenticated: {})
}
