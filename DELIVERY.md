# Bepay Crypto Transfer - Delivery & Engineering Review

This document outlines the priorities, simplifications, trade-offs, and production considerations for the Bepay Crypto Transfer take-home project.

---

## 🎯 What Was Prioritised

1. **Clean Architecture & Domain Decoupling**:
   - Kept the domain layer (`domain/entities`) strictly pure and decoupled from data serialization (`toJson`/`fromJson`). All JSON mapping is encapsulated inside `data/models` and extension classes.
2. **Reliable In-App Numeric Keyboard (`BepayKeypad`)**:
   - Enforced a custom keyboard for all amount entries. Completely blocked system OS keyboards to prevent focus conflicts.
   - Built custom precision constraints dynamically matching token requirements (USDC max 2, SOL max 6, ETH max 8 decimal places).
3. **Failsafe Security & Lockout Mechanisms**:
   - Implemented a 4-digit PIN confirmation with a randomized layout to prevent shoulder surfing.
   - Implemented a 3-strike lockout timer (30 seconds) that persists across app restarts (using `SharedPreferences`).
   - Integrated biometric authentication (Face ID/Fingerprint) with robust cancel/failure recovery.
4. **Resilient UI Layouts (Scroll Safety & Responsiveness)**:
   - Wrapped columns in scrollable sheets (`CustomScrollView` and `SliverFillRemaining`) to guarantee that the keypad and fields remain scrollable and accessible on small form factors (such as the iPhone SE).
   - Enforced truncation and text overflow safeguards on transaction hashes and long wallet addresses.
5. **Testing Coverage**:
   - Maintained **33 passing tests** (30 unit tests for BLoC and UseCase layers, plus 3 widget tests for the custom in-app keyboard).

---

## 🪚 What Was Intentionally Simplified

1. **Local Simulation of Backend/RPC Node**:
   - Instead of connecting to live EVM or Solana RPC endpoints, transaction broadcasting, fee calculation, and transaction history are simulated locally using mock data delays and stored JSON entries.
2. **Mock Transaction signing**:
   - Real private keys are not generated or stored, and blockchain transaction payloads (e.g., signing a raw transaction hash) are omitted. A mock transaction ID (`tx_timestamp`) is generated for result reporting.
3. **Contact Book Persistence**:
   - Added contacts are stored locally in the remote data source stub using memory/mock storage.

---

## ⚖️ Trade-offs Made

1. **`SharedPreferences` for Local Storage**:
   - **Trade-off**: Used standard `SharedPreferences` to persist assets, history, and lockout times. 
   - **Reasoning**: It is quick, reliable for a sandbox app, and has zero native configuration overhead. For production, sensitive data like PIN counts and asset balances should be written to secure storage.
2. **Monolithic Data Source Class**:
   - **Trade-off**: Kept the remote simulation logic inside a single `TransferRemoteDataSourceImpl` class.
   - **Reasoning**: Minimizes boilerplate during the sandbox stage. Under production, this class would be split into dedicated client wrappers (e.g., `ApiClient`, `DatabaseClient`, `AuthClient`).

3. **Qr scanner View**:
   - **Trade-off**: I used a mock qr scanner view instead of a real qr scanner view. Also qr is not validated against existing contacts.
   - **Reasoning**: in the sandbox stage, it is not necessary to use a real qr scanner view, and it can be tested using the mock qr scanner view. 
4. **Data Source Layer**:
    - Use of a slightly larger remote data source simulation file (TransferRemoteDataSourceImpl) which would ideally be split into smaller service clients in production.   

---

## 🚀 Improvements for Production

1. **Encrypted Secure Storage**:
   - Store the user's local PIN hash, biometric keys, and credentials using `flutter_secure_storage` or a local encrypted database like SQLite/SQLCipher.
2. **Real Web3 SDK Integration**:
   - Integrate `solana` (for SOL/SPL tokens) and `web3dart` (for EVM chains) to construct, gas-estimate, sign, and broadcast transactions on-chain.
3. **Advanced Biometric Settings**:
   - Leverage `local_auth` platform flags to customize prompt dialogues and handle biometric hardware changes (e.g., user enrolled a new fingerprint).
4. **QR Code Scanning**:
   - Integrate a QR scanner so users can scan BIP-21 addresses or payment request URIs, auto-filling token, amount, recipient, and memo fields instantly.
5. **Contact Book & Directory Sync**:
   - Build a comprehensive in-app contact book.
   - Sync device contacts from the user's phone book and look up registered Bepay IDs or active blockchain addresses in real-time, matching contact numbers to wallets similar to UPI payment applications.
6. **Advanced App Security & Biometrics**:
   - Enforce an app-level authorization lock when opening the application or returning from background status.
   - Add native Face ID configuration/entitlements specifically optimized for iOS hardware devices.
7. **MetaMask & External Wallet Integration**:
   - Integrate with MetaMask, Phantom, WalletConnect, or Trust Wallet to allow decentralized transaction signing and external address confirmation.
8. **Real-time Fiat Price Feeds**:
   - Integrate live fiat price feed providers (e.g. CoinGecko, CoinMarketCap, or Binance API) to fetch and cache accurate, real-time conversion rates for the tokens held in the user's wallet.
9. **Bepay Multi-Wallet & Dynamic Currency Switching**:
   - Enable users to switch currency denominations dynamically within the amount entry page.
   - For Bepay IDs linked to multiple destination wallets/chains, allow the sender to choose which destination address and network should receive the funds.
10. **Interactive Transaction Loading Streams**:
    - Stream submission states to the button UI during transaction broadcasting (e.g., yielding updates like `[preparing transaction...]`, `[connecting to chain...]`, `[authenticating...]`, `[creating record...]`, `[success...]`) so users feel and track exactly what is happening in the background.
11. **Referral Program**:
    - Add an invite and earn referral system to incentivize and grow the network base.
12. **In-App Asset Swapping**:
    - Add native decentralized exchange (DEX) swap integrations (e.g., Uniswap or Jupiter) to swap assets (e.g., SOL to USDC) directly within the wallet interface.
13. **Developer Options & Root Detection**:
    - Add security checks to detect if the application is running on a rooted (Android) or jailbroken (iOS) device, or if developer options / USB debugging are active. If detected, warn the user or block high-value transaction actions to mitigate keylogging, reverse-engineering, or tampering risks.
14. **Secure Storage**: Migrate sensitive information (lockout status, PIN hash, keys) to `flutter_secure_storage`.
15. **On-Chain SDKs**: Integrate `web3dart` and `solana` to build, sign, and broadcast real transactions.
16. **Live Price Feeds**: Fetch real-time market value rates using CoinGecko or Chainlink Oracles.
17. **Root & Developer Protection**: Detect if the application is running on jailbroken or rooted devices or if USB debugging is enabled, restricting access for maximum security.
18. **Interactive Broadcast Feed**: Stream loading states to button widgets (e.g. `[broadcasting...]` -> `[confirming...]` -> `[success]`) for a transparent user experience.

