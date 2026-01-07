# Subscription Manager - iOS App

A production-ready iOS application built with SwiftUI for managing subscriptions and tracking spending across multiple platforms.

## Features

✅ **Authentication**
- Email & Phone OTP-based login
- User registration with validation
- Secure token management

✅ **Subscription Management**
- Add, edit, and delete subscriptions
- Track renewal dates
- Categorize subscriptions (Streaming, Music, Gaming, etc.)
- Multiple billing cycles (Monthly, Yearly, Quarterly, Weekly)

✅ **Dashboard**
- Monthly spending overview
- Upcoming payments widget
- Subscription list with renewal status
- Spending analytics and charts

✅ **Design System**
- Dark theme with gradient backgrounds
- Custom UI components
- Consistent color palette and typography
- Smooth animations and transitions

## Architecture

**MVVM (Model-View-ViewModel)**
- Models: User, Subscription, AuthResponse
- ViewModels: LoginViewModel, SignupViewModel, OTPViewModel, DashboardViewModel, AddSubscriptionViewModel
- Services: AuthService, SubscriptionService
- Components: Reusable UI components with consistent styling

**Key Technologies**
- SwiftUI for UI framework
- Combine for reactive bindings
- NavigationStack for routing
- CoreData for local persistence
- URLSession for API communication

## Project Structure

```
SubscriptionManager/
├── Models/
│   └── AppModels.swift
├── Services/
│   ├── AuthService.swift
│   ├── SubscriptionService.swift
│   └── PersistenceController.swift
├── ViewModels/
│   └── AppViewModels.swift
├── Components/
│   └── UIComponents.swift
├── Theme/
│   └── AppTheme.swift
├── Views/
│   ├── DashboardView.swift
│   ├── AddSubscriptionView.swift
│   └── (other view files)
├── RootView.swift
├── ContentView.swift
└── SubscriptionManagerApp.swift
```

## Design System

### Colors
- **Background Top**: #07070A
- **Background Bottom**: #0C0C12
- **Card Surface**: #0E0F17
- **Accent / Primary**: #6D63FF
- **Text Primary**: #F7F8FC
- **Text Muted**: #9AA0B2

### Spacing
- XS: 4px
- SM: 8px
- MD: 12px
- LG: 16px
- XL: 24px
- XXL: 32px

### Corner Radius
- SM: 8px
- MD: 12px
- LG: 16px
- XL: 20px

## App Flow

### 1. Onboarding Screen
- Welcome screen with app introduction
- Monthly spending preview
- Sample subscription display
- "Get Started" button

### 2. Authentication Flow
- **Login**: Email or Phone OTP
- **Signup**: Full details + password
- **OTP Verification**: 6-digit code entry with auto-complete
- **Success**: Account created confirmation

### 3. Dashboard
- Monthly spending card
- Upcoming payments section
- Subscriptions list
- Floating Action Button (FAB) to add new subscription

### 4. Add Subscription
- Name, Category, Price, Billing Cycle
- Renewal date picker
- Optional notes
- Form validation

### 5. Analytics
- Yearly spending trends
- Spending by platform
- Charts and visualizations

### 6. Settings
- User profile
- Notification preferences
- Backup/Restore options
- Logout

## Setup Instructions

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+

### Installation

1. **Open the project**
   ```bash
   open /path/to/SubscriptionManager.xcodeproj
   ```

2. **Build the project**
   - Select target device or simulator
   - Press Cmd+B to build
   - Press Cmd+R to run

3. **Configure Backend** (Optional)
   - Update `AuthService` base URL to your backend
   - Implement authentication endpoints:
     - `POST /auth/send-otp`
     - `POST /auth/verify-otp`
     - `POST /auth/signup`

4. **API Endpoints Expected**
   ```
   POST /auth/send-otp
   {
     "email": "user@example.com",
     "phone_number": "1234567890",
     "country_code": "+62"
   }
   
   POST /auth/verify-otp
   {
     "identifier": "user@example.com",
     "otp": "123456",
     "identifier_type": "email"
   }
   
   GET /subscriptions
   POST /subscriptions
   PUT /subscriptions/{id}
   DELETE /subscriptions/{id}
   ```

## UI Components

### CustomTextField
```swift
CustomTextField(
    placeholder: "Email",
    text: $email,
    icon: "envelope"
)
```

### PrimaryButton
```swift
PrimaryButton(
    title: "Submit",
    action: { /* action */ },
    isLoading: isLoading,
    isEnabled: true
)
```

### CardView
```swift
CardView {
    VStack {
        Text("Content")
    }
}
```

### OTPInputView
```swift
OTPInputView(otp: $otp) {
    // On complete
}
```

### SubscriptionCardView
```swift
SubscriptionCardView(
    subscription: subscription,
    onTap: { /* handle tap */ }
)
```

## State Management

- **AuthService**: Manages authentication state, tokens, and user data
- **SubscriptionService**: Manages subscription list and operations
- **ViewModels**: Handle UI state, validation, and business logic
- **@AppStorage**: Persist simple settings locally

## Error Handling

- Network errors with user-friendly messages
- Input validation with real-time feedback
- API error parsing and display
- Graceful degradation for offline scenarios

## Security Features

- JWT token-based authentication
- Secure token storage in UserDefaults (production should use Keychain)
- Input validation and sanitization
- HTTPS-only API communication
- Sensitive data handling

## Testing

The app includes:
- Model validation tests
- ViewModel logic tests
- Component preview tests
- Integration tests for API communication

## Performance Optimizations

- Lazy loading of subscriptions
- Efficient state updates with Combine
- Reusable components to minimize memory
- Optimized list rendering with ForEach IDs

## Future Enhancements

- [ ] Push notifications for upcoming payments
- [ ] Advanced analytics with charts (using Charts library)
- [ ] Export reports (PDF, CSV)
- [ ] Multi-currency support
- [ ] Dark/Light theme toggle
- [ ] Offline mode with sync
- [ ] Watch app companion
- [ ] Siri shortcuts integration
- [ ] Family sharing
- [ ] Budget alerts and reminders

## Troubleshooting

### App doesn't compile
- Ensure Xcode is latest version
- Clean build folder (Cmd+Shift+K)
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`

### Network errors
- Check backend server is running
- Verify API endpoints in AuthService
- Check network connectivity

### Navigation issues
- Ensure NavigationStack is properly configured
- Check that all views conform to Hashable for destinations

## Contributing

1. Follow MVVM architecture
2. Use existing UI components for consistency
3. Add proper error handling
4. Test before committing
5. Update README if adding features

## License

MIT License - Free to use and modify

## Support

For issues or questions:
- Check the README
- Review the code comments
- Test with latest Xcode version
- Report issues with detailed reproduction steps

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Platform**: iOS 16.0+
