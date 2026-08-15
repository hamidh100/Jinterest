# Jinterest

> A full-stack photo-sharing and album-management application built with Flutter and Java.

Jinterest lets users upload, organise, discover, and share photos. The mobile
client communicates with a custom, line-delimited JSON protocol over TCP—there
is no REST framework or external database. Application state is persisted to
JSON files and uploaded images are stored locally.

## Highlights

- Secure sign-up and login with email or phone number
- PBKDF2-HMAC-SHA256 password hashing and persisted login sessions
- Biometric login, light/dark themes, and responsive Flutter UI
- Photo upload from gallery or camera, captions, categories, likes, comments,
  sharing, downloading, and multi-select actions
- Albums with creation, editing, sorting, and moving photos between albums
- Search across photos, captions, categories, comments, dates, and users
- Profiles, follows, followers, profile images, and account settings
- Admin views for users, photos, albums, comments, and audit activity
- Concurrent Java TCP server with JSON persistence and local image storage

## Architecture

```text
Flutter mobile app
        │  JSON request/response over TCP (port 8800)
        ▼
Java socket server ──► Router / services / session management
        │
        ├── database/jinterest.json   persisted application state
        └── database/images/          uploaded image files
```

The backend is intentionally stateless between requests. Authentication is
provided by a session token sent with each authenticated request; durable
application data is restored from `database/jinterest.json` at startup.

## Tech stack

| Area | Technology |
| --- | --- |
| Mobile | Flutter / Dart, Provider |
| Backend | Java 21, Maven, GSON |
| Transport | Custom TCP socket protocol with JSON payloads |
| Persistence | Local JSON file and filesystem image storage |
| Android | Android Gradle Plugin, JDK 17 for Android builds |

## Repository layout

```text
.
├── backend/
│   ├── src/
│   │   ├── server/        TCP server, protocol router, image storage
│   │   ├── services/      business logic and session management
│   │   ├── models/        domain models and password hashing
│   │   └── database/      JSON snapshot persistence
│   ├── test/              backend tests
│   └── pom.xml
├── frontend/
│   ├── lib/
│   │   ├── screens/       application screens
│   │   ├── services/      TCP API client and feature services
│   │   ├── providers/     UI and application state
│   │   └── models/        client-side models
│   └── pubspec.yaml
└── database/
    ├── jinterest.json     local application data
    └── images/            locally stored uploads
```

## Prerequisites

Install the following before running the project:

| Requirement | Version / note |
| --- | --- |
| JDK | JDK 21 or newer to build the Java backend (`--release 21`) |
| Maven | 3.9+ |
| Flutter | Stable channel with Dart `>= 3.12.2` |
| Android SDK | Platform tools plus Build Tools `35.0.0` and `36.1.0` |
| Android build JDK | JDK 17 (configured for Flutter/Gradle) |

On Manjaro/Arch, install Maven with:

```bash
sudo pacman -S maven
```

Configure Flutter to use the Android-compatible JDK once:

```bash
flutter config --jdk-dir /usr/lib/jvm/java-17-openjdk
```

> The backend compiler target and the JDK used by Android Gradle are separate
> concerns. Keeping Gradle on JDK 17 avoids Android toolchain incompatibilities.

## Quick start

### 1. Start the backend

From the repository root:

```bash
mvn -f backend/pom.xml compile exec:java
```

Expected output:

```text
Jinterest server listening on port 8800
```

The command must be run from the repository root so the backend can load
`database/jinterest.json` and access the image directory correctly.

### 2. Verify the server (optional)

In another terminal:

```bash
printf '{"method":"GET","route":"/ping","payload":{}}\n' | nc 127.0.0.1 8800
```

The response includes `"statusCode":200` and `"pong":true`.

### 3. Run the Flutter app

```bash
cd frontend
flutter pub get
flutter run
```

### Running on a physical Android device

The default server host is `localhost`. On a physical phone, that address
means the phone itself—not the development computer. Connect both devices to
the same network and pass the computer's LAN IP:

```bash
flutter run --dart-define=JINTEREST_HOST=192.168.1.10
```

Find the address with:

```bash
ip -4 addr show
```

Use the `inet` address associated with your Wi-Fi adapter (for example,
`192.168.1.10`), without the `/24` suffix. Allow TCP port `8800` through the
computer firewall if one is enabled.

The optional port override is also available:

```bash
flutter run \
  --dart-define=JINTEREST_HOST=192.168.1.10 \
  --dart-define=JINTEREST_PORT=8800
```

## TCP API

Each request is one UTF-8 JSON line; the server returns exactly one JSON line.
The connection can carry multiple requests. Object identifiers are UUID
strings.

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

Responses use a consistent envelope:

```json
{
  "statusCode": 200,
  "message": "Login successful",
  "payload": {}
}
```

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

### Public and authenticated endpoints

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

## Data and security

- Passwords are stored as salted PBKDF2-HMAC-SHA256 hashes; plaintext passwords
  are not persisted.
- `database/jinterest.json` is written after data-changing operations and
  restored when the server starts.
- Uploaded files are saved beneath `database/images/`.
- Treat the `database/` directory as application data. Back it up before
  deleting, editing, or migrating it.
- Do not commit local SDK paths, IDE settings, build output, or production data
  containing real user content.

## Development commands

```bash
# Run backend tests
mvn -f backend/pom.xml test

# Check Flutter diagnostics
cd frontend && flutter doctor

# Run Flutter tests
cd frontend && flutter test

# Build a release APK
cd frontend && flutter build apk --release
```

## Troubleshooting

| Symptom | Resolution |
| --- | --- |
| Phone cannot connect to server | Start the server first, use `JINTEREST_HOST=<computer LAN IP>`, and confirm both devices use the same network. |
| `Failed to find Build Tools revision 35.0.0` | Install that exact Build Tools version through Android Studio's SDK Manager. |
| Gradle reports an invalid `JAVA_HOME` | Configure Flutter with the installed JDK 17 path and remove any stale `JAVA_HOME` value. |
| Maven command is unavailable | Install Maven, then re-open the terminal. |
| Server starts without existing users/photos | Run Maven from the repository root so relative `database/` paths resolve correctly. |

## License

This repository is a private academic project. All rights reserved unless a
separate license is added.
