# Luna Tracker 🌙

A beautiful, friendly, and privacy-focused Flutter application designed for period tracking and menstrual health wellness.

---

## 🌸 About Luna Tracker

**Luna Tracker** combines period tracking with a supportive, non-clinical brand personality that feels like a message from a best friend. It offers personalized notification preferences, customizable language and tone, intelligent cycle calculations, Luna Care wellness dashboard, and intuitive onboarding screens.

### Design Principles
- **Comfort over Anxiety**: Warm pastel colors, soft gradients, and rounded surfaces.
- **Supportive & Relatable**: Personality-driven reminders, 2D cartoon character illustrations, and language selection (English, Tanglish, Tamil).
- **Privacy First**: Discreet notification settings for lock screens.

---

## 💡 Cycle Intelligence Engine

Luna Tracker features a dedicated, standalone **Cycle Intelligence Engine** (`CycleCalculationService`) that processes actual period records and onboarding data:

- **Rolling 6-Cycle Average**: Calculates average cycle length using up to the latest 6 observed cycles between consecutive confirmed period start dates.
- **Observed Cycle Statistics**: Tracks rolling average, shortest cycle, longest cycle, average period duration, and total observed cycle count.
- **Deduplication & Validation**: Ignores duplicate or near-duplicate period start entries (logged within 3 days).
- **Irregular & Delayed Cycles**: Handles delayed cycles gracefully without inventing fake period records. Predictions dynamically update as days advance.
- **Strict Prediction Isolation**: Predictions are used solely for future calendar projections and never fed back into historical averages.
- **Safe Fallbacks**: Falls back to onboarding preferences when observed data is incomplete or unavailable.

---

## 📱 Features & Screens

1. **Welcome Screen** (`WelcomeScreen`)
2. **Name Personalization** (`NameScreen`)
3. **Cycle Setup** (`CycleSetupScreen`)
4. **Cycle & Period Duration** (`CycleLengthDurationScreen`)
5. **Notification Preferences** (`NotificationPreferencesScreen`)
6. **Main Home Dashboard** (`HomeScreen`) — Interactive cycle wheel driven by Cycle Intelligence calculations with compact weekly calendar strip.
7. **Period Calendar** (`PeriodCalendarScreen`) — Monthly calendar grid, color-coded indicators (Period, Predicted, Fertile Window, Ovulation ⭐, Today ♡), Log Period bottom sheet, and Cycle Overview card.
8. **Luna Care Home Dashboard** (`CareHomeScreen`) — Feminine wellness dashboard featuring Hero Banner, 2-column feature grid (**Diet & Nutrition**, **Pain Relief Yoga**, **Daily Care Tips**, **Learn About Periods**), and Today's Care Tip card with sleeping mascot.

---

## 🛠️ Architecture & Project Structure

```text
lib/
├── core/
│   ├── app_colors.dart                 # Luna design palette (pastels, gradients, primary plum)
│   ├── app_theme.dart                  # Material 3 typography, theme, and common radii
│   ├── models/
│   │   └── period_record.dart          # Immutable model for actual recorded periods
│   └── services/
│       ├── cycle_calculation_service.dart # Cycle Intelligence calculation engine & predictions
│       └── notification_service.dart   # Native Android local notification manager
├── features/
│   ├── care/
│   │   └── care_home_screen.dart       # Luna Care wellness dashboard screen
│   └── onboarding/
│       ├── welcome_screen.dart
│       ├── name_screen.dart
│       ├── cycle_setup_screen.dart
│       ├── cycle_length_duration_screen.dart
│       ├── notification_preferences_screen.dart
│       ├── period_calendar_screen.dart
│       └── home_screen.dart
└── main.dart                           # Application entry point & onboarding navigation
docs/
├── DESIGN_SYSTEM.md                    # Visual identity, colors & component specs
├── SCREEN_FLOW.md                      # Onboarding & 5-tab screen navigation
└── FEATURES.md                         # Feature breakdown
test/
└── cycle_calculation_service_test.dart # Comprehensive unit test suite for Cycle Intelligence
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13+ recommended)
- Android Studio / VS Code with Flutter extension
- An Android Emulator or physical Android device

### Running the Project & Tests

1. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run unit test suite**:
   ```bash
   flutter test
   ```

3. **Run code analysis**:
   ```bash
   flutter analyze
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```
