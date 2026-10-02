<div align="center">

<img src="assets/icon/app_icon.png" width="112" alt="Sufra app icon" />

# Sufra · سُفرة

**A bilingual food delivery app built for Gaza, from UI design to backend.**

Arabic & English · Light & Dark · Flutter + Supabase

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3FCF8E?logo=supabase&logoColor=white)
![Tests](https://img.shields.io/badge/tests-61%20passing-2EC4B6)

</div>

## Screenshots

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/01-home-ar-light.png" width="220" alt="Home, Arabic, light theme" /><br /><sub>Home · Arabic · Light</sub></td>
    <td align="center"><img src="docs/screenshots/02-home-en-dark.png" width="220" alt="Home, English, dark theme" /><br /><sub>Home · English · Dark</sub></td>
    <td align="center"><img src="docs/screenshots/03-restaurant-ar-dark.png" width="220" alt="Restaurant page with menu and location map" /><br /><sub>Restaurant, menu & location</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/04-dish-options-ar-light.png" width="220" alt="Dish options sheet with required size and optional extras" /><br /><sub>Dish options</sub></td>
    <td align="center"><img src="docs/screenshots/05-checkout-ar-light.png" width="220" alt="Checkout with address, cash on delivery and promo code" /><br /><sub>Checkout</sub></td>
    <td align="center"><img src="docs/screenshots/06-map-ar-dark.png" width="220" alt="Delivery address picker on a map of Gaza" /><br /><sub>Address on the map</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/07-tracking-ar-dark.png" width="220" alt="Order tracking with the rider on the route" /><br /><sub>Order tracking</sub></td>
    <td></td>
    <td></td>
  </tr>
</table>

## About

Sufra (سُفرة, "the dining spread") is a food ordering app shaped around how delivery actually works in Gaza:
addresses are a **pin on the map plus a landmark** ("near the mosque, opposite the pharmacy") rather than a street
address, payment is **cash on delivery**, prices are in **₪**, and the app has to cope with **weak or missing internet**.

## Features

- **Browse & discover:** restaurants, categories, search across Arabic and English, and filters
  (sort by best match, nearest, top rated, fastest, or cheapest delivery; open now; rating; delivery fee),
  with live result counts and distance from your address.
- **Menus with real options:** required single-choice groups (size), optional multi-choice extras with limits,
  a note for the kitchen, and live price totals.
- **Cart:** one restaurant per cart (asks before replacing), merges identical configurations, minimum-order
  checks, and survives app restarts.
- **Addresses on the map (OpenStreetMap):** a fixed center pin you move the map under, GPS "my location",
  **offline neighborhood detection** for 20 Gaza areas, a required landmark, and Palestinian mobile-number validation.
- **Checkout:** cash on delivery, promo codes, clear reasons when an order can't be placed yet.
- **Order tracking:** a map with the restaurant, your home and the rider moving along the route, stage-by-stage
  progress, minutes left, and "order again" after delivery.
- **Accounts (Supabase Auth):** browsing and building a cart need no account; sign-in is asked for only at checkout.
  Addresses and orders follow the user across devices.
- **Bilingual & themed:** full RTL Arabic and English, light and dark themes, both remembered.
- **Built for weak connections:** fonts bundled in the app, cart/orders/addresses cached on the device,
  loading skeletons, and friendly error and empty states everywhere.

## Security

The backend is designed so a modified app can't cheat:

- **Row-Level Security:** users can only read and change their own addresses, and only read their own orders.
  Restaurants and menus are read-only from the app.
- **Server-side pricing:** orders are created only by the `place_order()` database function, which receives
  dish and option **ids** and looks up every price, option rule, minimum order and promo discount in the database.
- **No secrets in the code:** the app only uses Supabase's public (publishable) key, read from a git-ignored
  `supabase.json` at build time.

## Tech stack

| Area | Choice |
|---|---|
| UI | Flutter 3.47, Material 3 (`material_ui`), `flutter_animate`, custom-painted logo and illustrations |
| State & navigation | Riverpod 3, go_router 18 (stateful tab shell with nested routes) |
| Backend | Supabase: PostgreSQL, Row-Level Security, PL/pgSQL RPC, Auth |
| Maps & location | `flutter_map` with OpenStreetMap tiles, `geolocator` |
| Localization | Flutter gen-l10n (ARB), RTL-aware layouts, Arabic plural forms |
| Fonts | Alexandria and IBM Plex Sans Arabic, bundled (SIL Open Font License) |

## Project structure

```
lib/
  core/          theme, router, settings, maps, backend config, shared widgets
  features/
    home/        restaurants, categories, search, filters (+ data layer: sample & Supabase repositories)
    restaurant/  restaurant page, menu, dish options sheet
    cart/        cart state and screen
    checkout/    checkout and promo codes
    address/     map picker, address form, saved addresses
    orders/      orders, simulated progress, tracking screen
    auth/        email sign-in and sign-up
supabase/        schema.sql (tables, RLS, place_order), seed.sql (generated sample data)
test/            unit, mapping and layout-overflow tests
tool/            icon generator, seed exporter, screenshot script
```

The screens only talk to repository interfaces, so the same app runs on built-in **sample data** (demo mode)
or on the **live Supabase backend**, chosen at build time.

## Getting started

**Requirements:** Flutter 3.47+ and Android Studio (or VS Code).

```bash
flutter pub get
flutter run
```

That runs in **demo mode** on the built-in sample restaurants. Everything works except accounts.

### Connect Supabase

1. Create a Supabase project and run [`supabase/schema.sql`](supabase/schema.sql), then [`supabase/seed.sql`](supabase/seed.sql)
   in the SQL editor. Step-by-step notes: [`supabase/README.md`](supabase/README.md).
2. Copy `supabase.example.json` to `supabase.json` and fill in the project URL and the **publishable** key.
3. Run with the settings:

```bash
flutter run --dart-define-from-file=supabase.json
```

In Android Studio, pick the shared **`sufra (Supabase)`** run configuration, which passes that flag for you.

## Tests

```bash
flutter test
```

61 tests cover the cart and options pricing, filters and sorting, order progress and route geometry,
promo codes, phone validation, address and order JSON/database mapping, settings persistence, and
**layout overflow checks** on a 320-px phone with enlarged system fonts.

## Notes

- **Order status** advances on a demo clock (sped up 12×) and says so in the app. Real statuses need a
  restaurant-side dashboard that updates `orders.status`.
- **Sample data:** the restaurants, menus and prices are illustrative, not real businesses.
- **Map data** © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright). For production traffic,
  use a tile provider instead of OpenStreetMap's own tile servers.
- To refresh the screenshots: build for web, serve it, then run `node tool/screenshots.mjs`.

---

<div align="center" dir="rtl">

**سُفرة** تطبيق توصيل أكل بالعربي والإنجليزي، معمول خصيصًا لغزة:
عنوانك دبوس على الخريطة مع أقرب معلم، والدفع كاش عند الاستلام، والتطبيق بيشتغل حتى لو النت ضعيف.

صُنع في غزة، بكل حب 🧡

</div>
