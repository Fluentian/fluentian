# Fluentian MVP To-Do Tracker

Source: Fluentian Feature Launch Decision Matrix.

Decision principle: first build only what proves learners can study French through structured, localized lessons. Community, AI correction, payments, full DELF simulations, and advanced personalization should not block the first public launch.

Status note: items marked as finished below are based on the current repo state. Several are prototype/scaffold complete, but still need backend connection, real content, QA, or release work before they are MVP-ready.

| To-do list: what is left and estimated time | Ongoing tasks | Finished tasks |
|---|---|---|
| **1. Lock French-first MVP**: remove or disable multi-language target choices except French as the learning language. Keep support language as English first, Amharic later. **0.5-1 day** | French-first positioning is already visible in copy. | App branding and descriptions already focus on French learning. |
| **2. Connect registration/login to backend**: wire Flutter sign in/sign up to `/auth/register`, `/auth/login`, token storage, logout, and error states. **2-4 days** | Completed in current sprint. | **DONE.** Connected to AuthApi, AuthProvider, and Secure Storage. |
| **3. Profile and onboarding data**: save name, level, goal, target language, support language, and starting level to backend. **2-3 days** | Completed in current sprint. | **DONE.** Connected Level/Goal setup screens to `AuthProvider.updateProfile`. |
| **4. Clean onboarding flow**: after signup, ask level, goal, support language, then route to first lesson/home. **1-2 days** | Completed in current sprint. | **DONE.** Seamless signup -> Level -> Goal -> Home flow implemented. |
| **5. Course/unit/lesson API integration**: replace hardcoded course, unit, and lesson data with backend data. **4-7 days** | Completed in current sprint. | **DONE.** Connected HomeScreen and UnitDetailScreen to ContentProvider. |
| **6. Lesson detail screen**: build a real lesson page with explanation, examples, vocabulary, grammar, dialogue, audio block, and quiz entry. **4-6 days** | Completed in current sprint. | **DONE.** LessonDetailScreen renders blocks dynamically and routes to MCQ. |
| **7. Lesson order control**: enforce locked/unlocked lessons from backend progress, not hardcoded UI state. **2-3 days** | Completed in current sprint. | **DONE.** UnitDetailScreen calculates locked state based on completion. |
| **8. French lesson content batch 1**: prepare teacher-reviewed A1 starter content: units, lessons, vocabulary, examples, dialogues, and quizzes. **1-3 weeks depending on content team** | Content structure exists technically. | Backend can represent lesson blocks and questions. |
| **9. Localized explanations**: launch with English explanations first; add Amharic fields where ready. **3-7 days for first content batch after curriculum is ready** | Support-language idea exists in onboarding/signup copy. | UI already references English/Amharic support. |
| **10. Culturally relevant examples**: rewrite examples around Ethiopian/African learner contexts: school, work, family, travel, and daily life. **3-5 days for starter content** | Some Ethiopian learner positioning exists in onboarding. | App copy already targets Ethiopian learners. |
| **11. Vocabulary and example sentences**: define lesson vocabulary content blocks and render in app. **3-5 days** | Backend lesson blocks can store structured content. | Content model supports JSON lesson blocks. |
| **12. Dialogue lessons**: create dialogue layout and first set of practical conversations. **3-6 days** | Unit path includes dialogue lesson type visually. | Dialogue lesson labels/icons already appear in the UI. |
| **13. Grammar lessons**: create grammar explanation layout and A1/A2 starter grammar content. **4-8 days** | Lesson kinds include grammar. | Backend lesson type enum includes grammar explainer. |
| **14. Basic audio player**: add reliable audio playback for words, dialogues, or lesson audio. **2-5 days** | Completed in current sprint. | **DONE.** Added `just_audio` to `LessonDetailScreen` for vocabulary pronunciation. |
| **15. Pronunciation support**: add simple notes and audio replay. No AI feedback for MVP. **2-4 days** | Speaking/pronunciation concepts exist in UI, but should be simplified for MVP. | Lesson type enum includes pronunciation/speaking. |
| **16. Lesson quizzes**: support MCQ first, then matching, true/false, and fill blank. **4-7 days** | Completed in current sprint. | **DONE.** McqScreen rewritten to use backend QuestionModel and dynamic state. |
| **17. Quiz results and explanations**: show score, correct answer, explanation, and continue/retry. **2-4 days** | Completed in current sprint. | **DONE.** MCQ bottom sheet shows correct/wrong feedback. |
| **18. Lesson completion tracking**: submit lesson completion to backend and update UI. **2-3 days** | Completed in current sprint. | **DONE.** Calls `ContentProvider.completeLesson` tracking score and xp. |
| **19. Quiz score tracking**: store attempts, score, wrong answers, and mastery. **3-5 days** | Completed in current sprint. | **DONE.** `McqScreen` captures exact answer states and submits payload to `ProgressApi`. |
| **20. Unit and course progress**: calculate from completed lessons and display on home/unit/course screens. **3-5 days** | Completed in current sprint. | **DONE.** `UnitDetailScreen` and `HomeScreen` compute progress dynamically from `ContentProvider`. |
| **21. Continue learning card**: fetch real next lesson and open it. **1-2 days after progress integration** | Completed in current sprint. | **DONE.** `HomeScreen` dynamically loads `ContentProvider.getIncompleteLessons(3)`. |
| **22. Home dashboard MVP cleanup**: keep next lesson, progress, quick actions; restore Board and Social tabs after stable connection. **1-2 days** | Completed in current sprint. | **DONE.** Restored Board and Social tabs with backend connectivity and bottom navigation. |
| **38. Professional Opportunity Board**: implement backend CRUD, professional application fields, and mobile/admin integration. **4-7 days** | Completed in current sprint. | **DONE.** Implemented full lifecycle: listing, professional applications, and admin review/status management. |
| **23. Basic admin/content management**: admin CRUD for courses, units, lessons, blocks, quizzes, users, and feedback. **1-2 weeks** | Backend admin-protected create routes started. | Backend has admin create routes for courses/units/lessons. Role checks exist in backend. |
| **24. CSV/Excel import**: import curriculum spreadsheets into courses, units, lessons, and questions. **4-8 days** | Completed in current sprint. | **DONE.** Built hierarchical CSV import engine with multi-pass processing and detailed admin feedback UI. |
| **25. Role-based access control**: super_admin/admin/teacher/moderator/student roles with protected routes and dynamic UI. **3-5 days** | Completed in current sprint. | **DONE.** Implemented granular roles, backend enum migration, and dynamic sidebar filtering in the admin panel. |
| **26. Feedback form and bug priority**: tester feedback form with urgent/important/minor/later classification. **3-5 days** | Not found as a complete feature. | No finished feedback system found yet. |
| **27. Crash reporting**: add Firebase Crashlytics or Sentry, verify Android release reporting. **1-2 days** | Not started from repo scan. | No crash reporting setup found. |
| **28. Basic analytics**: measure registrations, lesson starts, completions, and performance. **3-6 days** | Completed in current sprint. | **DONE.** Built full-stack analytics dashboard with real-time aggregation and premium UI charts. |
| **29. Weak internet handling**: app-wide loading, retry, empty, timeout, and offline-friendly messages. **3-6 days** | Completed in current sprint. | **DONE.** Added explicit retry buttons and connection failure states to `HomeScreen` and `LessonDetailScreen`. |
| **30. Privacy policy and terms**: write pages, link from signup/settings, prepare Play Store URLs. **1-3 days** | Signup mentions Terms/Privacy, but links are not real pages yet. | Terms/Privacy text appears in signup UI. |
| **31. Play Store data safety and listing assets**: complete app data disclosure, screenshots, descriptions, icon, and promo text. **2-5 days** | Android project exists. | Flutter Android project and default app icons exist. |
| **32. Internal alpha testing**: test with team and fix blocking bugs. **3-7 days** | Not started. | No completed testing release found. |
| **33. School pilot testing**: run controlled student pilot and collect feedback. **1-3 weeks** | Not started. | No completed pilot evidence found. |
| **34. Pilot feedback analysis**: convert feedback into product fixes. **3-7 days after pilot** | Not started. | Not completed. |
| **35. Play Store closed testing**: publish closed test build and monitor crashes/feedback. **1-2 weeks depending on Google requirements** | Not started. | Not completed. |
| **36. Launch candidate build**: final release build, QA checklist, and versioning. **2-4 days** | Not started. | Flutter project can build structure-wise, but release candidate is not confirmed. |
| **37. Production release**: publish public MVP. **1-2 days after closed test approval** | Not started. | Not completed. |

## Parked Until After MVP

These features already appear partly in the codebase or roadmap, but they should not block the first launch:

| Feature area | MVP decision |
|---|---|
| AI coach and AI correction | Hide or disable for MVP unless core lessons are stable. |
| Social/community matching | Park until moderation, reporting, blocking, and enough users exist. |
| Text/audio/video chat | Park until safety and moderation are ready. |
| Payments/subscriptions | Park until usage and retention are proven. |
| Teacher feedback workflows | Park because they are operationally expensive. |
| Full DELF mock exams | Add after lessons, quizzes, and progress tracking are stable. |
| Personalized recommendations and spaced repetition | Add after enough real usage data exists. |

## Immediate Next Sprint Recommendation

| Priority | Work item | Why it matters |
|---|---|---|
| 1 | Connect Flutter auth to backend auth | Learners need accounts and saved progress. |
| 2 | Connect course/unit/lesson screens to backend content | This proves the structured French learning experience. |
| 3 | Build real lesson detail screen | The MVP depends on learners studying actual lessons, not only seeing a path. |
| 4 | Add first teacher-reviewed A1 content batch | Bad language content damages trust immediately. |
| 5 | Connect lesson completion/progress | Home, unit progress, and continue learning only become real after this. |

