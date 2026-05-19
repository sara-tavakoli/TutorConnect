# TutorConnect

### Find the right tutor. Book in seconds.

TutorConnect is a Flutter mobile application that connects university students with peer tutors for one-on-one study sessions. Students can browse verified tutor profiles, filter by subject, check real-time availability, book a session, and chat directly with their tutor — all from a single app. Tutors manage their own profiles, set their subjects and hourly rates, and handle incoming session requests through a dedicated dashboard.

The app was designed to solve a common problem on university campuses: finding quality peer tutoring is slow, fragmented, and usually word-of-mouth. TutorConnect brings everything into one place with a clean, modern interface backed by Firebase for real-time data sync and offline support.

---

## Features

- **User authentication and role selection** — users register with their name, email, and password, and choose their role as either a Student or a Tutor at sign-up. The app remembers the session and returns returning users to the correct home screen automatically. Login errors such as wrong password, too many attempts, or a disabled account all display friendly messages.

- **Browse tutors feed** — students land on a scrollable feed of all available tutors. Each card shows the tutor's name, photo, subjects, hourly rate, star rating, and review count. Tutors with no reviews display a clear "No reviews" label instead of a misleading zero rating.

- **Search and filter** — students can type in a search bar to narrow the list by tutor name or subject in real time. Subject filter chips across the top of the feed let students tap a subject like "Maths" or "English" to instantly filter to tutors who teach it. Typing a search term with no matching tutors shows a clear empty state message.

- **Tutor detail profile** — tapping a tutor card opens a full profile screen showing their photo, bio, university, year of study, subjects, all available time slots, hourly rate, overall star rating, and individual student reviews. The "Book a session" button is disabled if the tutor has not yet added subjects or availability, preventing a broken booking attempt.

- **Map view** — a map screen accessible from the Browse screen shows tutor locations as pins. Students can explore tutors near them geographically and tap a pin to view a tutor's details. Distance is shown in kilometres or metres depending on proximity.

- **Session booking** — students tap "Book a session" on a tutor profile and choose an available time slot from a bottom sheet. When a booking is submitted, the slot is blocked immediately in the database using an atomic batch write, so two students cannot accidentally claim the same slot at the same time. Only slots that are genuinely free are shown.

- **Booking management for students** — students have a Bookings screen split into Upcoming and Past tabs. Upcoming shows pending and confirmed sessions. Past shows completed and cancelled ones. Students can cancel any upcoming session with a single tap, which shows a confirmation dialog and then a snackbar confirming the cancellation.

- **Booking management for tutors** — tutors see the same screen labelled "Session Requests". They can confirm a pending booking, which locks the slot in their profile and notifies the system. They can also cancel sessions. Marking a session as done moves it to the Past tab and unlocks the student's ability to leave a review.

- **Real-time chat** — every tutor profile has a Message button that opens a direct one-to-one conversation. Messages send and appear instantly using Firestore real-time streams. The chat list screen shows all active conversations with the other person's name, last message, and unread message count. Unread counts reset when the conversation is opened.

- **Leave a review** — after a tutor marks a session as complete, a "Leave a Review" button appears on the tutor's profile for that student. The student picks a star rating from one to five and writes a comment. The tutor's overall rating and review count update instantly. The review button is hidden if the student has already submitted a review for that tutor, preventing duplicates. Students can delete their own reviews.

- **Tutor profile editing** — tutors access an Edit Profile screen from their profile page where they can update their bio (with a 300-character counter), university, year of study, hourly rate (validated between $5 and $500), a list of subjects they teach, and their weekly availability slots. Changes are saved to Firestore and reflected immediately across the app.

- **Profile photo upload** — tutors can upload a profile photo from their device. The image is stored in Firebase Storage and displayed throughout the app using cached network images for fast load times.

- **Student profile screen** — students see their name, email, and account role on their profile screen. A logout button in the app bar opens a confirmation dialog before signing out, preventing accidental logouts.

- **Tutor dashboard** — tutors have a dedicated dashboard screen summarising their activity, giving them a quick overview of their profile and session status.

- **Offline support** — Firestore persistence is enabled so that previously loaded data remains accessible when the user has no network connection. The app does not crash or show blank screens when going offline.

