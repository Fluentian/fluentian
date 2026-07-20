# Fluentian Bug Fixes and Feature Implementation Report

**Reporting period:** July 2026
**Report date:** July 18, 2026
**Products covered:** Fluentian mobile app, Fluentian FastAPI backend, and Fluentian Admin
**Prepared for:** Fluentian product and engineering team

## Executive Summary

This implementation cycle focused on stabilizing Fluentian's core user journeys and expanding the product into a connected learning community. Work covered authentication, email delivery, notifications, lesson presentation, Explore content, social messaging, LiveKit rooms, learner matching, safety controls, accountability partners, admin workflows, and responsive UI behavior.

The largest architectural improvement was replacing several static or device-only experiences with backend-owned data and workflows. Explore stories, social chat, live rooms, notification preferences, saved vocabulary, accountability partnerships, safety reports, blocks, and admin moderation are now represented through persistent APIs and database records.

The mobile project passes Flutter static analysis, the backend test suite passes, the admin application produces a successful production build, and the latest Android debug application was built and installed on the emulator.

## Bug Fixes Completed

### Authentication and Session Feedback

- Fixed authentication error and success messages remaining visible after navigating between sign-in, sign-up, forgot-password, and verification screens.
- Added short-lived feedback behavior so messages disappear automatically after being shown.
- Cleared stale authentication errors when users change screens or retry an action.
- Improved user-facing API error handling so backend failures are presented as readable messages.
- Restored local backend connectivity for Android emulator login through the emulator-safe API address.
- Improved token and authenticated API handling across the mobile client.

### Email Verification and Password Recovery

- Fixed verification-email delivery paths used during registration.
- Fixed forgot-password email delivery and related failure states.
- Improved backend email configuration validation and error reporting.
- Prevented email failure messages from remaining indefinitely on authentication screens.
- Kept sensitive email and service credentials in environment configuration rather than source code.

### LiveKit and Live Call Stability

- Fixed the Flutter exception caused by returning a `Future` from a `setState()` callback.
- Moved asynchronous LiveKit and API work outside synchronous state-update closures.
- Fixed live-room loading failures caused by incorrect state transitions.
- Corrected LiveKit server URL and backend token configuration handling.
- Fixed rooms connecting and then immediately closing because always-open rooms were treated as expired timed sessions.
- Updated zero-duration room behavior to mean unlimited rather than immediately finished.
- Improved LiveKit join errors and reconnecting/connected status feedback.
- Added separate microphone and camera permission handling.
- Added local and remote video-track rendering behavior.
- Fixed bottom overflow issues on call screens across smaller device sizes.
- Improved responsive phone and wide-screen layouts.
- Added safer cleanup for timers, listeners, tracks, rooms, and navigation.

### Social Chat Functionality

- Replaced static social chat-room content with backend room data.
- Connected chat history to backend message endpoints.
- Connected message sending to persistent backend storage.
- Added loading, empty, retry, and error states.
- Improved message input behavior and chat-screen presentation.

### Explore Page

- Connected Explore stories to backend-managed content.
- Connected Fluentian Admin Explore management to the same content source.
- Removed production fallback behavior that could hide missing backend data.
- Fixed posts with multiple images so they use a functional horizontal media carousel.
- Connected carousel indicators, page count, swipe gestures, and navigation arrows.
- Added mixed image and video support.
- Added media loading and failure states.
- Improved story-level and media-level page indicators.

### Lesson Detail Experience

- Reworked lesson content from one long page into an interactive block-by-block flow.
- Kept lesson overview information visible while learners progress through blocks individually.
- Added progress indication across lesson blocks.
- Updated continuation behavior so learners complete content before moving into the quiz.
- Redesigned lesson blocks to avoid awkward centered square-card presentation.
- Improved content hierarchy, width usage, padding, typography, and responsive layout.
- Fixed text overflow and clipping in lesson cards and learning-path entries.
- Added safer scrolling around long grammar, vocabulary, and example content.

### General Overflow and Responsive UI

- Fixed text spilling outside learning cards and containers.
- Added appropriate wrapping, flexible layout constraints, maximum lines, and ellipsis behavior.
- Improved layout behavior for long bilingual lesson titles.
- Fixed call-screen bottom overflows.
- Improved modal-sheet keyboard padding and small-screen scrolling.
- Updated the Social Add Friend sheet so it no longer uses a basic underlined input.

## Features Implemented

### Backend-Driven Explore Management

The Explore experience now uses a shared backend source across mobile and admin.

- Admin users can create, update, order, publish, and manage Explore culture stories.
- Stories support multiple media items.
- Paragraphs support French sentences and translated sentence pairs.
- Mobile content reflects backend publication and ordering state.
- Empty and backend-error states are shown explicitly.

