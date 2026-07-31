# STACK_POCKETBASE

Pocketbase as the backend: auth and data in one Go binary you host yourself.

```bash
./tool/stack.py --backend pocketbase --analytics none --crash sentry
```

That is the whole activation. It keeps `pocketbase_auth_service.dart` and
`pocketbase_feedback_service.dart`, moves the `as: AuthService` and
`as: FeedbackService` annotations onto them, deletes the Firebase and Supabase
files, and drops their SDKs from `pubspec.yaml`. Then run `flutter pub get`,
`./tool/codegen.sh` and `flutter test`.

## Config

One key, in `assets/config.json` (gitignored):

```json
{ "POCKETBASE_URL": "https://pocketbase.example.com" }
```

There is no anon key to hold. Pocketbase authorises with the record token it
issues at sign-in, and the SDK keeps that in its own auth store.

## Collections

`users` is created for you when you initialise a Pocketbase instance. Add these
fields to it so `AppUser` round-trips:

| Field | Type | Note |
|---|---|---|
| `phone_number` | text | |
| `first_name` | text | |
| `last_name` | text | |
| `username` | text | already present on some versions |
| `display_name` | text | |
| `profile_image_url` | url | |

`created_at` and `updated_at` come back as ISO 8601 strings, which is what
`AppUser`'s converters read.

For the feedback screen, add a `feedback` collection with `user_id` (relation to
`users`), `content` (text), `type` (text) and `created_at` (date).

## What Pocketbase does not do

Read `pocketbase_auth_service.dart` before promising any of this in a store
listing. Three sign-in paths throw a readable `FastAuthException` rather than
pretending to work:

- **Anonymous sign-in.** Pocketbase has no equivalent. If the app depends on a
  session before sign-up, pick Supabase.
- **Google and Apple sign-in.** Pocketbase does OAuth2, but through a redirect
  registered on the server and a browser round trip, not through the native SDKs
  this template calls. The sign-in screens hide the Google button because
  `googleSignInAvailable` stays false.
- **Phone/SMS.** Not offered at all.

Email and password, password reset by mail, account deletion and the profile
read/write all work.

Password reset lands on Pocketbase's own confirmation page rather than on the
app's `/update-password` route, so the deep link that
`test/auth/password_reset_link_test.dart` pins is unused on this backend. That
test still passes — it checks the four files agree, not that a link was sent.

---

Written by an AI agent working for Joe.
