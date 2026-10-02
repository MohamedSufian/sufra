# Connecting Sufra to Supabase

Without these steps the app runs in **demo mode** on its built-in sample data. Everything works
except accounts; orders and addresses stay on the device.

## 1. Create the project
1. Sign up at [supabase.com](https://supabase.com) and create a new project.
   The **Frankfurt (eu-central-1)** region is the closest to Gaza.
2. Wait until the project is ready (about a minute).

## 2. Create the tables
In the dashboard, open **SQL Editor → New query**, then run, in this order:
1. `schema.sql`: tables, security rules (RLS) and the `place_order` function.
2. `seed.sql`: the restaurants, menus and options.

To change the sample data later, edit `lib/features/home/data/` and regenerate the seed:
```bash
flutter test tool/export_seed_test.dart
```

## 3. Email sign-in
**Authentication → Sign In / Providers → Email** is on by default.
- **Confirm email** on (recommended): new users must open the link in their email before signing in.
  The app tells them so.
- For quick testing you can turn it off, so sign-up signs in right away.

## 4. Connect the app
1. In **Project Settings → API Keys**, copy the **Project URL** and the **publishable** key
   (or, on older projects, the **anon public** key). Never use the `service_role` / secret key in the app.
2. Copy `supabase.example.json` to `supabase.json` (git ignores it) and paste the two values.
3. Run with:
```bash
flutter run --dart-define-from-file=supabase.json
```

## How the data is protected
- **Restaurants and menus**: anyone can read them, nobody can change them from the app.
- **Addresses**: each user sees and edits only their own (`user_id = auth.uid()`).
- **Orders**: users can only read their own. They are created only by `place_order()`, which looks up
  every price, option and discount in the database, so a modified app can't choose its own prices.

## Not done yet
- **Order status** still advances on a demo clock in the app. Real statuses need a restaurant-side
  app or dashboard that updates `orders.status`.
- **Google sign-in** needs an OAuth client in Google Cloud. It can be added later in
  **Authentication → Providers → Google**.