### Explore Vocabulary and Personal Word Bank

Learners can now turn Explore reading into reusable vocabulary practice.

- Individual French words inside Explore sentences are tappable.
- Selecting a word opens a polished contextual learning sheet.
- The sheet displays the selected word, its original sentence, and the sentence translation.
- Learners can save the word to a backend-persisted word bank.
- Duplicate words are handled per user through normalized uniqueness.
- Saved records include source story, source sentence, translation context, mastery level, review count, and review timestamps.
- Explore includes direct access to the personal Word Bank.
- The Word Bank includes polished empty and populated states.
- Learners can remove saved words with a swipe action.
- Backend APIs support listing, saving, reviewing, and deleting vocabulary.

### Live Room Catalog and Matching

The Live area was expanded from simple temporary calls into structured communities.

- Added always-open rooms based on CEFR fluency levels.
- Level rooms enforce learner eligibility.
- Added always-open streak rooms for the following bands:
  - Under 7 days
  - 7–30 days
  - 31–100 days
  - 101–250 days
  - 251+ days
- Added two-person speaking-match rooms with a strict capacity of two learners.
- Added persistent database-backed match slots so matching works across API workers.
- Added match expiration and slot reuse behavior.
- Added learner-level and call-kind matching metadata.
- Added admin-controlled special rooms that can be scheduled or started manually.
- Added eligibility, open/closed, capacity, and schedule information to room responses.
- Added audio and video join options for eligible rooms.

### Live Community Safety Controls

Live rooms now include user-facing safety tools and persistent moderation records.

- Added an in-call Safety Center.
- Learners can instantly mute or restore room audio.
- Learners can leave a room immediately.
- Connected participants are listed in the safety interface.
- Learners can submit confidential participant reports.
- Report categories include harassment, hate speech, sexual content, spam, impersonation, unsafe behavior, and other concerns.
- Reports can include optional incident details.
- Learners can block a reported participant as part of the same workflow.
- Blocks are persisted to the backend.
- Blocked users are excluded from future two-person matching.
- Added backend APIs for reporting, blocking, unblocking, and viewing blocked users.
- Added persistent moderation states: open, reviewing, resolved, and dismissed.

### Admin Safety Moderation Queue

The Fluentian Admin Live Rooms page now includes moderation tooling.

- Displays confidential community reports.
- Shows category, room, timestamp, report description, reporter ID, and reported-user ID.
- Admins and authorized moderators can begin reviewing a report.
- Reports can be resolved or dismissed.
- The existing special-room controls remain available on the same page.
- Access is protected through backend role authorization.

### Accountability Partners

Fluentian Social now supports consent-based shared learning goals.

- Learners can invite an existing friend to become an accountability partner.
- Invitations require acceptance before progress tracking begins.
- Users can accept or decline incoming invitations.
- Supported shared targets include lessons completed and XP earned.
- Learners can configure target amount and goal duration.
- Invitations can include a short encouragement message.
- Progress is calculated from real backend learning records.
- Both learners see their own progress and their partner's progress.
- Active partnerships show visual progress bars and goal totals.
- Either participant can end a partnership.
- Duplicate active or pending partnerships between the same users are prevented.

### Friends and Social UX

- Added friend search by username or email.
- Added backend friend requests with incoming, outgoing, accepted, declined, and cancelled states.
- Added polished friend-result cards showing learner level, XP, and streak.
- Redesigned the Add Friend bottom sheet with a filled rounded search field, loading state, empty state, no-results state, and request progress.
- Added friend challenges for XP and lesson targets.
- Added friend activity and social progress summaries.
- Improved social empty states, loading states, feedback, and responsive card layouts.

### Notifications and Reminder Preferences

- Added reliable learning-reminder preferences.
- Added configurable reminder time.
- Added Board opportunity-notification preferences.
- Added support for device push-token registration.
- Added platform-aware local and remote notification services.
- Connected settings to backend notification preferences.
- Added opportunity notification delivery when relevant Board items are published.
- Improved the in-app notification inbox, unread handling, and notification feedback.
- Added required Android and iOS notification configuration.

### Opportunity Board Improvements

- Connected Board opportunities to backend-managed data.
- Added opportunity notification preference support.
- Added publication-triggered notification behavior for eligible users.
- Preserved professional application and opportunity-management workflows.

### Admin Live and Explore Management

- Added an Explore Content section to Fluentian Admin.
- Added a Live Rooms section for special-room management.
- Added scheduled start and manual-start controls.
- Added the safety moderation queue to the Live Rooms page.
- Connected admin API calls to authenticated backend routes.
- Updated admin navigation for the new management areas.

## Database and API Changes

New persistent data structures include:

- Special live rooms
- Speaking match slots
- Device push tokens
- Notification preferences
- Explore vocabulary
- Accountability partnerships
- User blocks
- Safety reports

