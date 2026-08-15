# Jinterest

> A full-stack, mobile-first photo-sharing platform built with Flutter and a custom Java TCP server.

Jinterest is an academic social-media project for uploading, organising, discovering, and sharing photos. It pairs a polished Flutter Android client with a Java 21 backend that speaks a lightweight, line-delimited JSON protocol over TCP. No web framework or external database is required: application data is persisted locally as JSON and uploaded images are stored on disk.

![Flutter](https://img.shields.io/badge/Flutter-3.12%2B-02569B?logo=flutter&logoColor=white)
![Java](https://img.shields.io/badge/Java-21-ED8B00?logo=openjdk&logoColor=white)
![Protocol](https://img.shields.io/badge/Protocol-TCP%20%2B%20JSON-4B32C3)
![License](https://img.shields.io/badge/License-Private-lightgrey)

## What it does

- Account creation, login, persisted sessions, biometric sign-in, and account settings
- Photo capture or gallery upload, captions, categories, privacy controls, downloads, and sharing
- Albums with create, edit, sort, and photo-assignment flows
- Likes, comments, comment controls, profiles, follows, followers, and profile images
- Search for photos and people using text and metadata
- Light and dark themes with a responsive mobile UI
- Administrative views for users, photos, albums, comments, and audit activity

## Architecture

```text
┌───────────────────────────┐       UTF-8 JSON, one message per line       ┌─────────────────────────────┐
│       Flutter client      │ ───────────────────────────────────────────▶ │       Java TCP server       │
│  screens · providers      │ ◀─────────────────────────────────────────── │ router · services · sessions│
│  services · local storage │                    port 8800                 │                             │
└───────────────────────────┘                                              └──────────────┬──────────────┘
                                                                                          │
                                                                           ┌──────────────┴──────────────┐
                                                                           │    database/jinterest.json  │
                                                                           │    database/images/         │
                                                                           └─────────────────────────────┘
```

The server restores its JSON snapshot at startup and saves after data-changing operations. Authenticated requests carry a session UUID in the request envelope; the backend resolves that token before handling protected operations.

## Tech stack

| Layer | Technologies |
| --- | --- |
| Mobile app | Flutter, Dart, Provider, Material UI |
| Device features | Camera/gallery picker, biometrics, local secure storage, sharing and gallery saving |
| Backend | Java 21, Maven, Gson |
| Communication | Custom TCP socket protocol with JSON payloads |
| Persistence | JSON snapshot plus local filesystem image storage |

## Project structure

```text
.
├── backend/
│   ├── src/
│   │   ├── TestClient.java       raw-socket ping smoke test
│   │   ├── database/             persistence and JSON snapshot handling
│   │   ├── exceptions/           backend domain exceptions and validation enums
│   │   ├── models/               domain models and password hashing
│   │   ├── server/               TCP server, request handling, and router
│   │   └── services/             application and session logic
│   ├── test/                     backend tests
│   ├── lib/                      local Java dependency jars, when used
│   └── pom.xml                   Maven build and Gson/JUnit dependencies
├── frontend/
│   ├── lib/
│   │   ├── exceptions/           client-side exception helpers
│   │   ├── models/               client-side data models
│   │   ├── providers/            app and UI state
│   │   ├── screens/              feature screens
│   │   ├── services/             TCP client and feature services
│   │   ├── theme/                colour palettes and theme definitions
│   │   ├── utils/                shared utility functions
│   │   └── widgets/              reusable UI components
│   ├── assets/icon/logo.png      application icon asset
│   └── pubspec.yaml              Flutter packages and asset declarations
└── database/                     runtime data; not source code
    ├── jinterest.json            persisted application state
    └── images/                   uploaded and profile images
```

## Prerequisites

| Requirement | Purpose |
| --- | --- |
| JDK 21+ | Compiles and runs the backend (`--release 21`) |
| Maven 3.9+ | Resolves backend dependencies and starts the server |
| Gson 2.11.0 | JSON serialization; declared in `backend/pom.xml` and downloaded by Maven |
| Flutter stable | Builds and runs the mobile application |
| Android SDK + connected device/emulator | Runs the Flutter client on Android |

> The Android toolchain may use a different JDK from the Java backend. Follow the JDK version recommended by `flutter doctor` for your installed Android Gradle tooling.

## Getting started

### 1. Start the backend

Run this from the repository root:

```bash
mvn -f backend/pom.xml compile exec:java
```

The server listens on TCP port `8800`. Keep this terminal open while using the mobile app.

You can confirm it is reachable with:

```bash
printf '{"method":"GET","route":"/ping","payload":{}}\n' | nc 127.0.0.1 8800
```

### 2. Fetch Flutter packages

```bash
cd frontend
flutter pub get
```

### 3. Run the mobile app

For an Android emulator:

```bash
flutter run --dart-define=JINTEREST_HOST=10.0.2.2 --dart-define=JINTEREST_PORT=8800
```

For a physical phone, connect the phone and computer to the same Wi-Fi network, then replace the example IP with the computer's LAN address:

```bash
flutter run \
  --dart-define=JINTEREST_HOST=192.168.1.10 \
  --dart-define=JINTEREST_PORT=8800
```

`localhost` on a phone refers to the phone itself, not the development computer. If the phone cannot connect, verify the server is running, the IP is correct, and the firewall allows inbound TCP traffic on port `8800`.

## Protocol overview

Each request and response is one UTF-8 JSON line. A socket connection can carry multiple request/response pairs. Resource IDs and session tokens are UUIDs.

```json
{
  "method": "POST",
  "route": "/auth/login",
  "sessionToken": "optional-session-uuid",
  "payload": {
    "identifier": "sara@example.com",
    "password": "Password1"
  }
}
```

Responses follow a consistent envelope:

```json
{
  "statusCode": 200,
  "message": "Login successful",
  "payload": {}
}
```

### Main route groups

| Area | Routes |
| --- | --- |
| Health and auth | `GET /ping`, `POST /auth/signup`, `POST /auth/login` |
| Users | `/users/{id}`, `/users/{id}/image`, `/users/{id}/follow` |
| Photos | `/photos`, `/photos/{id}`, `/photos/{id}/image`, `/photos/{id}/likes`, `/photos/{id}/comments` |
| Albums | `/albums`, `/albums/{id}` |
| Discovery | `/search`, `/search/user` |
| Moderation | `/admin/users`, `/admin/photos`, `/admin/albums`, `/admin/comments`, `/admin/audit` |

The backend supports the appropriate `GET`, `POST`, `PUT`, and `DELETE` operations for those resources. Administrative endpoints require a session belonging to an `ADMIN` user.

### Status codes

| Status | Meaning |
| --- | --- |
| `200` | Successful request |
| `201` | Resource created |
| `400` | Invalid request or validation failure |
| `401` | Invalid credentials |
| `403` | Forbidden or banned user |
| `404` | Resource or route not found |
| `405` | Unsupported method |
| `409` | Conflicting resource |
| `500` | Server error |
| `501` | Feature not implemented |

### Complete route reference

`{id}` represents the relevant UUID. Mutating and user-specific endpoints use
`sessionToken` in the request envelope.

| Method | Route | Purpose |
| --- | --- | --- |
| `GET` | `/ping` | Connection health check |
| `POST` | `/auth/signup` | Create an account with email **or** phone, password, and optional fullname |
| `POST` | `/auth/login` | Authenticate and receive `sessionToken` |
| `GET` / `PUT` / `DELETE` | `/users/{id}` | View, update, or delete a user |
| `GET` | `/users/{id}/image` | Fetch a profile image as Base64 |
| `POST` / `DELETE` | `/users/{id}/follow` | Follow or unfollow a user |
| `GET` / `POST` | `/photos` | List photos or create an upload |
| `GET` / `PUT` / `DELETE` | `/photos/{id}` | View, update, or remove a photo |
| `GET` | `/photos/{id}/image` | Fetch a photo as Base64 |
| `POST` / `DELETE` | `/photos/{id}/likes` | Like or unlike a photo |
| `GET` / `POST` | `/photos/{id}/comments` | List or create comments |
| `DELETE` | `/comments/{id}` | Delete a comment |
| `GET` / `POST` | `/albums` | List or create albums |
| `GET` / `PUT` / `DELETE` | `/albums/{id}` | View, update, or remove an album |
| `GET` / `POST` | `/search` | Search photos by `global`, `name`, `caption`, `category`, `time`, or `comments` |
| `GET` / `POST` | `/search/user` | Search users |

### Example requests

Create an account:

```json
{"method":"POST","route":"/auth/signup","payload":{"email":"sara@example.com","password":"Sara1234","fullname":"Sara Ahmadi"}}
```

Upload an image:

```json
{"method":"POST","route":"/photos","sessionToken":"<session-token>","payload":{"fileName":"sunset.jpg","imageBase64":"<base64-data>","name":"Sunset","categories":["NATURE"],"caption":"Summer evening","isPublic":true}}
```

Search captions:

```json
{"method":"POST","route":"/search","payload":{"type":"caption","text":"summer"}}
```

### Admin endpoints

Admin routes require a valid session token belonging to an `ADMIN` user.

| Route | Purpose |
| --- | --- |
| `/admin/users` | List users |
| `/admin/photos` | List photos |
| `/admin/albums` | List albums |
| `/admin/comments` | List comments |
| `/admin/audit` | View audit log |
| `/admin/users/{id}/ban` | Ban a user |
| `/admin/users/{id}/unban` | Unban a user |
| `/admin/users/{id}` | Delete a user |
| `/admin/photos/{id}` | Delete a photo |
| `/admin/comments/{id}` | Delete a comment |

## Error handling

The backend uses domain-specific Java exceptions instead of returning generic
failures from service code. The router converts these failures to the response
envelope and an appropriate status code, while the Flutter client can show the
returned message to the user.

| Category | Exception types | Typical outcome |
| --- | --- | --- |
| Signup and validation | `InvalidSignupMethod`, `InvalidUsername`, `WeakPassword`, `UserAlreadyExists` | `400` or `409` with a clear validation message |
| Authentication | `InvalidLoginMethod`, `IncorrectPassword`, `UserDoesNotExist` | `400` or `401` |
| Permissions | `UserBanned`, `AdminAccessRequired` | `403` |
| Missing resources | `PhotoDoesNotExist`, `AlbumDoesNotExist` | `404` |

`WeakPassword` and `InvalidUsername` also retain the specific validation reason
(for example, length, allowed pattern, or password composition) so the UI can
give useful feedback instead of a vague error.

## Test client

`backend/src/TestClient.java` is a small, standalone TCP smoke-test client. It
starts a temporary Jinterest server on port `5599`, connects to it with a raw
socket, sends a `GET /ping` JSON request, and prints the request and response.
It is useful for verifying the custom protocol without running Flutter.

Run it from the repository root:

```bash
mvn -f backend/pom.xml compile exec:java -Dexec.mainClass=TestClient
```

Expected output is similar to:

```text
-> {"method":"GET","route":"ping","payload":{}}
<- {"statusCode":200,"message":"pong","payload":{"pong":true}}
```

The test client intentionally uses `5599`, so it does not conflict with the
normal application server on `8800`. Stop it with `Ctrl+C` after the response.

## Data and privacy

- Passwords are stored as salted PBKDF2-HMAC-SHA256 hashes, never plaintext.
- `database/jinterest.json` is saved after data-changing operations and restored when the server starts.
- `database/images/` contains uploaded and profile image files.
- Treat `database/` as runtime data: do not commit real user data, and back it up before deleting or editing it.
- Do not commit local SDK paths, IDE settings, or build output.

## Development

```bash
# Backend tests
mvn -f backend/pom.xml test

# Flutter static analysis
cd frontend && flutter analyze

# Check Flutter and Android toolchain diagnostics
cd frontend && flutter doctor

# Flutter widget/unit tests
cd frontend && flutter test

# Release APK
cd frontend && flutter build apk --release
```

## Troubleshooting

| Problem | What to check |
| --- | --- |
| `No pubspec.yaml file found` | Run Flutter commands from `frontend/`, not the repository root. |
| Phone shows a server connection error | Start the Java server first and use the computer's LAN IP through `JINTEREST_HOST`. |
| Emulator cannot reach the server | Use `10.0.2.2` for the standard Android emulator. |
| `flutter pub get` cannot download packages | Check internet/proxy access to `https://pub.dev` and retry. |
| Backend data appears empty | Start Maven from the repository root so the relative `database/` location resolves correctly. |

## License

This is a private academic project. All rights reserved unless a separate license is added.
