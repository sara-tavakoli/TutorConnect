# TutorConnect

### Find the right tutor. Book in seconds.

TutorConnect is a Flutter mobile application that connects university students with peer tutors for one-on-one study sessions. Students can browse verified tutor profiles, filter by subject, check real-time availability, book a session, and chat directly with their tutor — all from a single app. Tutors manage their own profiles, set their subjects and hourly rates, and handle incoming session requests through a dedicated dashboard.

The app was designed to solve a common problem on university campuses: finding quality peer tutoring is slow, fragmented, and usually word-of-mouth. TutorConnect brings everything into one place with a clean, modern interface backed by Firebase for real-time data sync and offline support.

---

## Features

- **Browse & search tutors** — scrollable feed with name/subject search and subject filter chips
- **Tutor profiles** — photo, bio, subjects taught, hourly rate, university, availability slots, and star rating
- **Map view** — discover nearby tutors on an interactive map
- **Session booking** — students pick an available slot; the slot is blocked immediately to prevent double-booking
- **Booking management** — tutors confirm or cancel requests; students can cancel with one tap; both sides see Upcoming and Past tabs
- **Real-time chat** — 1-to-1 messaging between student and tutor, with unread counts
- **Reviews** — students leave a star rating and comment after a completed session; rating averages update instantly; duplicate reviews are prevented
- **Role-based experience** — students and tutors see a tailored interface and navigation from the moment they register
- **Profile management** — tutors edit bio, subjects, availability, and rate; students view their account details and sign out
- **Offline support** — Firestore persistence keeps data accessible without a network connection

---

## Users

### Students
University students who need help with one or more subjects. They use TutorConnect to find a suitable peer tutor quickly, see pricing and availability upfront, and book without back-and-forth messaging. They value trust signals like ratings and reviews, and the ability to message a tutor before committing.

**Persona — Alex, 2nd year Engineering:**
Alex struggles with Calculus mid-semester. He opens TutorConnect, filters by "Maths", finds Alice (rated 4.8★, $40/hr), checks her Monday 9am slot is free, books it in two taps, and messages her to confirm the location. After the session he leaves a review.

### Tutors
High-achieving students who want to earn money sharing their knowledge. They use TutorConnect to advertise their skills, set their own rate and availability, and manage their schedule without a middleman. The dashboard gives them a clear view of pending requests, which they can confirm or decline.

**Persona — Alice, 3rd year Maths:**
Alice sets up her tutor profile with her subjects, hourly rate, and weekly availability. She gets a notification when a student books her Monday slot, confirms it in the app, chats with the student to agree on a meeting spot, and marks the session done once it's complete.

---

## Technical Details

### Test Accounts

| Role | Email | Password |
|------|-------|----------|
| Student | `student@test.com` | `password123` |
| Tutor | `tutor@test.com` | `password123` |

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth, Firestore, Storage) |
| State management | Provider |
| Maps | Google Maps Flutter |
| Image caching | cached\_network\_image |
| Testing | flutter\_test, fake\_cloud\_firestore, firebase\_auth\_mocks |

### Project Structure

```
tutor_app/
├── lib/
│   ├── core/               # Shared theme, widgets (AppButton, AppTextField), utilities
│   ├── features/
│   │   ├── auth/           # Login, Register, Splash screens + AuthProvider
│   │   ├── bookings/       # Bookings screen, booking card, BookingProvider
│   │   ├── chat/           # Chat list and 1-to-1 chat screens
│   │   ├── dashboard/      # Tutor dashboard screen
│   │   ├── home/           # Bottom-nav shell
│   │   ├── map/            # Map screen
│   │   ├── profile/        # Profile screen, Edit Tutor Profile
│   │   ├── reviews/        # Add Review sheet, star rating widget
│   │   └── tutors/         # Tutor feed, detail screen, TutorProvider
│   ├── models/             # BookingModel, TutorModel, UserModel, ReviewModel, ChatModel, MessageModel
│   └── services/           # AuthService, BookingService, ChatService, LocationService, ReviewService, StorageService, TutorService
└── test/
    ├── models/             # 4 model unit tests
    ├── providers/          # 3 provider unit tests
    ├── services/           # 6 service unit tests
    └── widgets/            # 9 widget/screen tests (194 tests total, all passing)
```

### Running Tests

```bash
cd tutor_app
flutter test
```

All **194 tests** pass. Tests use `FakeFirebaseFirestore` and `MockFirebaseAuth` — no real Firebase connection required.

---

## Notes for Markers

- **Role selection** happens at registration. Create a new account and choose Student or Tutor, or use the test accounts above.
- **Booking flow**: log in as a student → Browse → tap a tutor → choose a slot → Book. Then log in as the tutor to confirm.
- **Review flow**: a "Leave a Review" button appears only after the tutor marks the session as done. Duplicate reviews are blocked.
- **Map screen**: accessible via the map icon in the Browse screen app bar. Requires a device or simulator with location services.
- **Firestore security rules**: role-aware rules are in place — users can only read/write their own data; `bookedSlots`, `rating`, and `reviewCount` on tutor documents are the only fields other authenticated users may update.
