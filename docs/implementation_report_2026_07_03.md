# Fluentian Implementation Report - July 3, 2026

## Summary

This single report covers the frontend and backend work completed for the Fluentian learner experience. The main updates were cleaner learning UI, reliable server-owned heart refills, Firebase Google sign-in, and supporting polish across the app.

## Features and Updates

- Refined the home screen learning experience by removing a redundant continue/enroll card above the final assessment.
- Redesigned the Continue learning cards with stronger lesson hierarchy, larger icons, clearer actions, and tighter spacing.
- Fixed visual alignment for the XP award icon.
- Added live heart countdown behavior in the app so active users see hearts refill one at a time.
- Added Firebase initialization and Google sign-in/sign-up support.
- Connected Google auth buttons on sign-in and sign-up screens to the shared auth flow.
- Added package support for Firebase Auth and Google Sign-In.
- Added persistent heart refill support with a stored next-refill timestamp.
- Moved refill authority to the backend so heart counts update correctly even when the app is closed.
- Added one-heart-per-minute refill behavior for testing.
- Added catch-up logic so users returning after time away immediately see the correct heart count.
- Added Firebase ID token exchange through `/auth/firebase`.
- Added Firebase token verification against Google Firebase public certificates.
- Added tests covering heart spending, one-at-a-time refill, old timer clamping, and catch-up refill behavior.

## Notes

- Android Google Sign-In still requires Firebase Console setup: add the app SHA-1/SHA-256 fingerprints and replace `android/app/google-services.json` if Firebase generates updated OAuth clients.
- The backend was restarted locally after the heart refill and Firebase auth changes.

## Validation

- Backend Python compile checks passed for the updated auth and heart refill code.
- Git whitespace checks passed for touched frontend and backend files.
- Backend was restarted locally and the new auth route was smoke-tested.
