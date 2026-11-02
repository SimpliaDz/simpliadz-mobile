# SimpliaDz Mobile Architecture

## Scope

SimpliaDz Mobile is a Flutter client for the SimpliaDz API. The application follows a pragmatic, feature-first Clean Architecture: code is grouped by business capability and layers are introduced only when they carry a real responsibility.

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

The app provides a validated login form and a dashboard placeholder. Sign-in navigation is intentionally local while the data, domain, state-management, and secure-storage layers are added. The dashboard uses placeholders rather than fabricated financial data.

## Next implementation sequence

1. Add environment configuration and an HTTP client.
2. Define the auth domain entity and repository contract.
3. Map API responses manually and implement the login repository.
4. Store refresh tokens securely and manage access tokens in memory.
5. Add application state and route guards.
6. Replace dashboard placeholders with authenticated API-backed features.
