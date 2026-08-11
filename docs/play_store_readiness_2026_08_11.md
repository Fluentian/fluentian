# Play Store Readiness — Action Plan (2026-08-11)

Source: full codebase audit run tonight. Verdict at the time of writing: **not ready to submit**, 6 real blockers. This file tracks each one to closure.

Legend: 🔧 code (I can do this) · 🌐 external action (only you can do this — dashboard/account/credential) · ❓ needs clarification before it can be scoped

---

## 1. 🔧 Wrong application ID — blocks submission entirely

`android/app/build.gradle.kts` still has `applicationId = "com.example.fluentian"` (the Flutter template default, never changed). Google Play rejects `com.example.*`, and once a real ID is set and the app is first uploaded, it can **never** be changed again.

**Steps:**
- [ ] Decide the final package name (e.g. `com.binovatechnologies.fluentian`) — 🌐 this is a one-way decision, flagging so you confirm it rather than me picking it
- [ ] Update `applicationId` and `namespace` in `android/app/build.gradle.kts`
- [ ] Regenerate `google-services.json` from the Firebase Console for the new package name — 🌐 requires Firebase Console access
- [ ] Update `ios/Runner.xcodeproj` bundle identifier to match, if iOS is also being submitted alongside

## 2. 🌐 No release signing keystore

`build.gradle.kts` expects `key.properties` for release signing; it doesn't exist. A release build cannot be produced right now.

**Steps:**
- [ ] Generate a keystore (`keytool -genkey -v -keystore <path> -keyalg RSA -keysize 2048 -validity 10000 -alias fluentian`) — 🌐 you should run and hold this yourself; if this keystore is ever lost, the app can never be updated on Play again under the same listing. I can write the `key.properties` wiring in `build.gradle.kts` (🔧) once you have the keystore file + passwords, but generating/storing the actual keystore is not something I should do unilaterally
- [ ] Store the keystore + passwords somewhere durable (password manager, not just this machine)
- [ ] Wire `key.properties` into `build.gradle.kts`'s `signingConfigs` block (🔧, once keystore exists)

## 3. 🔧 No web-reachable account-deletion page

Play requires a public web URL for account deletion, reachable without installing the app. In-app deletion already works; the web equivalent doesn't exist anywhere.

**Steps:**
- [ ] Add a `/account-deletion` (or similar) static page to `fluentian-website` explaining how to delete an account (link to in-app flow, or a simple hosted form) — 🔧
- [ ] Push → Vercel auto-deploys (per existing deployment setup) — 🔧, no manual dashboard step needed if auto-deploy is already wired
- [ ] Add this URL to the Play Console's Data Safety section at submission time — 🌐

## 4. 🔧 `/terms` returns 404 in production

Code exists (`backend/app/legal.py`, routed in `backend/app/main.py`), just not deployed yet.

**Steps:**
- [ ] Deploy backend (push already done tonight, migration + restart in progress as of this writing) — 🔧
- [ ] Smoke-test `https://api.fluentianapp.binovatechnologies.com/terms` returns 200 — 🔧

## 5. 🔧 Minification silently off

`isMinifyEnabled` is never set to `true` in the release build type, so existing ProGuard rules do nothing. Not a rejection cause by itself, but a "works in debug, crashes in release" risk if enabled later without matching Firebase keep rules.

**Steps:**
- [ ] Set `isMinifyEnabled = true` (and `isShrinkResources = true`) in the release build type — 🔧
- [ ] Add Firebase-specific ProGuard keep rules to `proguard-rules.pro` (Firebase Auth, Firestore/Analytics if used, reflection-based bits) — 🔧
- [ ] Actually build and run a real release build end-to-end to confirm nothing breaks (see "Release verification" below) — 🔧, but blocked on #2 (needs a real keystore to produce a signed release build)

## 6. 🔧 Age requirement (13+) stated but not enforced

Privacy policy and terms both say 13+; birth date is collected at onboarding but nothing actually enforces a minimum age, client or server side.

**Steps:**
- [ ] Add a maximum-date bound to the `CupertinoDatePicker` in `about_you_setup_screen.dart` (`maximumDate` should be "today minus 13 years", not just "today") — 🔧
- [ ] Add server-side validation in `backend/app/schemas/user.py`'s `_validate_birth_date` rejecting birth dates that make the user under 13 — 🔧
- [ ] Decide what happens if a user fails this check (block registration entirely vs. block only this onboarding step) — this is a product call, flagging before I implement a specific behavior

## Minor (not blocking)
- [ ] Add an adaptive icon (`mipmap-anydpi-v26`) instead of only legacy per-density PNGs — 🔧, cosmetic/best-practice only

---

## ❓ New report: "time selector in goal setting screen during registration doesn't work"

Checked `lib/screens/goal_setup_screen.dart` (the actual "Set your daily goal" step, step 2 of registration) — it currently has **no time/date picker widget at all**, just static XP-goal tiles (5/10/15/20 min presets you tap to select). No selector exists there to be broken.

The closest actual picker in the registration flow is the **birth-date `CupertinoDatePicker`** on the next step (`about_you_setup_screen.dart`, step 3, "About You") — from a static read, its state-handling looks correct (no obvious bug), but I haven't run it on a device.

I can't reproduce or scope this from the code alone. Need one of:
- A screen recording or exact repro steps, or
- Confirmation of which screen/step you mean (if it's actually the birth-date picker, or a reminder-time picker that used to exist in Settings and might still be broken there)

---

## Timeline

- Backend deploy (items covered: #4) is already in progress as of this writing — migrating, restarting, smoke-testing.
- Code-related items (#1 partial, #3, #4, #5 partial, #6, minor icon) will be implemented starting **2 hours 38 minutes from now**, per your instruction. (Note: my scheduling tool caps a single wakeup at 1 hour, so I'm chaining three wakeups back-to-back to land on the full 2h38m rather than starting early.)
- Items requiring your direct action (final applicationId decision, keystore generation, Play Console setup) are called out above and don't block me from finishing everything else in the meantime.
- Once implemented: build and run the app in **release mode** (not debug) to catch exactly the "works in debug, breaks in release" class of bug the minification finding warns about, then check back on it every 20 minutes.
