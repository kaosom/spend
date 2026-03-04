# Avid Spend - Intelligent Expense Tracker

Avid Spend is a modern, dark-mode expense tracking app for iOS built with Flutter. It features encrypted local storage, intelligent spend prediction, recurring transactions, and beautiful grid/heatmap visualizations.

## 🚀 Features

### Core Functionality
- **Multi-Account Support**: Track expenses across different accounts (cash, debit, credit)
- **Income & Expense Tracking**: Full transaction management with categories
- **Recurring Transactions**: Support for weekly, bi-weekly, and custom recurring patterns
- **Obligatory Payments**: Mark transactions as required obligations
- **Spend Prediction**: Intelligent analysis of upcoming expenses and balance projections

### Visualizations
- **Monthly Calendar Grid**: Week starts on Sunday, shows daily totals
- **GitHub-Style Heatmap**: Daily expense intensity visualization
- **Real-time Updates**: Immediate UI updates when switching accounts

### Security & Storage
- **Encrypted Storage**: AES-GCM encryption with iOS Keychain key storage
- **Versioned Schema**: Safe data migrations and corruption recovery
- **Secure Local Storage**: No cloud dependency, all data stays on device

### Design
- **Dark Mode Only**: Minimalist, futuristic design with subtle gradients
- **Atomic Design**: Modular component architecture
- **Google Fonts**: Clean, modern typography
- **Micro-glow Effects**: Subtle accent lighting for interactions

## 🏗️ Architecture

### Project Structure (Atomic Design)
```
lib/
├── app/                          # Application layer
│   ├── avid_app.dart            # Main app widget
│   ├── routes.dart              # Route definitions
│   └── theme/                   # Design system
│       ├── tokens.dart          # Design tokens
│       ├── avid_theme.dart      # Theme configuration
│       └── typography.dart      # Typography utilities
├── core/                        # Core utilities & services
│   ├── constants/               # App constants
│   ├── errors/                  # Error handling
│   ├── result.dart              # Result type utilities
│   ├── utils/                   # Utility functions
│   │   ├── dates.dart          # Date utilities
│   │   ├── currency.dart       # Currency formatting
│   │   └── debounce.dart       # Debouncing utilities
│   └── security/                # Security services
│       ├── crypto_service.dart  # Encryption/decryption
│       └── keychain_service.dart # iOS Keychain integration
│   └── storage/                 # Storage layer
│       ├── storage_service.dart # Encrypted storage
│       └── migrations.dart     # Database migrations
├── design_system/               # Atomic Design components
│   ├── particles/              # Basic tokens & atoms
│   ├── atoms/                  # Basic UI components
│   ├── molecules/              # Composite components
│   ├── organisms/              # Complex UI sections
│   └── templates/              # Page templates
├── features/                    # Feature modules
│   ├── accounts/               # Account management
│   │   └── accounts_controller.dart
│   ├── categories/             # Category management
│   ├── transactions/           # Transaction CRUD
│   │   └── transactions_controller.dart
│   ├── tracking/               # Grid/Heatmap views
│   │   └── tracking_controller.dart
│   ├── settings/               # App settings
│   │   └── settings_controller.dart
│   ├── prediction/             # Spend prediction
│   │   └── prediction_controller.dart
│   └── shell/                  # App shell & navigation
│       └── home_screen.dart
├── models/                     # Data models
│   ├── account.dart            # Account model
│   ├── category.dart           # Category model
│   ├── transaction.dart        # Transaction model
│   ├── recurrence_rule.dart    # Recurrence rules
│   ├── planned_spend.dart      # Planned spend model
│   ├── settings.dart           # Settings model
│   └── models.dart             # Export barrel
└── main.dart                   # App entry point
```

### State Management
- **GetX**: Reactive state management throughout the app
- **Controllers**: Feature-specific controllers with error handling
- **Reactive UI**: Automatic UI updates on state changes

### Data Flow
```
User Action → Controller → Business Logic → Storage Service → Encrypted Persistence
                                      ↓
UI Updates ← Reactive Observables ← Controller State
```

## 🔐 Security Design

### Encryption Architecture
- **Algorithm**: AES-GCM (Authenticated Encryption)
- **Key Storage**: iOS Keychain with biometric protection
- **Nonce**: 12-byte random nonce per encryption operation
- **Storage**: SQLite database with encrypted JSON blobs

### Key Management
```dart
// Key generation and storage flow
1. Generate random 256-bit key on first launch
2. Store key in iOS Keychain with accessibility restrictions
3. Use key for AES-GCM encryption of all data
4. Automatic key retrieval on app startup
```

### Data Protection
- **At Rest**: All data encrypted before SQLite storage
- **In Transit**: No network communication (local-only app)
- **Key Protection**: iOS Keychain with device-specific restrictions

## 🧪 Testing Strategy

### Unit Tests
```bash
flutter test
```

