# Restaurant Manager Pro

A Flutter Android app for QSR/restaurant managers with seven features:

1. **Labor cost calculator** — add hours × rate rows against the day's sales; shows labor % vs target and, when over, how many hours to cut at the average rate.
2. **Food cost calculator** — opening stock + purchases − closing stock = COGS; shows food cost % vs target with variance in currency.
3. **Staff scheduling** — weekly roster by day with time-picker shifts, per-day hour totals and each employee's running weekly hours (overtime visibility). Saved on device.
4. **Daily shift checklists** — Opening, Shift change and Closing templates with progress bars; state resets automatically each day; custom items can be added per day.
5. **KPI dashboard** — log daily sales, labor cost, food cost and transactions; summary tiles vs 14-day averages plus sales / labor % / food % trend charts.
6. **Profit estimator** — quick monthly P&L model (food %, labor %, royalties %, marketing %, fixed costs) with margin.
7. **AI coach** — a chat with Claude prompted as a multi-unit restaurant operations coach; conversation persists on device.

Currency symbol defaults to R (Rand) and is changeable in Settings.

---

## Setup

Same procedure as any Flutter project:

```bash
cd restaurant_manager_pro
flutter create . --platforms=android --org com.yourcompany
flutter pub get
flutter run
```

Then add the internet permission to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

and set `android:label="Restaurant Manager Pro"` on the `<application>` tag. Without the internet permission the AI coach fails in release builds only — an easy trap.

The six calculator/tracker features work fully offline. Only the AI coach needs API access: configure either your Anthropic API key (testing) or a deployed proxy URL (production) in Settings. The `backend_proxy/` folder contains the same minimal Node.js proxy as the Study Helper app — never ship an API key inside the APK; deploy the proxy with the key in a server-side environment variable, and add rate limiting before launch.

## Icon, signing, and release build

Identical steps to the AI Study Helper README, summarized:

1. 1024×1024 PNG at `assets/icon/icon.png` (+ `icon_fg.png`), then `flutter pub run flutter_launcher_icons`.
2. Generate a keystore with `keytool`, create `android/key.properties`, wire the `signingConfigs` block into `android/app/build.gradle`. Back up the keystore — losing it means you can never update the app.
3. `flutter build appbundle --release` → upload `build/app/outputs/bundle/release/app-release.aab`.

## Play Store checklist

1. Google Play developer account ($25 once; new personal accounts need a 14-day closed test with 12+ testers before production).
2. Privacy policy URL — required. This app stores business data locally and sends AI coach messages to an external API; the policy must say so.
3. Data safety form — declare: user-entered text sent off-device for AI processing; roster/KPI data stored locally only; nothing sold or used for ads.
4. Target audience — this one is genuinely "business professionals / 18+", so the questionnaire is simpler than a consumer app.
5. Generative AI policy — Google requires an in-app way to report offensive AI output; add a "Report a problem" mailto link in the coach screen before submitting.
6. Store listing: title (30 chars), short description (80), full description (4000), 2+ screenshots, 512×512 icon, 1024×500 feature graphic.

## Project structure

```
lib/
  main.dart                        App shell + theme
  models/models.dart               Shift, ChecklistItem, KpiEntry, ChatMessage
  services/storage.dart            Local persistence for everything
  services/claude_service.dart     AI coach API call
  screens/
    home_screen.dart               Feature menu
    labor_cost_screen.dart
    food_cost_screen.dart
    scheduling_screen.dart
    checklists_screen.dart
    kpi_dashboard_screen.dart
    profit_estimator_screen.dart
    coach_screen.dart
    settings_screen.dart
backend_proxy/                     Node.js proxy for the AI coach
```