New or expanded API areas include:

- `/social/live-rooms`
- `/social/live-rooms/join`
- `/social/live-rooms/special`
- `/social/vocabulary`
- `/social/accountability`
- `/social/safety/blocks`
- `/social/safety/reports`
- `/social/rooms/{room_id}/messages`
- Notification preference and device-token endpoints
- Backend-driven Explore content endpoints

Alembic migrations were added for the new database structures and preferences.

## Security and Configuration Notes

- LiveKit secrets and API credentials are not stored in this report or mobile source code.
- LiveKit tokens are generated by the authenticated backend.
- Mobile clients receive room-scoped tokens rather than service secrets.
- Safety moderation routes are role-protected.
- Friendship is required before an accountability invitation can be created.
- Blocked users are excluded from direct two-person match selection.
- Environment-specific API and service configuration should remain in environment files or deployment secrets.
- Any credentials previously shared through chat or temporary development channels should be rotated before production release.

## Verification Performed

### Flutter Mobile

- `dart format` completed for the updated Dart files.
- `flutter analyze` completed with no issues.
- Android debug APK assembled successfully.
- Latest build installed successfully on the Android emulator.
- Emulator build used the local backend through `10.0.2.2`.

### FastAPI Backend

- Backend application imports and Python compilation completed successfully.
- Alembic reports the latest migration as the active head.
- New vocabulary, accountability, and safety routes are present in OpenAPI.
- Backend automated test result: **28 tests passed**.
- Local health endpoint returned a successful response.

### Fluentian Admin

- Next.js optimized production build completed successfully.
- Type checking completed successfully.
- All admin routes, including Explore Content and Live Rooms, were generated.
- Existing unrelated lint warnings remain in older admin files but did not block the build.

## Known Production Follow-Up Items

The implemented work is functional and verified at build and automated-test level. The following activities are still recommended before public production release:

1. Run multi-user physical-device testing for LiveKit audio, video, reconnecting, reports, blocks, and two-person capacity.
2. Verify Firebase Cloud Messaging delivery on real Android and iOS devices in foreground, background, and terminated states.
3. Configure production SMTP and test delivery reputation, sender-domain verification, bounce handling, and rate limits.
4. Rotate development credentials before deployment and store production credentials in a managed secret service.
5. Run migration testing against a staging copy of the production database.
6. Add automated API coverage specifically for vocabulary, accountability, blocking, and moderation state transitions.
7. Add crash reporting and production performance monitoring.
8. Complete privacy policy, terms, community guidelines, reporting policy, and moderation operating procedures.
9. Add moderation audit notes and action history if the safety queue will be used by multiple moderators.
10. Perform accessibility testing with large fonts, screen readers, reduced motion, and high-contrast settings.
11. Upgrade Gradle, Android Gradle Plugin, and Kotlin versions before Flutter removes support for the currently configured versions.
12. Run closed testing with representative learners before public Play Store release.

## Recommended Acceptance Test Checklist

### Explore Vocabulary

- Open an Explore story and tap several words.
- Confirm the correct source and translated sentences appear.
- Save a word and confirm it appears in the Word Bank after restarting the app.
- Save the same word again and confirm no duplicate record is created.
- Swipe to delete a word and confirm it remains deleted after refresh.

### Accountability Partners

- Send an invitation to an accepted friend.
- Confirm the other account receives an incoming invitation.
- Accept the invitation and complete qualifying learning activity on both accounts.
- Confirm both progress values update correctly.
- Decline a separate invitation and verify its state.
- End an active partnership and confirm tracking stops.

### Live Safety

- Join the same two-person room from two physical devices.
- Open the Safety Center and confirm the other participant is listed.
- Mute room audio and restore it.
- Submit a report with and without blocking enabled.
- Confirm the report appears in Fluentian Admin.
- Move the report through reviewing and resolved states.
- Confirm blocked accounts are not directly matched again.

### Notifications

- Enable lesson reminders and select a reminder time.
- Confirm delivery while the app is open, backgrounded, and terminated.
- Enable Board opportunity notifications.
- Publish a new eligible opportunity and confirm delivery.
- Disable opportunity notifications and confirm no further opportunity push is received.

## Current Outcome

Fluentian now has a substantially more complete production architecture. Learners can progress through focused lesson blocks, browse backend-managed cultural content, save vocabulary from real contexts, communicate through persistent social chat, join eligibility-based Live rooms, form accountability partnerships, receive configurable reminders, and protect themselves using report and block controls. Administrators can manage Explore content, control special Live rooms, publish opportunities, and process safety reports through the admin application.

The next milestone should focus on staging deployment, multi-device QA, operational moderation procedures, observability, and closed user testing rather than adding another large feature set before release readiness is confirmed.