#### Test Coverage Areas
- **Date Utilities**: Date key generation, month calculations, week boundaries
- **Currency Utils**: Formatting, validation, calculations
- **Grid Generation**: Calendar layout, cell calculations
- **Heatmap Logic**: Intensity calculations, date ranges
- **Recurrence Expansion**: Occurrence generation, edge cases
- **Spend Prediction**: Balance calculations, conflict detection
- **Storage**: Encryption roundtrip, corruption recovery

### Test Structure
```
test/
├── unit/
│   ├── core/
│   ├── models/
│   └── features/
└── integration/
    └── storage_test.dart
```

## 🚀 iOS Setup & Running

### Prerequisites
- **Flutter**: `>=3.10.4`
- **iOS**: `>=12.0`
- **Xcode**: `>=14.0`
- **CocoaPods**: Latest version

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd avid_spend

# Install dependencies
flutter pub get

# Install iOS pods
cd ios && pod install && cd ..
```

### Running on iOS
```bash
# Run on connected iOS device/simulator
flutter run --platform ios

# Or specify a device
flutter run --device-id <device-id>
```

### Build for Release
```bash
# Build for iOS
flutter build ios --release

# Archive with Xcode
# Open ios/Runner.xcworkspace in Xcode
# Product → Archive
```

## 🛠️ Development

### Code Style
- **Analysis**: `flutter analyze`
- **Formatting**: `dart format .`
- **Linting**: Follows Flutter's recommended lints

### Dependencies
```yaml
dependencies:
  get: ^4.6.6                    # State management
  google_fonts: ^6.2.1           # Typography
  sqflite: ^2.3.3+1              # Local database
  flutter_secure_storage: ^9.2.2 # iOS Keychain
  encrypt: ^5.0.3                # Encryption
  intl: ^0.19.0                  # Internationalization
  # ... see pubspec.yaml for full list
```

### Key Decisions
- **Platform**: iOS-only for focused security implementation
- **State**: GetX for reactive, testable state management
- **Storage**: Encrypted SQLite over JSON for performance
- **Design**: Atomic Design for maintainable component architecture
- **Security**: AES-GCM with Keychain for production-ready encryption

## 📊 Features Deep Dive

### Spend Prediction Algorithm
```dart
// Prediction logic overview
1. Calculate current account balance from all transactions
2. Identify upcoming transactions (one-time + recurring)
3. Factor in existing planned spends
4. Project balance at target date
5. Compare against safety buffer
6. Identify conflicts (obligatory payments)
7. Return safe/not-safe recommendation with details
```

### Grid View Implementation
```dart
// Grid generation
1. Calculate month boundaries with leading/trailing weeks
2. Generate 6-week grid (42 cells) covering full month
3. Calculate daily totals for each cell
4. Apply disabled state for future dates (configurable)
5. Mark current day and obligatory transactions
```

### Heatmap Intensity
```dart
// Intensity calculation
1. Find maximum daily expense in selected range
2. Calculate intensity as (daily_expense / max_expense)
3. Bucket into 5 intensity levels
4. Apply GitHub-style color coding
5. Handle zero-expense days appropriately
```

## 🔄 Data Schema

### Versioned Storage
- **Current Version**: `avid_spend_v1_encrypted`
- **Migration Support**: Automatic schema upgrades
- **Corruption Recovery**: Attempt repair, fallback to defaults

### Core Entities
```dart
// Key relationships
Account (1) ←→ (*) Transaction
Category (1) ←→ (*) Transaction
Transaction (*) → (1) RecurrenceRule
Transaction (*) → (1) PlannedSpend
```

## 📈 Performance Optimizations

### UI Performance
- **Narrow Obx scopes**: Only rebuild necessary widgets
- **Memoized calculations**: Cache expensive grid/heatmap computations
- **Debounced saves**: 100-250ms delay prevents excessive I/O

### Memory Management
- **Efficient queries**: Targeted database queries
- **Lazy loading**: Load data only when needed
- **Controller lifecycle**: Proper cleanup on dispose

## 🚨 Error Handling

### Error Types
- `StorageReadError`: Database/file read failures
- `StorageWriteError`: Save operation failures
- `EncryptionError`: Crypto operation failures
- `KeychainError`: iOS Keychain access issues
- `ValidationError`: Input validation failures
- `NotFoundError`: Missing entity lookups

### Recovery Strategies
- **Storage corruption**: Attempt migration, fallback to defaults
- **Keychain issues**: Regenerate keys, show user warning
- **Validation errors**: Inline feedback, prevent invalid operations

## 🎯 Future Enhancements

### Planned Features
- **Transfers**: Between-account money movement
- **Budgets**: Spending limits and tracking
- **Reports**: Advanced analytics and insights
- **Categories**: Custom user-defined categories
- **Export**: Data export functionality

### Technical Improvements
- **Cloud Backup**: Optional encrypted cloud sync
- **Biometrics**: Enhanced security options
- **Widgets**: iOS home screen widgets
- **Notifications**: Spending alerts and reminders

---

Built with ❤️ using Flutter for iOS