# Bepay Crypto Transfer Application

A Clean Architecture-compliant Flutter mobile application designed for crypto transfers. The project integrates custom amount validation, biometric confirmation, dynamic network fee estimation, a custom numeric keypad, automated lockout mechanisms, and simulated transaction result flows.

---

## 📋 Submission Details

*   **Flutter SDK Version**: `3.41.0`
*   **Dart SDK Version**: `>=3.0.0 <4.0.0`
*   **Platform Support**: Android, iOS
*   **Code Quality**: `flutter analyze` passes with **0 warnings**
*   **Test Suite**: **51 tests passing** (unit, widget, and E2E integration tests)

---

## 🛠️ Setup & Running

### Prerequisites
- **Flutter SDK**: `3.41.0` or compatible stable version.
- **Dart SDK**: `>=3.0.0 <4.0.0`

### Installation & Execution Steps

1. **Clone the repository and fetch dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate Dependency Injection Bindings:**
   The project uses `injectable` and `build_runner` for dependency injection configuration:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run the Test Suite:**
   Run all unit, widget, and E2E integration tests:
   ```bash
   flutter test
   ```

4. **Launch the Application:**
   Run the app on your connected device/simulator:
   ```bash
   flutter run
   ```

---

## 🚀 Features & Completed Capabilities

### 1. Wallet Home Feed
*   **Universal Currency Conversion**: Displays wallet balance dynamically in selected fiat currencies (**USD, INR, GBP, EUR**). Uses a centralized currency manager to sync currency preferences across the entire app.
*   **Assets & History Feed**: List of active crypto assets (USDC, SOL, ETH) with balance details, and a chronologically sorted, non-duplicated recent transaction history.

### 2. Recipient Entry
*   **Real-time Address Validation**: Auto-detects input query format:
    *   **Verified BepayID** (e.g. `user@bepay`)
    *   **Solana/EVM Wallet Address** (e.g. `0x742D...`)
    *   **Email Address** (e.g. `john@example.com`)
    *   **Phone Number** (e.g. `+919876543210`)
*   **Safety Warning Cards**: Renders an alert badge highlighting the risks when transferring funds to an external wallet address versus an internal Bepay ID.
*   **QR Scanner Simulator**: A fully functional mock QR scanning screen featuring viewfinder scan animations, manual hash input, and quick-simulator buttons (Wallet Address, Bepay ID, Solana Hash).

### 3. Amount Entry & Custom Keypad
*   **In-App Numeric Keypad (`BepayKeypad`)**: Blocks native OS keyboards to prevent input collisions and guarantee a uniform UX. Handles digit presses, decimals, backspaces, and biometric auth shortcuts.
*   **Token-Specific Precision Constraints**: Enforces decimal precision bounds at the keypad layer:
    *   **USDC**: Maximum **2** decimal places.
    *   **SOL**: Maximum **6** decimal places.
    *   **ETH**: Maximum **8** decimal places.
*   **Balance Validation**: Disables the continuation button and displays an error message if the input exceeds the available balance or is equal to zero.

### 4. Transaction Review
*   **Deduction Summary**: Shows a complete breakdown of transfer amount, coin-specific network fees, memo, and total deduction.
*   **Go-Back Editing**: Allows users to step back to edit amount or recipient details seamlessly.

### 5. PIN Confirmation & Security
*   **Randomized Keypad Layout**: Randomly shuffles numeric key grids on every display to defend against shoulder surfing.
*   **3-Strike Lockout Cooldown**: Entering the incorrect PIN 3 times triggers a 30-second lockout timer. The lockout timer persists in `SharedPreferences` across app restarts.
*   **Biometrics Authorization**: Displays mock biometric prompt options (Face ID/Fingerprint) with full cancellation and hardware fallback support.

### 6. Transaction Result
*   **Dynamic Submission Simulation**: Renders distinct screens based on outcomes:
    *   **Success**: Green checkmark, success header, and balance deduction.
    *   **Pending**: Orange/amber clock, pending header, and balance deduction.
    *   **Failed**: Red cross, failed header, and **no balance deduction**.
*   **Deterministic Simulation Testing**:
    *   Amounts ending in `.88` (e.g. `50.88`) result in **Pending**.
    *   Amounts ending in `.99` (e.g. `50.99`) result in **Failed**.
    *   Other amounts default to a randomized mock API response (75% Success, 15% Pending, 10% Failed).
*   **Details Bottom Sheet**: Sliding panel with a breakdown of transaction hashes, network status, timestamps, and fees.

---

## 🏗️ Architecture Overview

The app is built on **Clean Architecture** combined with the **BLoC (Business Logic Component)** state management pattern.

