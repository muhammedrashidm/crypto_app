---
name: Financial Velocity
colors:
  surface: '#13131b'
  surface-dim: '#13131b'
  surface-bright: '#393841'
  surface-container-lowest: '#0d0d15'
  surface-container-low: '#1b1b23'
  surface-container: '#1f1f27'
  surface-container-high: '#292932'
  surface-container-highest: '#34343d'
  on-surface: '#e4e1ed'
  on-surface-variant: '#c7c4d7'
  inverse-surface: '#e4e1ed'
  inverse-on-surface: '#303038'
  outline: '#908fa0'
  outline-variant: '#464554'
  surface-tint: '#c0c1ff'
  primary: '#c0c1ff'
  on-primary: '#1000a9'
  primary-container: '#8083ff'
  on-primary-container: '#0d0096'
  inverse-primary: '#494bd6'
  secondary: '#ddb7ff'
  on-secondary: '#490080'
  secondary-container: '#6f00be'
  on-secondary-container: '#d6a9ff'
  tertiary: '#ffb783'
  on-tertiary: '#4f2500'
  tertiary-container: '#d97721'
  on-tertiary-container: '#452000'
  error: '#EF4444'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#f0dbff'
  secondary-fixed-dim: '#ddb7ff'
  on-secondary-fixed: '#2c0051'
  on-secondary-fixed-variant: '#6900b3'
  tertiary-fixed: '#ffdcc5'
  tertiary-fixed-dim: '#ffb783'
  on-tertiary-fixed: '#301400'
  on-tertiary-fixed-variant: '#703700'
  background: '#13131b'
  on-background: '#e4e1ed'
  surface-variant: '#34343d'
  success: '#22C55E'
  warning: '#F59E0B'
  surface-dark: '#09090B'
  surface-light: '#FAFAFA'
  border-subtle: '#27272A'
typography:
  display-balance:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  keypad-num:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '500'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-mobile: 1.25rem
  gutter-sm: 0.5rem
  gutter-md: 1rem
  stack-sm: 0.25rem
  stack-md: 0.75rem
  stack-lg: 1.5rem
---

## Brand & Style

The design system is engineered for a non-custodial crypto environment where trust, security, and speed are paramount. The brand personality is **Professional, Safe, and Efficient**. It avoids the speculative "hype" aesthetics often found in web3, instead opting for a "Bank-Grade" reliability that feels familiar to fintech users while remaining modern.

The visual style is a hybrid of **Minimalism** and **Corporate Modern**. It utilizes a rigorous 8px grid system, generous whitespace to reduce cognitive load during complex transactions, and a high-contrast color application to highlight critical financial data. The interface is intentionally restrained to ensure that the user's primary focus remains on transaction accuracy and asset security.

## Colors

The palette is anchored by a vibrant **Indigo primary**, signaling innovation and stability. This color is reserved for primary actions and active states. 

- **Primary & Secondary:** Used for "Send" actions, progress indicators, and active selection states.
- **Transactional States:** Success (Green), Error (Red), and Warning (Amber) follow industry-standard semantics to ensure immediate user comprehension of transaction results.
- **Neutral Palette:** This design system utilizes a "Zinc" scale of grays. In **Dark Mode** (default), it uses deep charcoals (#09090B) to provide depth without the harshness of pure black. In **Light Mode**, it uses soft off-whites to reduce eye strain.
- **Contrast:** A minimum contrast ratio of 4.5:1 is maintained for all functional text to ensure accessibility in varied lighting conditions.

## Typography

The design system exclusively uses **Inter** for its exceptional legibility in digital interfaces and its neutral, systematic character.

- **Balances:** Large wallet balances use `display-balance` with tight letter spacing to create a high-impact, professional financial dashboard feel.
- **Information Hierarchy:** Bold headlines are used for screen titles, while `label-caps` are utilized for metadata like "NETWORK" or "TRANSACTION ID" to create clear visual separation between categories and values.
- **Numeric Data:** All numbers (amounts, fees, PINs) use tabular figures where possible to ensure vertical alignment in lists and transaction reviews.

## Layout & Spacing

The layout follows a **Fixed Grid** philosophy for mobile devices, centering content within a safe area with 20px (`margin-mobile`) horizontal margins. 

- **8px Baseline:** All spacing, padding, and height values are multiples of 8px to ensure a consistent rhythmic flow.
- **Stacking:** Use `stack-lg` to separate major logical sections (e.g., Balance vs. Token List). Use `stack-sm` for tight coupling between labels and their corresponding input fields.
- **Keypad Layout:** The custom numeric keyboard utilizes a 3-column grid with `gutter-sm` spacing to ensure buttons are large enough for comfortable thumb interaction while maintaining a compact vertical footprint.

## Elevation & Depth

To maintain a "clean and safe" feel, the design system avoids heavy shadows, instead relying on **Tonal Layers** and **Low-Contrast Outlines**.

- **Level 0 (Base):** The primary background color of the app.
- **Level 1 (Cards/Surfaces):** Tokens and list items sit on a surface slightly lighter (in dark mode) or slightly darker (in light mode) than the base, defined by a 1px `border-subtle`.
- **Level 2 (Modals/Overlays):** PIN confirmation and bottom sheets use a subtle ambient shadow (0px 4px 20px rgba(0,0,0,0.2)) to lift them above the main flow.
- **Glassmorphism:** Reserved specifically for the "Review Transaction" summary header to provide a premium feel without sacrificing readability.

## Shapes

The design system uses a **Rounded** (0.5rem) language to balance the technical nature of crypto with a friendly, accessible fintech experience.

- **Buttons:** Primary buttons use `rounded-lg` (1rem) to appear distinct and "tappable." 
- **Cards:** Token items and transaction containers use the base `rounded` (0.5rem) to maintain a structured, grid-like feel.
- **Inputs:** Input fields for recipient data use the base `rounded` setting to match the container language.
- **PIN Dots:** PIN entry indicators are perfect circles to differentiate them from standard data input.

## Components

### Buttons
- **Primary:** Full-width, solid background (Primary Color), `body-lg` bold text. Used for "Continue" or "Confirm."
- **Secondary:** Outlined or ghost style. Used for "Cancel" or "Max."
- **Keypad Buttons:** Subtle surface background that changes color slightly on press (active state) to provide tactile feedback without the native keyboard.

### Cards & Lists
- **Token Card:** Contains Icon (left), Name/Symbol (center-left), and Balance/Fiat Value (right). 
- **Transaction Card:** Uses a high-contrast "Send" vs "Receive" icon indicator and clearly distinguishes the Recipient (bold) from the Network (muted).

### Inputs
- **Numeric Keypad:** The digits 0-9 are arranged in a standard 3x4 grid. The "Max" button is placed to the left of the "0", and the "Backspace" icon is to the right. This layout is optimized for single-handed thumb use.
- **Recipient Input:** A single-line field with clear validation icons (checkmark for valid bepayID/address, error icon for invalid strings).

### PIN Entry
- Discrete indicators (dots) that fill as the user types. 
- On error, the entire row of dots performs a horizontal "shake" animation with the `error` color state.

### Transaction Review
- A "Summary Sheet" layout where the main amount is displayed at the top, followed by a list of "Row Items" (Recipient, Network, Fee, Total). The Total row must be emphasized with a background tint or bold font.