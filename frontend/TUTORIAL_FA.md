# Jinterest Frontend — Tutorial (Finglish)

> Yek rahnama-ye koochik baraye inke betooni farda code-e Flutter ro tozih bedi.
> Az paye shoroo mikonim va bad mirim soraghe khode file-haye project.

---

## 0. Flutter dar yek jomle

Flutter yek framework baraye sakhte app-e (mobile / web / desktop) hastesh.
Zaban-esh **Dart**-e. Do ta ghanoon-e talayi ke bayad bedooni:

1. **Hame chiz Widget-e.** Dokme, matn, aks, hatta khode safhe... hamashoon Widget hastan.
   Yek app dar vaghe yek **derakht az Widget-ha** (widget tree) hastesh.
2. **UI = function(state).** Yani hamishe UI ro az rooye "state" (data-ye fe'li) misazi.
   State ke avaz she, Flutter khodesh UI ro dobare mikeshe (rebuild).

---

## 1. Sakhtar-e project (kojahaee chi hast)

```
frontend/lib/
├── main.dart            → noghte-ye shoroo-e app
├── models/              → shekl-e data (Photo, User, Album, ...)
├── services/            → mantegh + zakhire-ye data (fe'lan too memory)
├── providers/           → state-e app + khabar dadan be UI
├── screens/             → safhe-ha (login, home, explore, ...)
├── widgets/             → tekke-widget-haye ghabele estefade-ye dobare
└── utils/               → helper va validator-ha
```

**Jaryan-e data (mohem baraye tozih dadan):**

```
Screen  ──(user click)──►  Provider  ──►  Service  ──►  data (List/Map)
  ▲                           │
  └────(notifyListeners)──────┘
         UI dobare keshide mishe
```

Yani Screen mostaghim ba data kar nemikone. Har vaght chizi mikhad,
be **Provider** mige. Provider be **Service** mige. Bad Provider dad mizane
"data avaz shod!" (`notifyListeners`) va Screen khodesho dobare mikeshe.

---

## 2. Widget: do no' darim

### StatelessWidget — bedoone hafeze
Vaghti chizi taghir nemikone. Faghat migire va neshoon mide.

```dart
class _EmptyState extends StatelessWidget {
  final IconData icon;      // <- data-i ke az biroon migire
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {   // <- build = "khodeto bekesh"
    return Center(child: Text(text));
  }
}
```

### StatefulWidget — ba hafeze (state)
Vaghti chizi darune widget avaz mishe (masalan matne search box).

```dart
class _FeedPageState extends State<_FeedPage> {
  String _query = '';   // <- in "state" hastesh

  onChanged: (value) {
    setState(() {       // <- setState = "man avaz shodam, dobare bekesh"
      _query = value;
    });
  }
}
```

> **Noghte-ye kelidi baraye emtehan:** `setState()` be Flutter mige UI ro rebuild kone.
> Bedoone `setState`, taghir-e `_query` rooye safhe dide nemishe.

---

## 3. main.dart ro khat be khat befahm

`main.dart` se ta kar-e mohem mikone:

```dart
void main() {
  runApp(const MyApp());   // 1) app ro rooshan mikone
}
```

```dart
// 2) hameye Provider-ha ro balaye app mizare ke hame ja dastres bashan
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),   // login/user
    ChangeNotifierProvider(create: (_) => PhotoProvider()),  // aks-ha
    ChangeNotifierProvider(create: (_) => AlbumProvider()),  // album-ha
    ChangeNotifierProvider(create: (_) => ThemeProvider()),  // dark mode
  ],
  ...
)
```

```dart
// 3) route-ha: esm-e safhe -> khode safhe
routes: {
  '/login':  (_) => const LoginScreen(),
  '/home':   (_) => const HomeScreen(),
  '/upload': (_) => const UploadScreen(),
  ...
}
```

Vaghti minevisi `Navigator.pushNamed(context, '/home')` yani "boro be safhe-ye home".

---

## 4. Provider chetori kar mikone (in ghesmat ro hatman balad bash)

Provider = **ja-ee ke state neghdari mishe + be UI khabar mide**.

Mesal: `ThemeProvider` (saade-tarin-e, baraye shoroo aali-e)

```dart
class ThemeProvider extends ChangeNotifier {   // <- ChangeNotifier = "man mitoonam khabar bedam"
  ThemeMode _themeMode = ThemeMode.light;       // state

  ThemeMode get themeMode => _themeMode;         // khoondan-e state

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();   // <- "hey UI! man avaz shodam, dobare bekesh"
  }
}
```

**Dar Screen se joor be Provider vasl mishi:**

| Ravesh | Kar | Rebuild mishe? | Mesal |
|--------|-----|----------------|-------|
| `context.watch<X>()` | goosh dadan + gereftan | **Are** | `context.watch<PhotoProvider>()` |
| `context.read<X>()`  | faghat seda zadan | Na | `context.read<AuthProvider>().login(...)` |

> Ghanoon-e saade: **too `build()`** az `watch` estefade kon (mikhay UI update she).
> **Too `onPressed`/`onTap`** az `read` estefade kon (faghat mikhay ye kari bokoni).

---

## 5. Yek mesal-e kamel: dokme-ye Like

Bebin data chetori az UI ta service miره va bar migarde. Ino too `home_screen.dart` dari:

```dart
IconButton(
  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
  onPressed: () {
    // 1) Screen be Provider migه: in aks ro like/unlike kon
    context.read<PhotoProvider>().toggleLike(
      photoId: photo.uuid,
      userId: currentUser.uuid,
    );
  },
)
```

Bad too `photo_provider.dart`:

```dart
Future<void> toggleLike({required String photoId, required String userId}) async {
  // 2) Provider be Service migه
  final updatedPhoto = await PhotoService.toggleLike(photoId: photoId, userId: userId);

  // 3) natije ro too list-e khodesh update mikone
  final index = _photos.indexWhere((p) => p.uuid == photoId);
  if (index != -1) _photos[index] = updatedPhoto;

  notifyListeners();   // 4) be UI khabar mide -> ghalb por/khali mishe
}
```

**Kholase-ye masir:** click → `read().toggleLike()` → `PhotoService` → `notifyListeners()` → UI rebuild.
Age farda faghat hamin yek jaryan ro balad bashi, 80% Provider ro fahmidi.

---

## 6. Model chie? (Photo ro mesal bezan)

Model = **shekl-e yek data**. `photo.dart`:

```dart
class Photo {
  final String uuid;          // shenase-ye yekta
  final String ownerID;       // saheb-e aks
  final String path;          // masir-e file rooye guhi
  final List<String> likeIDs; // ki-ha like kardan
  final bool isPublic;        // omoomi ya khosoosi
  // ...
}
```

Ye chize ke ziyad mibini: **`copyWith`**. Chon field-ha `final` hastan (ghabele taghir nistan),
baraye "avaz kardan" yek noskhe-ye jadid misazi:

```dart
final updatedPhoto = oldPhoto.copyWith(likeIDs: newLikes);
// yani: hamon aks, faghat likeIDs-esh avaz shode
```

In elgoo behesh migan **immutable** (taghir-napazir) — dar Flutter kheyli rayej-e chon
bug kamtari misaze.

---

## 7. Ye safhe-ye vaghei: Form-e Login

`login_screen.dart` neshoon mide chetori form + validation kar mikone:

```dart
final _formKey = GlobalKey<FormState>();   // "kelid" baraye kontrol-e form

Form(
  key: _formKey,
  child: Column(children: [
    TextFormField(
      validator: Validators.validateIdentifier,  // check-e doroст boodan
      onSaved: (value) => _identifier = value ?? '',
    ),
    // ...
  ]),
)
```

Vaghti dokme feshorde mishe:

```dart
if (!_formKey.currentState!.validate()) return;  // 1) hameye validator-ha ro check kon
_formKey.currentState!.save();                    // 2) onSaved-ha ro seda bezan
final success = await authProvider.login(...);    // 3) login kon
if (success && mounted) Navigator.pushReplacementNamed(context, '/home');  // 4) boro home
```

> `mounted` yani "aya in safhe hanooz rooye safhe hast?". Bad az `await` hamishe check-esh kon
> ke crash nakoni (in yeki az nokte-haye mohem-e Flutter-e).

---

## 8. Vazhename-ye sari' (vaghti gir kardi)

| Kalame | Ya'ni |
|--------|-------|
| **Widget** | har tekke-ye UI |
| **build()** | tabe'-i ke UI ro misaze |
| **setState()** | "man avaz shodam, dobare bekesh" (dakhel-e yek widget) |
| **Provider / ChangeNotifier** | ja-ye neghdari-e state-e moshtarak |
| **notifyListeners()** | "hameye goosh-dadan-ha ro khabar kon" |
| **watch / read** | goosh bede (rebuild) / faghat seda bezan |
| **context** | "man koja-ye derakht-am" — baraye dastresi be provider/route |
| **Future / async / await** | kar-e tool-keshide (masalan gereftan-e data) |
| **Navigator** | jabejaee beyne safhe-ha |
| **copyWith** | sakhtan-e ye noskhe ba chand field-e avaz-shode |

---

Movafagh bashi! 🚀
