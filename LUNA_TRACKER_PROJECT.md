# LUNA TRACKER — PROJECT HANDOFF

> **Purpose of this file:** Everything the previous Claude account knew about this project, so a new Claude account can continue without losing context.
> **Written:** 12 Nov 2026 (user timezone: Asia/Calcutta, IST).
> **Sources:** the user's original project plan (Appendix A), every message in the previous conversation, and the Dart files delivered or attached in it.
> **Rule used while writing:** nothing here is invented. Where something was never decided, it says **"Not decided"**. Where something is my (Claude's) suggestion rather than the user's decision, it is labelled **"Suggestion"**.

---

## 0. READ THIS FIRST (for the new Claude)

### 0.1 Status legend
| Tag | Meaning |
|---|---|
| ✅ **DONE** | Code was written and delivered to the user. See the note on verification below. |
| 🟡 **IN PROGRESS** | Started or requested, not finished or not delivered. |
| 🔲 **PLANNED** | In the user's plan or agreed as a next step; no code exists. |
| 💡 **SUGGESTION** | Claude's idea; the user has not approved it. |
| ❓ **NOT DECIDED** | Open question. Ask the user. |

### 0.2 Verification honesty notes
- **The previous Claude never compiled or ran any Flutter code.** The sandbox had no `dart`/`flutter` (`which dart flutter` returned nothing). The user ran the code on their own machine and sent screenshots; that is the only runtime evidence.
- User-confirmed by screenshot or comment: the **welcome screen** ran, the **name screen** ran and the user said "i love the second name screen", the **first home screen wheel** ran (screenshot of "Day 7"). **Cycle-setup screen (screen 3): the user never explicitly confirmed running it.**
- The **current `home_screen.dart` is the user's own latest version** (attached late in the conversation as `ab07ebc6-attachment.txt`). It contains wheel code (`_periodInfo`, start/end/next date labels on the wheel, `_WheelLegend(periodRange, cycleLength)`) that **goes beyond the last version Claude wrote in the chat**. Treat the user's file as the source of truth, not the earlier Claude version. It also uses `errorBuilder: (_, _, _)` (wildcard parameters), so the user's Dart SDK must be 3.7 or newer. This is an observation from the file, not something the user stated.
- Contrast ratios quoted in `DESIGN.md` (about 5.6:1 and about 5.2:1) were **hand-estimated by Claude, not measured with a tool.** Re-check them with a contrast checker.
- **The new account will not have the user's images, the Dart files or the Claude Project.** The user must re-upload them. See section 22.

### 0.3 How the user works (observed)
- Spends about **1 hour per day**, often late at night IST. Wants step-by-step guidance and slow, steady progress.
- Works in **Android Studio**, project folder `~/StudioProjects/period_tracker`.
- Gives **mockup screenshots** and asks for the **"exact UI code"**. Repeats "exact" often. Wants pixel-faithful reproduction, not an interpretation.
- Has a **Java backend background** and is learning Flutter and Dart.
- Likes concise "what to paste where" instructions, for example "which file do I add this code to?" Spell out file paths and whether to hot reload or hot restart.
- Wants files delivered as downloadable files, not only pasted code.

---

## 1. Project identity and vision

| Item | Value |
|---|---|
| Working name used now | **Luna** ("Luna Tracker", wordmark `luna`, tagline `PERIOD TRACKER`) |
| Original name in the user's plan | **Nilah** — "Menstrual Health & Wellness Companion" |
| Platform | Flutter mobile app, **Android first** |
| Flutter project folder / package | `period_tracker` (`~/StudioProjects/period_tracker`) |
| Builder | The user alone, learning Flutter |

### 1.1 Naming status ❓ NOT DECIDED
The user's plan document, the six notification examples ("Nilah is checking on you") and the GitHub repo name plan all say **Nilah**. On 9 Nov 2026 the user asked: *"change nilah into Luna"* for the welcome screen, and later mockups all say **luna**. The user has never said whether the final Play Store name is Luna or Nilah. **Ask before launch.**

Claude already warned once that "Luna" is a very common app name (including other period trackers), so the user should check Play Store similarity and trademarks before building the brand on it. The user has not replied to that.

### 1.2 Mission (from the plan)
Make menstrual wellness easier to understand and manage by combining useful tracking, personalized self-care, and an emotionally supportive experience.

### 1.3 Vision (from the plan)
Build a trusted, privacy-conscious wellness brand that users want to keep on their phones because it helps them feel informed, supported, and understood.

### 1.4 Product personality (from the plan)
Friendly, funny, caring, relatable, modern, and respectful.

### 1.5 Design identity (user's own recommendation text, 9 Nov)
> Don't make Luna look like a traditional medical application. Your visual identity should communicate: Comfort rather than anxiety. Understanding rather than judgement. Privacy rather than exposure. Self-care rather than medical complexity.
> Also, make sure text and important calendar indicators have sufficient contrast and don't rely on colour alone to communicate cycle information.
> Keep your pink + lavender + plum identity. Don't completely change your palette. Refine it into a consistent design system that you can use across onboarding, dashboard, calendar, reminders and settings.

---

## 2. Goals (from the plan)

1. **Help users understand their cycles.** Track period dates, cycle history, symptoms and estimated upcoming periods. Clearly communicate that predictions can be inaccurate and cycles can vary.
2. **Make notifications a signature feature.** Funny, personalized, rotating reminders that feel like messages from a best friend, while respecting privacy, quiet hours and notification preferences.
3. **Support everyday wellness.** Gentle yoga, breathing exercises, relaxation music and practical self-care that may help users manage discomfort and stress.
4. **Serve the intended audience.** Tamil and English support, accessible content, simple navigation, a welcoming design for users with different levels of health knowledge.
5. **Launch a sustainable product.** Build v1 alone, validate usefulness, launch Android first if practical, explore a planned **₹15/month** premium subscription.

## 3. Target audience
- **Initial audience: Tamil Nadu**, with planned **Tamil and English** support (plan text).
- Users with different levels of health knowledge.
- Nothing else about demographics was ever specified. Do not assume age ranges.

---

## 4. Feature list and status

### A. Onboarding and personalization
| Feature | Status |
|---|---|
| Screen 1: logo + welcome animation | ✅ DONE (`welcome_screen.dart`) |
| Screen 2: ask what name to use | ✅ DONE (`name_screen.dart`) |
| Screen 3: personalized greeting | ✅ DONE as "Welcome, <name>!" + last-period date (`cycle_setup_screen.dart`). The plan said "Hey, Halin!"; the user's mockup says "Welcome, Halin!" and the code follows the mockup. |
| Language preference during onboarding | 🔲 PLANNED (optional in plan) |
| Cycle setup (last period date) | ✅ UI DONE, **not persisted** |
| Ask for notification permission "at an appropriate time" | 🔲 PLANNED |

### B. Period tracking and calendar
| Feature | Status |
|---|---|
| Show cycle day and estimated next period | ✅ DONE on Home (in-memory maths, defaults 28/5) |
| Weekly strip calendar that drives the wheel | ✅ DONE on Home |
| Log period start and end dates | 🔲 PLANNED |
| Monthly calendar and cycle history | 🔲 PLANNED (Calendar tab) |
| Record symptoms, mood, energy | 🔲 PLANNED (Mood/Cramps/Drugs cards exist as "coming soon" stubs) |
| Allow users to correct dates and predictions | 🔲 PLANNED |

### C. "Nilah Bestie Notifications" — signature feature 🔲 PLANNED (no code yet)
Funny, relatable, caring. Period-near reminders, mood check-ins, self-care reminders, yoga and relaxation prompts, water reminders, gentle support messages. Must rotate, respect quiet hours, allow tone and frequency choice. Details in section 12.

### D. Period pain relief and yoga 🔲 PLANNED
Beginner stretching and yoga guides, breathing and relaxation, warm-compress and other practical self-care, symptom logging, clear guidance to seek medical care for severe or unusual pain. **Must be described as supportive options, not guaranteed treatments.**

### E. Music and relaxation 🔲 PLANNED
Relaxing audio and soundscapes, guided meditation and breathing, short sessions and sleep support, audio player with play, pause and duration. **Use original or properly licensed audio only.**

### F. Journal, insights, education 🔲 PLANNED
Mood and symptom journal, personal cycle history and patterns, Tamil and English educational content, notification settings, optional ovulation estimates **clearly labelled as estimates** (see the "NOT to do" list in section 18 about pregnancy wording).

### G. Privacy, accounts, premium 🔲 PLANNED
Local-first storage, data export and deletion, optional accounts and cloud backup, premium and subscription management, privacy policy.

---

## 5. Roadmap

### 5.1 The user's 8 phases (from the plan)
1. **Phase 1 — Project foundation:** Flutter setup, folders, reusable colors/components, three onboarding screens. → 🟡 mostly done (onboarding UI + theme done; persistence not).
2. **Phase 2 — Home and navigation:** home dashboard and navigation between main sections. → 🟡 Home done; **navigation change in progress** (section 21); other tabs are stubs.
3. **Phase 3 — Core period tracking:** period logging, calendar views, calculations, local storage. → 🔲
4. **Phase 4 — Notifications:** scheduled reminders, permissions, quiet hours, preferences, rotating message library. → 🔲
5. **Phase 5 — Wellness:** yoga guides, pain-support info, breathing, basic music player. → 🔲
6. **Phase 6 — Language and personalization:** Tamil + English, accessible content, mood tracking, settings. → 🔲
7. **Phase 7 — Testing and privacy:** predictions, offline behaviour, notifications, accessibility, sensitive data, different Android devices. → 🔲
8. **Phase 8 — Launch and growth:** store listing, privacy policy, feedback process, optional backend and subscription when justified. → 🔲

The plan says: *"Finish one working milestone before adding the next. The order can be adjusted after testing."* and the immediate priority is *"Build the onboarding and navigation foundation, then complete period tracking and notifications before expanding into all the wellness features."*

### 5.2 Timeline Claude proposed at 1 hour/day 💡 SUGGESTION (user did not object)
| Weeks | Phase | Goal |
|---|---|---|
| 1–2 | Flutter basics + Phase 1 | Environment, 3 onboarding screens, theme and colors |
| 3–4 | Phase 2 | Home screen and bottom navigation |
| 5–9 | Phase 3 | Period logging, calendar, cycle calculations, local storage |
| 10–13 | Phase 4 | Notifications: permissions, quiet hours, rotating messages |
| 14–15 | Closed-test prep | Bug fixes, privacy policy, app icon, store listing, signed build |
| 16–18 | Closed test on Play Store | Testers, feedback, fixes |
| Later | Phases 5–8 | Yoga and breathing first, then music, Tamil/English, premium |

First Play Store release estimated at **4–5 months**; the full vision at **8–10 months**. The user has actually moved faster on UI than this timeline.

Daily rhythm Claude suggested: 10 min review, 40 min build, 10 min commit to Git with a short note.

### 5.3 Where the user actually is (12 Nov 2026)
- Day 1 (environment setup) reported done on 29 Oct 2026.
- By 9–10 Nov the user had built four screens (welcome, name, cycle setup, home) and a theme.
- **Not confirmed:** whether the repo was pushed to GitHub; whether `applicationId` was changed from the default.

---

## 6. Screens and navigation

### 6.1 Planned main navigation (from the plan)
Home (daily overview), Calendar (cycle tracking), Wellness (yoga and relief), Relax (music and breathing).
Additional screens: onboarding, period logging, symptom journal, education, notification settings, profile, privacy, premium subscription.

### 6.2 Bottom navigation — history
1. **Plan:** Home / Calendar / Wellness / Relax.
2. **First home mockup (user's UI):** Home / Calendar / Reports / Self-Care. Built that way in `home_screen.dart`.
3. **Latest request (10 Nov 2026):** *"want to remove Reports and Self-Care from the current navigation and use the navigation style in your reference image. Your new bottom navigation will be:"* — **the message was cut off and the list never arrived.** The attached reference image shows exactly four tabs: **Home, Calendar, Care, Relax**. That matches the plan's four sections, with "Care" in place of "Wellness".
4. **Status: 🟡 IN PROGRESS, no edit was delivered.** Claude had only copied the file into a scratchpad before the conversation moved on. See section 21 for the spec.

### 6.3 Screen flow (implemented in `main.dart`)
```
WelcomeScreen ──(Let's Begin)──► NameScreen ──(Continue name / Skip "")──► CycleSetupScreen
   ──(Continue date / "I'll do this later" null)──► HomeScreen   [pushAndRemoveUntil: onboarding cleared]
```
There is **no persistence**. Every cold start begins at the welcome screen again.

---

## 7. Design system

Code files: `lib/core/app_colors.dart`, `lib/core/app_theme.dart`, and `DESIGN.md` in the project root (full text of all three in Appendix B).

### 7.1 The user's chosen "Luna colour system" (pasted by the user, 9 Nov)
| Role | HEX | Use |
|---|---|---|
| Primary background | `#F8E8F0` | Background |
| Primary action | `#98577F` | Buttons |
| Secondary colour | `#E9DDF9` | Cards |
| Period indicator | `#F4A6C6` | Calendar |
| Text colour | `#7A4E72` | Typography |
| Warm accent | `#FBD8C6` | Highlights |

### 7.2 Original palette in the plan (before the Luna system)
| Name | HEX | Meaning |
|---|---|---|
| Soft pink | `#DDA0C7` | Warmth and care |
| Lavender | `#AF83E8` | Calm and focus |
| Sage green | `#76B98A` | Wellness and rest |
| Peach | `#E9A36E` | Friendly highlights |

The user said to keep pink + lavender + plum. Sage (`#76B98A`) is kept as `AppColors.sage` for wellness and rest. The plan palette hexes `#DDA0C7`, `#AF83E8` and `#E9A36E` are **not** used in the code.

### 7.3 Supporting colours added by Claude (in `app_colors.dart`)
| Name | HEX | Use |
|---|---|---|
| `textMuted` | `#80587C` | Secondary text (darker than an earlier lighter plum that was too light) |
| `lavender` | `#A98BEB` | Gradient start, focus rings |
| `lavenderSoft` | `#D5BDEB` | Borders |
| `sage` | `#76B98A` | Wellness / rest |
| `onPrimary` / `white` | `#FFFFFF` | Text on primary |
| `ctaGradient` | `#9B72DC` → `#B56BC6` (left→right) | **Currently unused**; available if a gradient button is wanted again |
| `backgroundGradient` | `#FDEFF3` → `#F8E8F0` → `#FCEFEA` (top→bottom) | Available |

### 7.4 Other hard-coded colours used in screens (not yet in `AppColors`)
| HEX | Where / why |
|---|---|
| `#EE6FA0` (`_hotPink`) | Home: period drop icons, spark lines |
| `#E8629A` → `#CF4F86` | Home wheel: period band gradient (top-left → bottom-right) |
| `#D95A8F` | Home wheel legend dot |
| `#B54877` | Home wheel date labels |
| `#B3426B` | Error text (name screen, date screen) and theme `error` |
| `#E8446F` | Home: notification dot |
| `#D4558C` | Shadow tint (`0x1AD4558C` etc.) on glass cards |
| `#9B7FC2` | Welcome: "PERIOD TRACKER" text |
| `#B79AD6` | Welcome logo curl |
| `#F0C4D8` | Home: info-card divider |
| `#EBD3E4` | Cycle setup: date-card divider |
| `#EBD9F2` | Name screen: back-button border |
| Mood card gradient | `#FDE4E4` → `#FBD3E2` |
| Cramps card gradient | `#F8E3F2` → `#EBD9F7` |
| Drugs card gradient | `#E9E6FB` → `#DCE0F8` |
| Greeting card gradient | `0xCCFBD3E3` → `0x99FCE6F0` (left→right) |

### 7.5 Screen background gradients (all top→bottom)
| Screen | Colours | Stops |
|---|---|---|
| Welcome | `#FDEFF3`, `#F8E8F0`, `#F1E4F6` | 0, 0.45, 1 |
| Name | `#FDEFF3`, `#F8E8F0`, `#F1E4F6` | evenly |
| Cycle setup | `#FBEAF2`, `#F8E8F0`, `#F9DEEB` | 0, 0.5, 1 |
| Home | `#FCEAF3`, `#F8E8F0`, `#F8DCEB` | 0, 0.45, 1 |

Welcome-screen waves: lavender `0x55E9DDF9`→`0x33E9DDF9`, warm accent `0x66FBD8C6`→`0x33F4A6C6`, white sparkle dots `0x66FFFFFF`.
Cycle-setup waves: `0x44E9DDF9`→`0x66D9C2F0` and flat `0x44E0C8F2`.

### 7.6 Typography
- **No custom font package yet.** Headings on welcome and name use `fontFamily: 'serif'` (generic); everything else is the Flutter default (Roboto on Android).
- 💡 Suggestion (not approved): `google_fonts` with a serif such as Playfair Display / Cormorant for headings and Quicksand / Comfortaa for the rounded `luna` wordmark, to approach the mockups.
- Sizes in use:

| Element | Size / weight |
|---|---|
| Welcome `luna` wordmark | 62, w400, letterSpacing 1.5 |
| Welcome "PERIOD TRACKER" | 12, w600, letterSpacing 4.2, `#9B7FC2` |
| Welcome main message | serif 32, w500, height 1.2, `AppColors.text` |
| Welcome supporting message | 16.5, `AppColors.textMuted` |
| Name title | serif 35, w500, height 1.2 |
| Name subtitle | 15.5, height 1.5 |
| Cycle setup logo wordmark | 54, w300; tagline 13, w500, letterSpacing 5.5 |
| "Welcome, <name>!" | 33; "Welcome, " w400, name w800 |
| "We're happy you're here." | 19 |
| "When did your last period start?" | 28, w700 |
| Home logo | `luna` 44, w300; tagline 11.5, w500, letterSpacing 5 |
| Home greeting | "Hi, <name>!" 26, w800; subtitle 14.5 |
| Home month title | 20, w700 |
| Home weekday / day number | 14 / 21 w700 |
| Home info values | 23, w800; labels 14, `textMuted` |
| Quick card title / subtitle | 18 w800 / 13 |
| Bottom nav label | 13.5 |

### 7.7 Spacing, radii, shadows
- Screen side padding: **28** (welcome, name), **24** (cycle setup), **18** (home cards). `AppSizes.screenPadding = 24`.
- Pill buttons: height **58** (welcome, name), **60** (cycle setup); radius **29 / 30**. `AppSizes.buttonHeight = 58`, `radiusPill = 30`, `radiusCard = 24`.
- Welcome button width: `max(240, screenWidth × 0.68)`.
- Name field: height 58, radius 29, border `#D5BDEB` 1.3 px, fill `0x99FFFFFF`, max 30 characters.
- Cards: radius 28 (date card, quick cards), 30 (week card), 32 (info card), 38 (greeting card, height 112). Weekly day circle 44×44; icon bubble 52×52; back button **48×48**.
- Primary button shadow: `0x5598577F`, blur 22, offset (0, 10).
- "Glass" card: fill `0x99FFFFFF`, border `0xB3FFFFFF` 1.4 px, shadow `0x1AD4558C` blur 20 offset (0, 8).
- Selected day circle: fill `#98577F`, shadow `0x5598577F` blur 12 offset (0, 5).

### 7.8 Animation rules
- **Gentle, slow float only.** On the user's request, lotus and petals float slowly: **10-second loop**, lotus moves about 3 px, petals about 3×5 px with 0.06 rad rotation. Intro: fade + slight slide, 1400 ms.
- The wheel knob animates between days (500 ms `easeInOutCubic`); centre text uses `AnimatedSwitcher` 250 ms.

### 7.9 Accessibility rules (DESIGN.md and the user's recommendation)
- Never rely on colour alone for cycle information; pair with icon/shape + text (drop for period days, dot for today/predicted, ring for selected).
- The period pink `#F4A6C6` is light, so always pair it with a border or icon.
- Minimum tap target 48×48.
- Predictions are always labelled **"estimate"**.
- Day cells and the wheel have `Semantics` labels.

### 7.10 Visual references (mockups the user supplied)
These were images. They are not in this file. **The user must re-upload them.**
1. **Welcome mockup #1 (brand "nilah" at the time):** star-and-two-leaf logo, `PERIOD TRACKER`, text above a soft watercolour lotus, purple-gradient "Let's Begin →".
2. **Name mockup:** back button, girl hugging a big heart with small hearts and leaves, "What should I call you?", pill text field with person icon, lavender-pink gradient Continue, "Skip for now". **The user loves this screen.**
3. **Cycle setup mockup:** small logo + `PERIOD TRACKER`, "Welcome, Halin!" with a heart doodle, "We're happy you're here.", lotus on water ripples with sparkles, "When did your last period start?", white date card ("Select your last period date", "Example: 9 November 2026"), plum Continue, underlined "I don't remember / I'll do this later", disclaimer "Your answers help us give better suggestions, but are not medical advice."
4. **Home mockup:** header (menu, logo, bell with red dot), greeting card with a girl hugging a pink pillow ("Hi, Halin! 💕 / Stay kind to yourself today ♡"), weekly strip "November 2026" (Sun 8 … Sat 14, selected Wed 11), a lotus-petal-backed circular cycle wheel ("Day 1"), card "Next Period in 24 days (≈ 5 Dec 2026)" + "Cycle Length 28 days", three cards Mood / Cramps / Drugs, bottom nav. Note: the mockup numbers are inconsistent with each other (Day 1 on 11 Nov with a 28-day cycle would put the next period at 9 Dec, not 5 Dec). The code calculates real values from data.
5. **Latest nav reference image:** dark/black flat bar, four tabs Home / Calendar / Care / Relax, **active Home in pink with bold label**, others grey, outlined icons (house, calendar, heart, music note). See section 21.

**Limit of the process:** Claude cannot extract artwork from a screenshot, so the logo, lotus, petals, branches, girl illustrations and waves are **drawn in code with `CustomPaint`** and look close but not identical. For an exact match the user should export transparent PNGs (lotus, name girl, home girl) and add them as assets. Two spots already support this with a code-drawn fallback: `assets/images/name_girl.png` and `assets/images/home_girl.png`.

---

## 8. Flutter architecture

### 8.1 Principles (from the plan)
Start with an app that works **offline**. Keep period tracking and basic notifications **on-device**. Add Spring Boot + PostgreSQL **only when a feature genuinely needs a backend** (account sync, subscription verification). Menstrual data is sensitive: don't collect or upload it unnecessarily.

### 8.2 Actual folder structure (as built)
```
period_tracker/
├── DESIGN.md                  (Luna design guide)
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── core/
    │   ├── app_colors.dart
    │   └── app_theme.dart
    └── features/
        ├── onboarding/
        │   ├── welcome_screen.dart
        │   ├── name_screen.dart
        │   └── cycle_setup_screen.dart
        └── home/
            └── home_screen.dart
```
Android Studio displays `features/onboarding` as `features.onboarding` when the parent holds a single subfolder. That is a display quirk, not a problem.

### 8.3 Folders Claude suggested on Day 2 (not confirmed created) 💡
`lib/features/calendar/`, `lib/features/wellness/`, `lib/features/relax/`. Earlier suggested layout also had `lib/core/` (done).

### 8.4 Packages
**Currently: none beyond the Flutter SDK.** Everything is drawn in code; there are no assets declared and no dependencies added.

💡 **Suggested (not yet added, not approved):**
| Package | Purpose |
|---|---|
| `shared_preferences` | Save name, last-period date (next immediate task) |
| `drift` (SQLite) | Typed local database for cycles, symptoms, logs (suits Java background) |
| `riverpod` | State management |
| `go_router` | Navigation |
| `flutter_local_notifications` + `timezone` | Phase 4 scheduled reminders |
| `google_fonts` | Typography closer to the mockups |
| `in_app_purchase` | Google Play Billing for premium |

### 8.5 Localization ❓
Claude advised putting all text in **ARB localization files from the start** to ease Tamil later. **Currently every string is hard-coded English** in the screens. Adopting ARB is still to do.

### 8.6 Android identity (must fix before publishing)
- The Flutter default application ID is probably `com.example.period_tracker`. **Google Play rejects `com.example` IDs and the application ID is permanent once published.**
- Claude told the user to change `applicationId` and `namespace` in `android/app/build.gradle(.kts)` to something like `com.yourname.<appname>`. **Not confirmed done. The final app name (Luna vs Nilah) affects this.**

---

## 9. Existing implementation, file by file

All screens use `AppColors` where named, plus hard-coded colour literals listed in 7.4. All art is `CustomPaint`.

### 9.1 `lib/main.dart` ✅ (current delivered version)
```dart
import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/cycle_setup_screen.dart';
import 'features/onboarding/name_screen.dart';
import 'features/onboarding/welcome_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luna',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => WelcomeScreen(
          onBegin: () => _openNameScreen(context),
        ),
      ),
    );
  }
}

/// Screen 1 -> Screen 2
void _openNameScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => NameScreen(
        onContinue: (name) => _openCycleSetup(context, name),
        onSkip: () => _openCycleSetup(context, ''),
      ),
    ),
  );
}

/// Screen 2 -> Screen 3
void _openCycleSetup(BuildContext context, String name) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CycleSetupScreen(
        name: name,
        onContinue: (date) => _openHome(context, name, date),
        onLater: () => _openHome(context, name, null),
      ),
    ),
  );
}

/// Screen 3 -> Home (clears the onboarding screens from the back stack)
void _openHome(BuildContext context, String name, DateTime? lastPeriod) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => HomeScreen(name: name, lastPeriodStart: lastPeriod),
    ),
    (route) => false,
  );
}
```
`Builder` is needed so `Navigator.push` gets a context below `MaterialApp` (Claude explained this to the user).

### 9.2 `welcome_screen.dart` — `WelcomeScreen({VoidCallback? onBegin})` ✅
- **Order (user's instruction, final):** 1) logo, 2) lotus, 3) main message, 4) supporting message, 5) "Let's Begin →".
- **Wording (user-approved, exact):** "Your body has its own rhythm." / "We're here to help you understand it." The user said *"I would keep this as Luna's welcome-screen identity rather than adding more text."* Main message is rendered on two lines: `Your body has its\nown rhythm.`
- Logo = painted four-point sparkle (`AppColors.period`) + two gradient leaves + curl, `luna`, `PERIOD TRACKER`.
- Button: **solid `AppColors.primary` `#98577F`**, "Let's Begin" + arrow icon, white text.
- Six floating petals in `AppColors.period`; soft top glow; waves; lotus drawn with layered petal gradients (lavender outer `#E4C8F2`→`#A98BE2`, pink `#FBD3E3`→`#E3A8D6`, pink `#FFE3E9`→`#F6A9C9`, cream front `#FFF6EF`→`#FBD6E2`) and glowing stamens `#F2B35E` / `#FFD58A`.
- First version (Nilah) had the message above the lotus and a purple gradient button; both were replaced.

### 9.3 `name_screen.dart` — `NameScreen({ValueChanged<String>? onContinue, VoidCallback? onSkip, VoidCallback? onBack})` ✅
- Illustration: `assets/images/name_girl.png` if present, otherwise a code-drawn girl hugging a heart (`_GirlPainter`).
- Title `What should\nI call you?`; subtitle "This is your personal space. Choose the name you feel comfortable with."; field hint "Enter your name"; solid-primary Continue; "Skip for now" in primary.
- Validation: empty name shows "Tell me what to call you 🌸" in `#B3426B`; name is trimmed, `maxLength: 30`; `onSubmitted` also continues; tapping outside closes the keyboard; back button defaults to `Navigator.maybePop`.
- Migrated to `AppColors` on 9 Nov. Original had a lavender→pink gradient Continue; changed to solid plum for consistency. Skip link, hint and error colours were darkened for readability. Float slowed to 10 s. Back button enlarged 40→48.
- **User feedback: loves this screen.**

### 9.4 `cycle_setup_screen.dart` — `CycleSetupScreen({String name = '', ValueChanged<DateTime>? onContinue, VoidCallback? onLater})` ✅
- Empty/whitespace name shows **"friend"** ("Welcome, friend!").
- Date card opens `showDatePicker` themed with primary `#98577F`: `firstDate` = today minus 1 year, `lastDate` = today, `helpText: 'Last period start date'`. After picking, the card shows the date in bold and "Tap to change". Before picking it shows "Example: <today formatted as 9 November 2026>".
- Continue with no date shows "Pick a date, or choose "I'll do this later" 🌸".
- "I don't remember / I'll do this later" → `onLater` (Home gets `lastPeriodStart: null` and shows "Add date").
- Lotus scene with ripples and sparkles; heart-doodle painter next to the greeting; corner branches; waves; calendar+clock icon.
- Note in text: "Your answers help us give better suggestions, but are not medical advice."

### 9.5 `home_screen.dart` — `HomeScreen({String name = '', DateTime? lastPeriodStart, int cycleLength = 28, int periodLength = 5})` ✅ (user's latest version; see 0.2)
Layout top to bottom, inside `SafeArea` + scroll view, with a fixed bottom nav:
1. **Header:** menu button (snackbar "Menu is coming soon 🌸"), centred logo (mini lotus, `luna`, `PERIOD TRACKER`), notification bell with red dot (snackbar "Notifications is coming soon").
2. **Greeting card:** girl (asset `assets/images/home_girl.png`, fallback painter), "Hi, <name>! 💕", "Stay kind to yourself today ♡", spark lines.
3. **Weekly calendar card:** month/year from mid-week, prev/next week arrows, Sun–Sat strip. Each day: weekday, number circle, and below it a **drop icon for estimated period days** or **a small dot for today**. Tapping a day sets `_selected` and the wheel updates. Semantics label includes ", estimated period day".
4. **Cycle wheel** (signature feature): section 11.4.
5. **Wheel legend:** "Period days" (drop) and "Selected day" (ring), plus "Period: <range> · Cycle: N days".
6. **Info card:** "Next Period" (`in N days` / `Today` / `in 1 day` and `(≈ 5 Dec 2026)`) | "Cycle Length" (`28 days`).
7. **Quick cards:** Mood ("How are you feeling?"), Cramps ("Any symptoms?"), Drugs ("Take any supplements?"). Each shows a "<X> is coming soon 🌸" snackbar. These use Material icons, not the mockup's illustrated icons.
8. **Bottom nav (current code):** four tabs Home / Calendar / Reports / Self-Care in a white rounded bar, with a primary underline under the active tab. Only Home works; the rest show "coming soon". **This is the part being replaced (section 21).**

### 9.6 `app_colors.dart` and `app_theme.dart` ✅ — full code in Appendix B.
`AppTheme.light`: Material 3, colour scheme (primary `#98577F`, secondary `#E9DDF9`, tertiary `#FBD8C6`, surface `#F8E8F0`, onSurface `#7A4E72`, error `#B3426B`), text colours `AppColors.text`, `ElevatedButton` with stadium shape and height 58, `TextButton` in primary.

### 9.7 What the screens do NOT do yet
- No saving. No persistence of name, date, language or settings.
- No period logging, editing, history, or symptom screens.
- No notifications, permissions, or settings.
- Cycle length (28) and period length (5) are **hard-coded defaults**, not user input. The 5-day period length was Claude's default (the mockup showed a band of roughly four to five days).

---

## 10. Pending decision about button style ❓
Welcome and name screens originally used gradient buttons. The user's "Luna colour system" lists the primary action as solid `#98577F`. Claude implemented **solid plum everywhere** and kept `AppColors.ctaGradient` unused. Claude asked whether the user wants gradient or solid in some places. **The user did not answer.** Current state: solid everywhere.

---

## 11. Period calculations

### 11.1 Inputs and defaults
`lastPeriodStart` (nullable), `cycleLength = 28`, `periodLength = 5`. All results are **estimates**; the plan requires telling users predictions may be wrong and cycles vary.

### 11.2 Core helpers (current code)
```dart
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

/// Whole days from [a] to [b] (DST-safe).
int _daysBetween(DateTime a, DateTime b) {
  final ua = DateTime.utc(a.year, a.month, a.day);
  final ub = DateTime.utc(b.year, b.month, b.day);
  return ub.difference(ua).inDays;
}

DateTime _startOfWeek(DateTime d) => _addDays(d, -(d.weekday % 7)); // Sunday
```

### 11.3 Cycle day, period day, next period
```dart
/// Cycle day (1-based) for [d], or null if there is no data for that day.
int? _cycleDay(DateTime d) {
  if (!_hasData) return null;
  final diff = _daysBetween(_start, d);
  if (diff < 0) return null;
  return diff % widget.cycleLength + 1;
}

bool _isPeriodDay(DateTime d) {
  final day = _cycleDay(d);
  return day != null && day <= widget.periodLength;
}

DateTime? get _nextPeriod {
  if (!_hasData) return null;
  final diff = _daysBetween(_start, _today);
  final k = diff < 0 ? 0 : diff ~/ widget.cycleLength + 1;
  return _addDays(_start, k * widget.cycleLength);
}
```
Per selected day, `build` derives the surrounding cycle:
```dart
final diff = _daysBetween(_start, _selected);
final cycleIndex = diff < 0 ? 0 : diff ~/ widget.cycleLength;
cycleStartDate  = _addDays(_start, cycleIndex * widget.cycleLength);
periodEndDate   = _addDays(cycleStartDate, widget.periodLength - 1);
nextPeriodDate  = _addDays(cycleStartDate, widget.cycleLength);
```

### 11.4 The cycle wheel
- **Geometry:** `step = 2π / cycleLength`; day `d` sits at angle `-π/2 + (d-1)·step` (day 1 at 12 o'clock, clockwise). Disc radius `r = size × 0.44`; ring (track) radius `r × 0.86`; track width `r × 0.16`. The period band is an arc from `angle(1) - step/2` sweeping `periodLength × step`.
- **Painted elements (current user version):** soft shadow + white-pink radial disc; light-pink track `0x59F4A6C6` with small white dots for non-period days; inner circle (`r × 0.56`) holding the text; period band gradient `#E8629A→#CF4F86` with the word **"Period"** written along the arc (if `periodLength >= 3`); a white circular **drop marker** at the period start; a smaller white-ringed pink **end marker**; date labels on the wheel at radius `r × 0.67` (start date, end date, and "Next: <d MMM>" at day `cycleLength × 0.72`); a white-ringed plum **selected-day knob** that animates.
- **Fallback labels** when no date is logged: "Day 1", "Day <periodLength>", "Day <cycleLength/2>".
- **Centre text via `_periodInfo` (returns `(title, line1, line2)`):**
  - During the period: title `Period`; line1 `Day X of 5 (3 Nov – 7 Nov)`; line2 `N days left` or `Last day of period`.
  - Otherwise: title `Day X`; line1 `Period in N days (1 Dec)` or `Period starts tomorrow (1 Dec)`; line2 `Period: 3 Nov – 7 Nov`.
  - No data: title `Add date`, "Log your last period" / "to see your cycle".
  - Selected day before first log: `No data`, "This day is before" / "your first log".
- Wheel text sizes scale with the wheel (`wheel × 0.125` for the title, etc.) and sit in a `FittedBox`.

### 11.5 Worked example
`lastPeriodStart = 3 Nov 2026`, cycle 28, period 5:
- Period = 3–7 Nov (days 1–5). Selected 9 Nov → diff 6 → **Day 7**.
- Next period = 3 Nov + 28 = **1 Dec 2026**. From 12 Nov that is **in 19 days**; 12 Nov is **Day 10**.

### 11.6 Known limitations of the maths (Claude's own analysis of the current code)
- Cycles are projected forward by pure repetition (`diff % cycleLength`). The **"period expected / N days late" branch in `_periodInfo` can never run**, because the next period date for any selected day is always after that day. Real late handling needs logged actual periods.
- Dates before `lastPeriodStart` give `null` ("No data"); there is no backwards projection.
- No average-cycle learning from history, no irregular-cycle handling, no user-set cycle or period length.
- Week starts on **Sunday**, hard-coded.

### 11.7 Ovulation / fertile-window logic
An earlier Claude version computed ovulation as `cycleLength − 14` with a fertile window (ovulation −5 to +1) and showed pregnancy-chance text. **The user rejected this and it was removed** (section 18). The plan still lists *optional ovulation estimates, clearly labelled as estimates* under F. ❓ Ask the user before reintroducing any ovulation or fertile-window feature, and never with pregnancy-chance wording.

---

## 12. Notification logic (🔲 PLANNED — nothing is implemented)

### 12.1 Requirements from the plan
- Personality: **funny, relatable, caring** — messages like a best friend.
- Types: period-near reminders, mood check-ins, self-care reminders, yoga and relaxation prompts, water reminders, gentle support messages.
- **Rotate** messages; respect **quiet hours**; allow users to choose **preferred tone** and **frequency**; must be **disable-able**.
- Ask for notification permission **at an appropriate time**, not blindly at launch.
- Respect privacy (sensitive health context).

### 12.2 The six original examples (user's text, verbatim)
| Type | Message |
|---|---|
| Period is near | "Bestie 👀 Your period may be on its way. Your bag better be prepared." |
| Mood check | "Psst… you and your mood okay? Nilah is checking on you 🫶" |
| Self-care | "Your to-do list can wait 5 minutes. Your breathing session is calling. 😌" |
| Yoga | "Me: just one stretch. Also me: suddenly a yoga influencer. 🧘‍♀️😂" |
| Water reminder | "Bestie, water. Coffee cannot do every job. 💧😭" |
| Gentle support | "Plot twist: today's achievement is simply taking care of yourself. 💗" |

Note the mood-check message names **Nilah**; update it if the brand becomes Luna (❓ naming).

### 12.3 Technical notes from the plan's learning list
Scheduling, notification channels, permissions, **time zones**, quiet hours, **battery restrictions**, and testing.

### 12.4 💡 Suggestions from Claude (not approved)
- Use `flutter_local_notifications` + `timezone`.
- **Test on a real Android phone early**: battery-saver settings on many Android phones delay or block notifications.
- A message library keyed by type, tone and language, with a "last shown" record so messages rotate rather than repeat.
- Not decided: how many days before the predicted period the "period near" reminder fires, the default quiet hours, the default frequency, the tone names.
- The home bell currently only shows a "coming soon" snackbar; the red dot is static decoration.

### 12.5 Health-wording rule
Estimates only; a funny tone must not trivialise severe symptoms. Wellness content must say it is a supportive option, not treatment, and must advise seeking medical care for severe or unusual pain.

---

## 13. Wellness, music, journal, education (🔲 PLANNED)
All of this is in the plan; **no design or code exists** beyond the nav labels and three home quick-action stubs. Claude's only sequencing advice: yoga and breathing first, then music, then language, then premium. Claude also advised having a doctor or qualified person review pain-relief and yoga text before launch.

---

## 14. Data and backend

### 14.1 Local-first (plan)
Local database/storage holds cycle dates, preferences and logs on the device. Store cycle entries, symptoms, user preferences and notification settings; handle edits, deletions and **data migration safely**. 💡 Claude suggested `shared_preferences` for the immediate name/date saving, and `drift` (SQLite) for the real data model.

### 14.2 Backend (plan only — nothing designed)
| Item | Plan |
|---|---|
| Java + Spring Boot | **Optional** REST API |
| PostgreSQL | **Optional** cloud data storage |
| When | Only when a feature genuinely needs it: account-based synchronisation or subscription verification |
| Learning list | REST APIs, Spring Boot, authentication, PostgreSQL, validation, authorization, secure data handling, API testing |

**There are no endpoints, schemas, auth choices or hosting decisions.** ❓ All open. The plan states: *"Don't collect or upload [menstrual data] unnecessarily."*

---

## 15. Premium subscription and payments

### 15.1 What the plan says
- Proposed price **₹15/month**. Explicitly *"proposed features, not a confirmed pricing or subscription model."*
- **Validate willingness to pay with real users** before investing heavily in payments or infrastructure.
- Account for **app-store fees, taxes and other operating costs** when estimating revenue.
- Technology list: **Google Play Billing** for Android premium subscriptions; backend only if needed for subscription verification.
- Potential premium features (proposed): advanced cycle history and insights, more reminder customisation, expanded yoga/meditation/relaxation libraries, optional cloud backup and synchronisation.

### 15.2 💡 Claude's guidance (general knowledge, not a decision; verify current Google documentation)
- Skip accounts, backend and subscription for **v1**; add them only after real users show they want them.
- Typical later architecture: the Flutter app buys through Google Play Billing (for example `in_app_purchase`); the purchase token is verified server-side against the Google Play Developer API; an entitlement is stored; the app unlocks premium features. A fully client-side check is possible but weaker.
- Verify the minimum price point and the exact fee and tax treatment for ₹15 in Play Console before assuming revenue. No figures were established in the conversation.

---

## 16. Privacy and security (plan)
Data minimisation, encryption where appropriate, secure backups, consent, data deletion, protecting sensitive information. Features: local-first storage, data export and deletion controls, optional accounts and cloud backup, a clear privacy policy and transparent data practices. Analytics only **with consent**. Users should understand how their data is stored and controlled.

---

## 17. Play Store launch (from conversation)
- Google Play developer account: **one-time US$25 fee** (stated by Claude).
- Google **may require a closed test with a minimum number of testers for a set number of days** before production on a personal account. Claude told the user to **check the current rule when registering** and recruit testers early (friends, family, classmates).
- Needed: privacy policy, app icon, screenshots, store description, signed build, closed-test feedback.
- Package name must be final before publishing (section 8.6).
- First milestone is **not** the whole vision: a working app users can try (success checklist in Appendix A).

---

## 18. The user's corrections and instructions (chronological) and the "do NOT" list

### 18.1 Chronology
| # | Date (IST) | User instruction or correction |
|---|---|---|
| 1 | 29 Oct | Shares plan. "Ready to spend 1 hr per day", wants step-by-step help to reach the Play Store. |
| 2 | 29 Oct | "day one done" |
| 3 | 29 Oct | Screenshot of project tree (`period_tracker`, only `lib/main.dart`); asks how to create folders and files for different screens. |
| 4 | 29 Oct | Sends welcome mockup, asks to "convert into welcome_screen.dart". |
| 5 | 29 Oct (11:27) | Sends the name-screen mockup: "i need the exact ui code". The name screen later becomes the user's favourite. |
| 6 | 9 Nov | Pastes old `main.dart`, asks how to add the name screen. |
| 7 | 9 Nov | "i love the second name screen **load the design ui in your memory**." (Claude explained memory was off and recommended committing files + `DESIGN.md`.) |
| 8 | 9 Nov | Welcome screen "looks different" from the first mockup. **Change nilah into Luna**; second picture was Claude's code; "i need exact code" of the first image's UI, colours and **button colours**. |
| 9 | 9 Nov | Pastes the **Luna colour system** and the "don't look medical" recommendation; says to continue with the home dashboard next. |
| 10 | 9 Nov | "i have 3 files only which to add this code" (Claude: the theme code goes in **new** files in `lib/core/`). |
| 11 | 9 Nov | **Change welcome code to the suggested colour style; lotus first, emotional message directly underneath; keep float gentle/slow; use wording "Your body has its own rhythm. We're here to help you understand it."** |
| 12 | 9 Nov | "is okk for the name screen or update anything?" (Claude migrated it to `AppColors`.) |
| 13 | 9 Nov | Sends cycle-setup mockup: "if user enter the name via page 2 its shows hey halin like exact ui". |
| 14 | 9 Nov (19:42) | Sends home mockup: convert to code. Pastes the wheel description and **recommends the wheel be interactive: changing the selected day on the weekly calendar must update the wheel.** |
| 15 | 9 Nov (21:30) | Screenshot of the wheel (Day 7): "everything was good but this center period calendar did not clean… **im creating periods reminder app not a pregnancy change, clean this UI**." |
| 16 | 10 Nov | Attaches the updated home screen code; "**remove Reports and Self-Care** … use the navigation style in your reference image. Your new bottom navigation will be:" (message truncated). Reference image = Home, Calendar, Care, Relax. |
| 17 | 12 Nov | Moving to a new Claude account (usage limit reached); requests this handoff file. |

### 18.2 Things the user explicitly said NOT to implement
1. **Pregnancy-chance messaging.** *"im creating periods reminder app not a pregnancy change."* The wheel must never say "Low/Higher chance of getting pregnant" or show fertile-window pregnancy wording. This was removed from the home screen and its code (`_wheelMessage`) deleted.
2. **No traditional-medical look.** "Don't make Luna look like a traditional medical application" (user-pasted recommendation).
3. **Do not completely change the palette.** Keep pink + lavender + plum.
4. **Do not add more text to the welcome screen** than the approved two lines.
5. **Reports and Self-Care tabs are to be removed** from the navigation.

### 18.3 Constraints from the project plan (user's own document)
- No guaranteed-treatment claims; always "supportive options."
- Don't collect or upload sensitive menstrual data unnecessarily.
- Don't rely on colour alone for health information.
- Backend, accounts, cloud sync, and the ₹15 subscription only when justified, after user validation.
- Use original or properly licensed audio only.
- Predictions must be labelled as estimates; allow users to correct dates.

### 18.4 Claude's recommendations the user did not contradict (💡)
Skip backend/accounts/subscription in v1; use ARB localization from day one; use `go_router`, `riverpod`, `drift`; test notifications on a real device; check Play Store name conflicts; change the Android application ID early.

---

## 19. Bugs, risks and known issues

| # | Issue | Severity / note |
|---|---|---|
| 1 | **No persistence:** name and last-period date live only in memory; app restarts at the welcome screen every launch. | High; next task |
| 2 | Android `applicationId` likely still `com.example.period_tracker`; Play will reject it. | High before launch |
| 3 | Brand name unresolved (Luna vs Nilah); Luna may conflict with existing apps. | High before launch |
| 4 | None of the code was compiled by Claude. Fix any analyzer errors the user reports. | Ongoing |
| 5 | The "late period" branch in `_periodInfo` is unreachable (11.6). | Medium |
| 6 | Cycle and period length are hard-coded (28 / 5); no user input. | Medium |
| 7 | The user's `home_screen.dart` has diverged from Claude's last version; do not overwrite it with an older copy. | Medium |
| 8 | Colours are partly hard-coded (7.4); only part of the screens use `AppColors`. | Low |
| 9 | All strings hard-coded in English; no ARB or Tamil. | Medium |
| 10 | Contrast ratios in `DESIGN.md` were hand-estimated, not measured. | Low; re-check |
| 11 | Illustrations are code-drawn approximations; `home_girl.png` / `name_girl.png` assets are not provided. | Cosmetic, user wants "exact" |
| 12 | Fonts are generic (`serif`, Roboto) vs the mockups' custom fonts. | Cosmetic |
| 13 | Home quick cards use Material icons, not the mockup's illustrated icons (the mockup's cramps icon was underwear). The label "Drugs" follows the mockup. | Cosmetic |
| 14 | The old nav shows a "Reports" tab that is being removed (section 21). | In progress |
| 15 | Date picker only allows the last year; first-time users who forgot earlier can pick "later". | Design decision, not asked about |
| 16 | The user's SDK must be 3.7 or newer (wildcard `_` parameters in the user's home file). | Observation |
| 17 | GitHub push status unknown; the user's Day 2 plan named the repo `nilah`, while the actual project is `period_tracker`. | Ask |

---

## 20. Next development tasks (in order)

1. **Finish the bottom-nav change** (section 21) and confirm Home / Calendar / Care / Relax.
2. **Save name and last-period date** locally (`shared_preferences`), and skip onboarding on later launches.
3. Commit everything to Git/GitHub, including `DESIGN.md`.
4. Resolve the **brand name** and fix the Android **application ID**.
5. Move remaining hard-coded colours into `AppColors` (7.4).
6. **Phase 3:** Calendar tab (monthly view), period start/end logging, editing/correcting dates, cycle history, symptoms/mood/energy, local database (`drift`).
7. Let the user set cycle and period length (and learn from history); implement real "late" handling.
8. **Phase 4:** notifications (permissions, quiet hours, preferences, rotating library).
9. Export transparent PNGs for the exact lotus / girl art and wire them in; consider `google_fonts`.
10. ARB localization scaffold (English now, Tamil later).
11. Phases 5–8 per the plan.

---

## 21. 🟡 Bottom navigation change — spec for the new Claude

**User request (10 Nov):** remove **Reports** and **Self-Care**; use the nav style from the reference image. Tabs: **Home, Calendar, Care, Relax** (inferred from the image because the user's list was cut off — confirm with the user).

**What the reference image shows:** a flat, full-width, near-black bar with a thin top divider; four equal tabs; **outlined icons** above short labels; **active tab (Home) in pink with a bold label**, inactive tabs grey; no pill, no underline.

**Current code to replace:** `_bottomNav()` in `HomeScreen` (white rounded bar, 76 px high, 14 px side margin, items Home/Calendar/Reports/Self-Care, primary underline indicator). Home works; other tabs call `_soon(label)` and show "<label> is coming soon 🌸".

**💡 Suggested implementation (nothing delivered yet):**
- Icons (outlined): `Icons.home_outlined`, `Icons.calendar_month_outlined`, `Icons.favorite_border_rounded`, `Icons.music_note_outlined`. Labels: Home, Calendar, Care, Relax.
- Colours: active `#E8629A` (already used in the wheel; about 6.6:1 on black), inactive `#9A9A9A`, bar `#000000`, divider `#2A2A2A`. These nav colours are Claude's choices from the screenshot, not user-specified.
- Use `Material(color: ...)` as the bar background (not a `Container(color: ...)`) so `InkWell` splashes are visible.
- The bar spans edge to edge, so use `SafeArea(bottom: false)` for the page content and add `MediaQuery.of(context).padding.bottom` as padding inside the nav, otherwise the pink gradient shows below the dark bar.
- Remove the underline indicator. Keep `Semantics(button: true, selected: ...)`. Keep tap height at least 48 (about 64 suggested).
- ❓ A black bar on the light pink app looks stark; the user did ask for the reference style. If it looks wrong on a device, offer the same layout with a light bar (white, active `#98577F`) via a single colour constant.

---

## 22. What the user must carry over to the new account

The new Claude will not see the old files. Ask the user to attach or upload:
1. The **latest `lib/features/home/home_screen.dart`** (user's version, not any older Claude copy).
2. `lib/main.dart`, `lib/core/app_colors.dart`, `lib/core/app_theme.dart`, the three onboarding files, and `DESIGN.md` (or just zip `lib/` and `DESIGN.md`, or share the GitHub repo).
3. The five reference images listed in section 7.10 (welcome, name, cycle setup, home, nav reference).
4. This file.

Suggested first message in the new account: *"Read LUNA_TRACKER_PROJECT.md. Here are my current files and mockups. Next task: finish the Home / Calendar / Care / Relax bottom navigation, then save the name and period date locally."*

---

## 23. Working agreements and behaviours that worked
- Open with a one-sentence statement of what you are about to do, then do it. Deliver Dart files as downloadable files and also say exactly where each goes in `lib/`.
- Always say whether to **hot reload** or **hot restart** (`main.dart` changes need restart).
- Keep the tone friendly and concise; the user is a beginner at Flutter but strong in Java.
- When a mockup is supplied: match layout, text, colours and wording exactly; draw art in code unless the user provides PNG assets; keep `AppColors` for new colours.
- Never reintroduce pregnancy or fertile-window wording.
- State plainly that code has not been compiled unless it has been.
- Give estimates and disclaimers on cycle predictions.

---

# APPENDIX A — The user's original project plan (verbatim content, formatting cleaned)

*(The plan also existed as an attached "Periods_Tracker" Project description on claude.ai.)*

## 1. Project identity
**Nilah** — Menstrual Health & Wellness Companion — Flutter mobile app

**Mission:** Make menstrual wellness easier to understand and manage by combining useful tracking, personalized self-care, and an emotionally supportive experience.

**Vision:** Build a trusted, privacy-conscious wellness brand that users want to keep on their phones because it helps them feel informed, supported, and understood.

**Product personality:** Friendly, funny, caring, relatable, modern, and respectful.

## 2. Your main goals
- **Goal 1 — Help users understand their cycles.** Track period dates, cycle history, symptoms, and estimated upcoming periods. Clearly communicate that predictions can be inaccurate and cycles can vary.
- **Goal 2 — Make notifications a signature feature.** Create funny, personalized, rotating reminders that feel like messages from a best friend, while respecting privacy, quiet hours, and notification preferences.
- **Goal 3 — Support everyday wellness.** Offer gentle yoga, breathing exercises, relaxation music, and practical self-care suggestions that may help users manage discomfort and stress.
- **Goal 4 — Serve the intended audience.** Plan Tamil and English language support, accessible content, simple navigation, and a welcoming design for users with different levels of health knowledge.
- **Goal 5 — Launch a sustainable product.** Build the first version yourself, validate whether people find it useful, launch Android first if practical, and explore revenue through a planned ₹15/month premium subscription.

## 3. Planned features
These are your planned features, organized so the app can grow in stages rather than becoming too difficult to build at once.

### A. Onboarding and personalization
- Screen 1: Nilah logo and welcome animation.
- Screen 2: Ask the user what name to use.
- Screen 3: Personalized greeting, such as "Hey, Halin!"
- Optional language preference and cycle setup.
- Ask permission for notifications at an appropriate time.

### B. Period tracking and calendar
- Log period start and end dates.
- Show cycle day and estimated next period.
- View a monthly calendar and cycle history.
- Record symptoms, mood, and energy.
- Allow users to correct dates and predictions.

### C. Nilah Bestie Notifications — signature feature
Your chosen notification personality is funny, relatable, and caring.
- Period-near reminders.
- Mood check-ins.
- Self-care reminders.
- Yoga and relaxation prompts.
- Water reminders.
- Gentle support messages.

Notifications should rotate, respect quiet hours, and allow users to choose their preferred tone and frequency.

Your six original notification examples 💗
- Period is near: "Bestie 👀 Your period may be on its way. Your bag better be prepared."
- Mood check: "Psst… you and your mood okay? Nilah is checking on you 🫶"
- Self-care: "Your to-do list can wait 5 minutes. Your breathing session is calling. 😌"
- Yoga: "Me: just one stretch. Also me: suddenly a yoga influencer. 🧘‍♀️😂"
- Water reminder: "Bestie, water. Coffee cannot do every job. 💧😭"
- Gentle support: "Plot twist: today's achievement is simply taking care of yourself. 💗"

### D. Period pain relief and yoga
- Beginner-friendly stretching and yoga guides.
- Breathing and relaxation exercises.
- Warm-compress and other practical self-care suggestions.
- Symptom logging to understand personal patterns.
- Clear guidance to seek medical care for severe or unusual pain.

The app should describe these as supportive options, not guaranteed treatments.

### E. Music and relaxation
- Relaxing audio and calming soundscapes.
- Guided meditation and breathing.
- Short relaxation sessions and sleep support.
- An audio player with play, pause, and duration controls.

Use original or properly licensed audio.

### F. Journal, insights and education
- Mood and symptom journal.
- Personal cycle history and patterns.
- Tamil and English educational content.
- Optional reminders and notification settings.
- Optional ovulation estimates, clearly labelled as estimates.

### G. Privacy, accounts and premium
- Local-first storage for personal tracking.
- Data export and deletion controls.
- Optional accounts and cloud backup.
- Premium features and subscription management.
- A clear privacy policy and transparent data practices.

## 4. App navigation and screen plan
The app may have many screens, but its main navigation should remain simple.
- **Home** — Daily overview
- **Calendar** — Cycle tracking
- **Wellness** — Yoga and relief
- **Relax** — Music and breathing

Additional screens: onboarding, period logging, symptom journal, education, notification settings, profile, privacy, and premium subscription.

## 5. Technology and architecture
You are building Nilah yourself, using your existing Java backend knowledge while learning Flutter app development.

| Technology | Purpose |
|---|---|
| Flutter + Dart | Mobile UI and app logic |
| Android Studio | Development and Android testing |
| Local database/storage | Save cycle dates, preferences and logs on the device |
| Local notifications | Schedule reminders on the phone |
| Java + Spring Boot | Optional REST API backend |
| PostgreSQL | Optional cloud data storage |
| Google Play Billing | Android premium subscriptions |
| Git + GitHub | Version control and backups |

Recommended architecture: Start with a Flutter application that works offline. Keep period tracking and basic notifications on-device. Add Spring Boot and PostgreSQL only when features genuinely need a backend, such as account-based synchronization or subscription verification.

Because menstrual data is sensitive, don't collect or upload it unnecessarily. Build privacy and secure storage into the design from the beginning.

## 6. Business and revenue goals
Your initial business idea is to offer Nilah at a proposed ₹15/month premium price.

A sensible approach is to make the core tracking experience reliable first, then test which advanced features users would pay for.

Potential premium features could include:
- Advanced cycle history and insights.
- More customization of reminders.
- Expanded yoga, meditation and relaxation libraries.
- Optional cloud backup and synchronization.

These are proposed features, not a confirmed pricing or subscription model. Validate willingness to pay with actual users before investing heavily in payments or infrastructure. Also account for app-store fees, taxes, and other operating costs when estimating revenue.

## 7. Development roadmap
Build in eight phases. Finish one working milestone before adding the next. The order can be adjusted after testing.
1. **Phase 1 — Project foundation.** Set up Flutter, project folders, reusable colors and components, and the three onboarding screens.
2. **Phase 2 — Home and navigation.** Build the home dashboard and navigation between the main sections.
3. **Phase 3 — Core period tracking.** Add period logging, calendar views, cycle calculations and local storage.
4. **Phase 4 — Notifications.** Implement scheduled reminders, permission handling, quiet hours, user preferences and the rotating Nilah message library.
5. **Phase 5 — Wellness features.** Add yoga guides, pain-support information, breathing exercises and a basic music player.
6. **Phase 6 — Language and personalization.** Add Tamil and English, accessible content, mood tracking, and settings.
7. **Phase 7 — Testing and privacy.** Test predictions, offline behaviour, notifications, accessibility, sensitive-data handling and different Android devices.
8. **Phase 8 — Launch and growth.** Prepare the store listing, privacy policy, user feedback process, and an optional backend and subscription when justified.

## 8. Subjects you need to learn
- **Flutter and Dart:** widgets, layouts, navigation, state management, forms, animations, reusable components and responsive UI.
- **UI/UX design:** user flows, wireframes, typography, color systems, accessibility, interaction design and usability testing. Your planned one hour of daily UI/UX practice can help here.
- **Local storage and data modelling:** store cycle entries, symptoms, user preferences and notification settings; handle edits, deletions and data migration safely.
- **Android notifications:** scheduling, notification channels, permissions, time zones, quiet hours, battery restrictions and testing.
- **Backend development:** REST APIs, Java Spring Boot, authentication, PostgreSQL, validation, authorization, secure data handling and API testing.
- **Privacy and security:** data minimization, encryption where appropriate, secure backups, consent, data deletion, and protecting sensitive information.
- **Testing and release:** unit tests, widget tests, device testing, error handling, app signing, store publishing and feedback-driven improvements.
- **Product and business skills:** user interviews, feature prioritization, marketing, pricing, analytics with consent, customer support and product iteration.

## 9. Design principles
Your planned visual direction is a soft, modern, floral interface.
- Soft pink — Warmth and care — `#DDA0C7`
- Lavender — Calm and focus — `#AF83E8`
- Sage green — Wellness and rest — `#76B98A`
- Peach — Friendly highlights — `#E9A36E`

Use rounded cards, clear typography, gentle animation and accessible contrast. The design should feel welcoming without making the app childish or relying on colors alone to communicate health information.

## 10. What success looks like
Your first milestone isn't to finish every planned feature. It's to have a working app that users can try.
- [ ] The three onboarding screens work.
- [ ] Users can record and edit period dates.
- [ ] Cycle estimates are presented responsibly.
- [ ] Local data persists after closing the app.
- [ ] Notifications work at the intended time and can be disabled.
- [ ] The first wellness activities are useful and easy to navigate.
- [ ] Users understand how their data is stored and controlled.
- [ ] Feedback from real users guides the next version.

Measure success through usability, reliability, retention, user feedback and — once you have enough consenting users — whether the app genuinely helps them manage their routines.

## Your project summary
Nilah is a Flutter-based menstrual health and wellness app designed to combine period tracking, cycle predictions, playful personalized notifications, yoga, pain-relief support, music, mood tracking, and self-care in a single mobile experience. The initial audience is Tamil Nadu, with planned Tamil and English support. The app will start with local-first tracking and expand to optional Java Spring Boot APIs, PostgreSQL, cloud backup, and a proposed ₹15/month premium subscription when needed. Its distinguishing feature is its funny, caring notification personality, balanced with responsible health guidance and strong privacy protections.

**Your immediate priority:** Build the onboarding and navigation foundation, then complete period tracking and notifications before expanding into all the wellness features. This gives Nilah a usable core while preserving your larger vision.

---

# APPENDIX B — Small files in full

## `lib/core/app_colors.dart`
```dart
import 'package:flutter/material.dart';

/// Luna design system colors.
///
/// Use these everywhere instead of hard-coded hex values so the whole
/// app stays consistent (onboarding, dashboard, calendar, settings).
class AppColors {
  AppColors._();

  // Core palette
  static const background = Color(0xFFF8E8F0); // primary background
  static const primary = Color(0xFF98577F); // buttons, primary actions
  static const secondary = Color(0xFFE9DDF9); // cards, soft surfaces
  static const period = Color(0xFFF4A6C6); // period days in the calendar
  static const text = Color(0xFF7A4E72); // main text
  static const warmAccent = Color(0xFFFBD8C6); // highlights

  // Supporting colors
  static const onPrimary = Colors.white;
  static const textMuted = Color(0xFF80587C); // secondary text (AA on background)
  static const lavender = Color(0xFFA98BEB); // gradient start, focus rings
  static const lavenderSoft = Color(0xFFD5BDEB); // borders
  static const sage = Color(0xFF76B98A); // wellness / rest
  static const white = Colors.white;

  // Gradients
  static const ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF9B72DC), Color(0xFFB56BC6)],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFDEFF3), Color(0xFFF8E8F0), Color(0xFFFCEFEA)],
  );
}
```

## `lib/core/app_theme.dart`
```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared sizes so screens feel consistent.
class AppSizes {
  AppSizes._();

  static const double radiusCard = 24;
  static const double radiusPill = 30;
  static const double buttonHeight = 58;
  static const double screenPadding = 24;
}

/// Luna app theme. Use it in main.dart: `theme: AppTheme.light`.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.text,
      tertiary: AppColors.warmAccent,
      onTertiary: AppColors.text,
      surface: AppColors.background,
      onSurface: AppColors.text,
      error: Color(0xFFB3426B),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
```

## `DESIGN.md` (project root)
```markdown
# Luna Design Guide

Luna is a comforting self-care companion, not a medical app.

## Feel
- Comfort rather than anxiety
- Understanding rather than judgement
- Privacy rather than exposure
- Self-care rather than medical complexity

## Colors (lib/core/app_colors.dart)
| Role | Hex | Use |
|---|---|---|
| Background | #F8E8F0 | Screen backgrounds |
| Primary | #98577F | Buttons, primary actions |
| Secondary | #E9DDF9 | Cards, soft surfaces |
| Period | #F4A6C6 | Period days in calendar |
| Text | #7A4E72 | Main text |
| Warm accent | #FBD8C6 | Highlights |
| Text muted | #80587C | Secondary text |
| Lavender | #A98BEB | Gradients, focus |
| Sage | #76B98A | Wellness / rest |

## Style
- Rounded cards (radius 24), pill buttons and fields (radius 30)
- Button height 58, screen side padding 24
- Soft gradients, floating petals, gentle animation
- Serif headings, friendly sans body text
- Friendly, caring wording; no clinical jargon

## Accessibility
- Body text on background is about 5.6:1 contrast; white on primary is about 5.2:1
- Never rely on color alone for cycle information: use an icon or shape
  (for example a drop for period days, a dot for predicted days, a ring for today)
  plus a text label
- The pink period color is light, so always pair it with a border or icon
- Minimum tap target 48x48
- Predictions are always labelled "estimate"

## Screens built
1. welcome_screen.dart
2. name_screen.dart
```
(Update "Screens built" to also list `cycle_setup_screen.dart` and `home_screen.dart`.)

---

# APPENDIX C — Quick facts for fast orientation

- Example user name in all mockups: **Halin** (it is a mockup name; the user's real name is not confirmed to be Halin).
- Mockup example date used: **9 November 2026**.
- Defaults in code: `cycleLength = 28`, `periodLength = 5`.
- Home week starts Sunday; wheel starts at 12 o'clock, clockwise.
- Welcome button text is "Let's Begin" (capital B); the name and cycle screens use "Continue".
- Tagline on every logo: `PERIOD TRACKER`.
- No dependencies in `pubspec.yaml` beyond Flutter; no assets declared.
- Optional assets the code looks for: `assets/images/name_girl.png`, `assets/images/home_girl.png` (declare `assets: - assets/images/` in `pubspec.yaml`).
- Claude Project the plan was attached to: "Periods_Tracker" (0 docs in it).
- Android Studio, Dart 3.7+ (inferred), target Android first.
