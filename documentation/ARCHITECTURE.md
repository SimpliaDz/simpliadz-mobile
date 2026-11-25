# Simplia Mobile Architecture

## Scope

Simplia Mobile is a Flutter client for the Simplia API. The application follows a pragmatic, feature-first Clean Architecture: code is grouped by business capability and layers are introduced only when they carry a real responsibility.

## Layout

```
lib/
  app/                         Application root, theme, and later routing/bootstrap
  core/                        Shared configuration, networking, storage, errors, and UI
  features/
    auth/
      presentation/            Flutter screens and state for authentication
      domain/                  Authentication entities, repository contracts, use cases
      data/                    API DTOs, repository implementation, token storage
    home/
      presentation/            Dashboard UI
```

Presentation depends on domain abstractions; data implements those abstractions. UI widgets must not call HTTP or secure storage directly.

## Authentication contract

The configured API tenant selects the tenant context; mobile requests do **not** send `X-Tenant-Id`.

- `POST /auth/login` accepts `{ "email": "...", "password": "..." }`.
- Successful responses include `accessToken`, `refreshToken`, expiry fields, `email`, and `roles`.
- The access token remains in memory. Persist the refresh token only with platform secure storage.
- `POST /auth/refresh` rotates the refresh token, so its replacement must overwrite the stored value atomically.
- `POST /auth/logout` revokes the refresh token.

The local development API is `http://localhost:5278`. On a physical Android device connected by USB, use `adb reverse tcp:5278 tcp:5278` before calling it.

## Current UI slice

The app provides a validated login form, a real authenticated dashboard, logout,
development password-reset request/reset, and a refresh-token-aware repository.
The dashboard reads GET /reports/dashboard/today and labels metrics as unavailable
when their backing module is disabled rather than representing unavailable data as
business zeroes.

## Admin dashboard

Dashboard code is grouped under features/dashboard. It maps the backend dashboard
DTO into a typed domain entity through a data source and repository. Widgets only
observe DashboardController state. AuthenticatedApiClient adds the bearer token and
retries a failed request once after the existing auth controller rotates the refresh
token. A 403 response remains a permission message, not an empty dashboard.

The dashboard requires the reports.dashboard.view permission and the Reporting
module. It shows current UTC date/time-zone labels, sales metrics, expenses, and
low-stock count. Pull down to refresh after changing backend data.

## Running authentication locally

Start the API from the platform repository, then run the mobile app. The Android
emulator default is http://10.0.2.2:5278. For a USB-connected phone, first run
adb reverse tcp:5278 tcp:5278, then launch Flutter with:

    flutter run --dart-define=API_BASE_URL=http://localhost:5278

The debug-only Android manifest permits cleartext HTTP so the local API can be
used in development. Release builds must use HTTPS.

The development account and password are documented in the API project's
src/SimpliaDz.Api/SimpliaDz.Api.http file; enter them manually. They are not
embedded in the mobile app.

## Reporting navigation

The mobile client focuses on oversight. Reports groups the financial dashboard,
sales and product performance, expenses, and worked hours. More provides inventory
counts, inventory warnings, barcode lookup, and audit history. Entries follow API
permissions. The API remains responsible for authorizing and calculating results.

The financial dashboard calls GET /reports/financial-dashboard with the selected
date range and optional location ID. It displays operating metrics, recent active
days, payment mix, shop comparison, and top products. Users with locations.view
can select shops without sales in the current range. Worked hours uses
GET /reports/work-hours and shows organization-wide hours grouped by day.

The shared theme in lib/app/app_theme.dart uses the web app's blue Material 3
direction and follows the device's light or dark appearance.