- **Role-based navigation** — the bottom navigation bar shows different tabs depending on whether the user is a student or a tutor. Students see Browse, Bookings, Messages, and Profile. Tutors see Dashboard, Bookings, Messages, and Profile.

---

## Users

### Students

University students who need help with one or more subjects. They use TutorConnect to find a suitable peer tutor quickly, see pricing and availability upfront, and book without back-and-forth messaging. They value trust signals like ratings and reviews, and the ability to message a tutor before committing.

**Persona — Alex, 2nd year Engineering:** Alex is struggling with Calculus mid-semester and needs help before his upcoming exam. He opens TutorConnect, types "Maths" in the search bar, and instantly sees tutors who teach it. He taps Alice's profile, reads her bio, sees she is rated 4.8 stars with 10 reviews, and notices her Monday 9am slot is still free. He books it in two taps, sends her a quick message to confirm the location, and after the session he leaves a five-star review.

### Tutors

High-achieving students who want to earn money sharing their knowledge. They use TutorConnect to advertise their skills, set their own rate and availability, and manage their schedule without a middleman. The dashboard gives them a clear view of pending requests, which they can confirm or decline.

**Persona — Alice, 3rd year Mathematics:** Alice wants to earn money between lectures. She creates a tutor profile, adds Maths and Physics as her subjects, sets her rate at $40 per hour, and marks Monday 9am and Wednesday 2pm as available. When Alex books her, she gets the request in her Bookings tab, confirms it, and chats with him about where to meet. After the session she marks it as done, which releases her availability for that slot again and lets Alex leave a review.

---

## Technical Details

### Test Accounts

Two pre-seeded accounts are available for marking without registration:

- **Student account** — email: `student@test.com`, password: `password123`
- **Tutor account** — email: `tutor@test.com`, password: `password123`

### Technology Stack

The app is built with **Flutter** and **Dart**. The backend uses **Firebase Authentication** for login and registration, **Cloud Firestore** for all real-time data, and **Firebase Storage** for profile photo uploads. State management is handled with the **Provider** package. Maps are powered by **Google Maps Flutter**. Images are cached using the **cached_network_image** package for smooth scrolling performance.

### Project Structure

The codebase is organised into feature-based folders under `lib/features/`, each containing its own screens, providers, and widgets. Shared UI components such as `AppButton` and `AppTextField` live in `lib/core/`. Data models are in `lib/models/` and all Firestore and Firebase interactions are encapsulated in service classes under `lib/services/`. Tests are in `test/` and mirror the same structure — models, providers, services, and widgets each have their own subfolder.

### Test Suite

The project includes **194 automated tests** across four layers, all passing:

- **Model tests** — unit tests for BookingModel, TutorModel, UserModel, and ReviewModel covering serialisation, deserialisation, and field logic.
- **Service tests** — unit tests for AuthService, BookingService, ChatService, LocationService, ReviewService, and TutorService using FakeFirebaseFirestore and MockFirebaseAuth so no real Firebase connection is needed.
- **Provider tests** — unit tests for AuthProvider, BookingProvider, and TutorProvider verifying state transitions and stream filtering.
- **Widget tests** — integration-style widget tests for LoginScreen, RegisterScreen, ProfileScreen, BookingsScreen, TutorFeedScreen, BookingCard, AppButton, AppTextField, EmptyState, and StarRating.

To run the full test suite: navigate to the `tutor_app` directory and run `flutter test`.

---

## Notes for Markers

- **Choosing a role** happens at registration — create a new account and select Student or Tutor, or use the test accounts above to skip registration.
- **Booking flow to test** — log in as the student, go to Browse, tap a tutor, select a slot, and book. Then log in as the tutor, go to Bookings, and confirm. Log back in as the student and the booking appears as confirmed in Upcoming.
- **Review flow to test** — after the tutor marks the session done (the Mark Done button on the booking card), log back in as the student. The tutor's detail page will now show the Leave a Review button.
- **Map screen** — accessible via the map icon in the top-right corner of the Browse screen. Requires location permissions to be granted on the device or simulator.
- **Firestore security rules** — role-aware rules are deployed. Each user can only read and write their own data. Students can update only the `bookedSlots`, `rating`, and `reviewCount` fields on tutor documents as part of booking and review operations.