```
lib/
├── feature/
│   ├── home/                  # Home wallet view & currency configuration
│   └── transfer/              # Transfer flow domain, data, & presentation
│       ├── domain/
│       │   ├── entities/      # Pure business entities (no serialization)
│       │   ├── usecases/      # Single-purpose business rules
│       │   └── repositories/  # Repository interfaces (contracts)
│       ├── data/
│       │   ├── datasources/   # Local/Remote database & mock APIs
│       │   ├── models/        # Data serialization classes (fromJson/toJson)
│       │   └── repositories/  # Repository implementations (FP-based Either)
│       ├── bloc/              # State management handlers
│       └── view/              # Responsive widgets & layouts
├── shared/
│   ├── di/                    # Dependency Injection (get_it & injectable)
│   ├── error/                 # Domain failure structures
│   ├── navigation/            # Router configuration (go_router)
│   ├── services/              # SharedPreferences & core utils
│   ├── theme/                 # Premium unified design system
│   └── widgets/               # Reusable UI widgets
```

### Key Architectural Choices:
1.  **Decoupled Domain**: Domain entities are kept pure. JSON mappings (`fromJson`/`toJson`) are restricted to `data/models` and extension classes.
2.  **Functional Error Handling**: All repository operations return an `Either<Failure, T>` monad via the `fpdart` package. This forces the UI layer to explicitly handle both error and success cases.
3.  **Scroll Safety & Keyboard Overflows**: Layouts use `CustomScrollView` and `SliverFillRemaining` to avoid UI overflows on small screen viewports (like the iPhone SE).

---

## 🕹️ State Management Approach

The project utilizes `flutter_bloc` to handle state management cleanly. Each major view is backed by a dedicated BLoC:

*   **`HomeBloc`**: Manages wallet assets, currency selection state, and the recent transaction history list.
*   **`RecipientEntryBloc`**: Orchestrates recipient search inputs, debounces search events (300ms), and validates query targets.
*   **`AmountEntryBloc`**: Manages keypad events, updates the decimal-precision restricted amount string, and handles fiat-to-crypto conversions.
*   **`ReviewTransactionBloc`**: Manages transaction construction and network fee calculation.
*   **`PinConfirmationBloc`**: Manages PIN keyboard input, attempts counters, lockout timers, and biometric auth states.

---

## ⚖️ Assumptions & Trade-offs

### 1. Local Database & RPC Simulations
*   **Trade-off**: Instead of executing real transactions on-chain (using live Ethereum/Solana RPC nodes), transaction broadcasting and fee estimations are mock-simulated with delays.
*   **Reasoning**: Fits the take-home assessment guidelines while allowing detailed testing of all loading, pending, success, and failure UX states.

### 2. Lockout Persistence via `SharedPreferences`
*   **Trade-off**: SharedPreferences is used to persist PIN lockout timestamps.
*   **Reasoning**: Sufficient for sandbox verification. In a production environment, this should be written to encrypted local storage (`flutter_secure_storage` or SQLCipher).

### 3. QR Scanner Simulation
*   **Trade-off**: Standard camera libraries are not integrated; instead, an interactive simulation scanner is built.
*   **Reasoning**: Prevents dependencies on hardware camera permissions in virtual test environments while verifying the UI logic and integration with contact searches.

### 4. Responsive Layout Limits
*   **Trade-off**: Only the Wallet Home Page is made fully responsive for all mobile screens, including ultra-narrow viewports (e.g. Samsung Galaxy Fold folded state).
*   **Reasoning**: Maximizes design focus and demonstrates responsiveness patterns (e.g., FittedBox, Wrap, LayoutBuilder button grids) on the primary interface.


---

## 🧪 Testing Instructions

The codebase includes **51 automated tests** covering unit validations, widget keypads, and an E2E Integration Test Suite.

### Running all tests:
```bash
flutter test
```

### Key Test Categories:
1.  **E2E Integration Test Suite** (`test/integration/send_flow_integration_test.dart`):
    *   **Recipient Entry**: Verifies search positive case (navigation) and negative cases (no results on invalid queries).
    *   **Amount Entry**: Verifies keypad input, balance error warnings, button enabling, and continuation.
    *   **PIN & Lockout**: Tests incorrect PIN attempts, 3-strike lockout cooldown display, and correct PIN completion navigations.
2.  **Validation Unit Tests** (`test/amount_entry_bloc_test.dart` & `test/add_contact_bloc_test.dart`):
    *   Asserts USDC, SOL, and ETH token decimal bounds.
    *   Verifies 6 custom negative test cases: double decimal points, empty amounts, zero checks, backspacing empty inputs, precision underflow blocks, and reset behaviors.
3.  **Widget & Animation Tests** (`test/bepay_keypad_widget_test.dart` & `test/qr_scanner_page_test.dart`):
    *   Asserts keyboard rendering, button layout clicks, and simulated QR scanner responses.

---


