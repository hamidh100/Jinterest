# Jinterest — Syntax-e Dart/Flutter (baraye kasi ke Java + HTML/CSS balad-e)

> Khoshbakhtane Dart tقriban baradar-e Java-st va widget tree mesle HTML nesting kar mikone.
> Pas har ja ke mishe, ba chizi ke az ghabl baladi moghayese mikonam.

---

## 0. Zehniyat-e kolli (do khat)

- **Dart ≈ Java** — type dare, class dare, `.` seda mizani, `//` comment-e. 90% ashna-st.
- **Widget tree ≈ HTML** — tag-haye too-ye-ham (nested). Faghat be-jaye `<div>` minevisi `Container`.
- **Style-dadan ≈ CSS** — vali be-jaye file-e joda-ye `.css`, style ro **darun-e khode widget** midi (mesle `style="..."` inline).

---

## 1. Motaghayer (variable) — moghayese ba Java

### Java:
```java
String name = "Ali";
final int age = 20;
```

### Dart:
```dart
String name = 'Ali';        // string ba ' meynevisan (ya " ham mishe)
final int age = 20;         // final = ghfele shode, avaz nemishe (mesle Java)
var city = 'Tehran';        // var = type ro khodesh hads mizane (mesle Java 10+)
```

Se ta kalame ke ziad mibini:

| Kalame | Ya'ni | Moadel-e Java |
|--------|-------|---------------|
| `var`   | type ro khodet nanevis, Dart hads bezane | `var` |
| `final` | faghat yek bar meghdar migire, ba'd ghofl | `final` |
| `const` | mesle final vali dar **zaman-e compile** sabet-e | `static final` (taghriban) |

> Too code-e projet mibini: `final _formKey = ...`، `const SizedBox(height: 16)`.
> `const` yani "in chiz hich-vaght avaz nemishe" — Flutter az in baraye sor'at estefade mikone.

---

## 2. String interpolation — in ro Java nadare (ama rahat-e)

Be-jaye `+` kardan-e string, az `$` estefade mikoni:

```dart
String name = 'Ali';
print('Salam $name');              // Salam Ali
print('Sale badet ${age + 1}');    // baraye expression az ${...}
```

### Moadel-e Java (kesht-tar):
```java
System.out.println("Salam " + name);
```

Too code: `'${photo.likeIDs.length}'` ya `'User ${photo.ownerID}'`.

---

## 3. Null Safety — mohem-tarin farghe ba Java

Dart be-sorat-e **default** ejaze nemide chizi `null` bashe. Bayad ba `?` sarih begi.

```dart
String name;      // in HATMAN bayad meghdar dashte bashe (nemitoone null bashe)
String? caption;  // in MITOONE null bashe (? = "momkene nabashe")
```

Se ta alamat ke hey mibini:

| Alamat | Esm | Kar |
|--------|-----|-----|
| `?` | nullable | "in momkene null bashe" — `String? x` |
| `!` | bang | "man motmaenam null nist" — `photo.captionText!` |
| `??` | default | "age null bood, in ro estefade kon" — `x ?? 'hichi'` |
| `?.` | safe call | "age null nabood, seda bezan" — `user?.name` |

Mesal az code-e khodet:
```dart
photo.captionText?.toLowerCase()   // age caption null bood, kolan bikhial (null bar migardoone)
album.description ?? 'No description'  // age null bood, 'No description' bezar
_identifier = value ?? '';         // age value null bood, string-e khali bezar
```

> **Chera in hast?** Chon `NullPointerException`-e Java (ya`null`-e ke hame ja moshkel misaze)
> inja dar zaman-e neveshtan jelogiri mishe. Compiler majboor-et mikone fekr koni "in momkene null bashe?".

---

## 4. Function — kheyli shabih Java

### Java:
```java
int add(int a, int b) {
  return a + b;
}
```

### Dart:
```dart
int add(int a, int b) {
  return a + b;
}
```

**Daghighan yeki-e!** Faghat do ta ezafe dare:

### a) Arrow function (baraye tabe'-haye yek-khati)
```dart
int add(int a, int b) => a + b;    // => ya'ni "return"
```
Too code: `ThemeMode get themeMode => _themeMode;`

### b) Named parameters — in ro Java nadare (vali too Flutter hame-jast)
Be-jaye tartib-e argument-ha, esm-eshoon ro minevisi:

```dart
// ta'rif:
void createUser({required String name, int age = 0}) { ... }

// seda zadan:
createUser(name: 'Ali', age: 20);   // esm ro minevisi, tartib mohem nist
```

`required` = "in argument ejbari-e". `age = 0` = "age nadadi, 0 bashe (default)".

Mesal az code-et:
```dart
context.read<PhotoProvider>().toggleLike(
  photoId: photo.uuid,     // <- named
  userId: currentUser.uuid,
);
```

> In hamon chizi-e ke Flutter ro khoon-a mikone: vaqti 10 ta argument dari,
> `Container(width: 100, height: 50, color: red)` kheyli behtar az `Container(100, 50, red)`-e.

---

## 5. Class va Constructor — 95% Java

### Java:
```java
class Photo {
  final String uuid;
  Photo(String uuid) {
    this.uuid = uuid;
  }
}
```

### Dart (kootah-tar):
```dart
class Photo {
  final String uuid;
  final bool isPublic;

  Photo({                       // { } = named parameters
    required this.uuid,         // this.uuid = mostaghiman set kon (nabayad dobare benevisi)
    this.isPublic = false,      // default meghdar
  });
}
```

Do ta meydoon-e vaghtgir-e Java (`this.x = x`) inja hazf shode — faghat `this.uuid` minevisi.

**Sakhtan-e object — bedoone `new`!**
```dart
// Java:
Photo p = new Photo("123");
// Dart: (new lazem nist)
Photo p = Photo(uuid: '123');
```

---

## 6. Widget tree = HTML nesting (in ghesmat kelidi-e)

Ino be HTML tashbih kon:

### HTML ke baladi:
```html
<div class="card">
  <div class="header">
    <img src="ali.jpg">
    <span>Ali</span>
  </div>
</div>
```

### Moadel-esh dar Flutter:
```dart
Card(                          // <div class="card">
  child: Column(               // chidan-e amoodi (bala be paeen)
    children: [                // chand ta bacche (mesle chand ta tag-e too-ye ham)
      Row(                     // chidan-e ofoghi (chap be rast)
        children: [
          CircleAvatar(...),   // <img>
          Text('Ali'),         // <span>
        ],
      ),
    ],
  ),
)
```

**Do ghanoon-e mohem:**
- `child:` = **yek** bacche dari (mesle yek tag-e dakheli).
- `children: [...]` = **chand** bacche dari (list ba `[]`).

**Widget-haye chidman ke moadel-e CSS layout hastan:**

| Flutter | Moadel-e CSS/HTML | Kar |
|---------|-------------------|-----|
| `Column` | `display:flex; flex-direction:column` | chidan-e amoodi |
| `Row`    | `display:flex; flex-direction:row` | chidan-e ofoghi |
| `Container` | `<div>` | ja'be-ye omoomi (padding, color, ...) |
| `Padding` | `padding: ...` | faseleye dakheli |
| `SizedBox(height: 16)` | `margin` / faseleye khali | ja'be-ye khali baraye faseleh |
| `Expanded` | `flex: 1` | "hameye jaye baghi-monde ro begir" |
| `Center` | `align-items:center; justify-content:center` | vasat chin |
| `Stack` | `position: absolute` | rooye ham gozashtan-e widget-ha |

---

## 7. Style-dadan = CSS vali inline

Dar CSS:
```css
.title { font-size: 28px; font-weight: bold; color: purple; }
```

Dar Flutter (style ro be khode widget midi):
```dart
Text(
  'Welcome Back',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple,
  ),
)
```

Padding/margin:
```dart
Padding(
  padding: const EdgeInsets.all(16),          // padding: 16px (hameye taraf)
  child: ...,
)
EdgeInsets.symmetric(horizontal: 16, vertical: 8)  // padding: 8px 16px
EdgeInsets.only(bottom: 88)                          // padding-bottom: 88px
```

> Farghe asli ba CSS: inja "class-e moshtarak" nadari (be-sorat-e default).
> Har widget style-e khodesho darun-e khodesh dare. Baraye همین gahi code tekrari mishe.

---

## 8. List va Map — moadel-e Java Collections

### Java:
```java
List<String> tags = new ArrayList<>();
Map<String, User> users = new HashMap<>();
```

### Dart:
```dart
List<String> tags = [];             // [] = ArrayList-e khali
Map<String, User> users = {};       // {} = HashMap-e khali
final likeIDs = <String>['a', 'b']; // ba meghdar-e avaliye
```

**Kar-haye rooye list (mesle Java Stream vali kootah-tar):**
```dart
photos.where((p) => p.isPublic).toList()     // filter (mesle .filter().collect())
photos.map((p) => p.name).toList()           // tabdil (mesle .map())
photos.firstWhere((p) => p.uuid == id)       // aval-in ke shart dare
photos.any((p) => p.isPublic)                // aya heداقل yeki? (mesle anyMatch)
photos.indexWhere((p) => p.uuid == id)       // index-e aval-in shart
```

`(p) => p.isPublic` = **lambda**-ye Java (`p -> p.isPublic`). Faghat `->` shode `=>`.

---

## 9. async / await / Future — moadel-e Java Future/CompletableFuture

Kar-haye tool-keshide (masalan gereftan-e data) ro "async" mikonan ke app hang nakone.

```dart
Future<bool> login(...) async {        // Future<bool> = "yek roozi bool bar migardoonam"
  final user = await UserService.login(...);   // await = "sabr kon ta tamoom she"
  return true;
}
```

| Kalame | Ya'ni |
|--------|-------|
| `Future<T>` | "alan nist, vali baadan yek `T` amade mishe" (mesle `Future<T>`-e Java) |
| `async` | "in tabe' kar-e tool-keshide dare" |
| `await` | "sabr kon javab biad, baad boro khat-e ba'd" |

> Bedoone `await` code nemi-istad va mire khat-e ba'di — masalan `success` hanooz amade nabude.
> Pas har vaght `await` mibini, ya'ni "inja montazer mimoonim".

---

## 10. Chand ta idiom-e Dart ke too code hey mibini

### `..` (cascade) — chand kar rooye yek object
```dart
// be-jaye:
messenger.clearSnackBars();
messenger.showSnackBar(...);
// mishe:
messenger..clearSnackBars()..showSnackBar(...);
```

### `if` darun-e list (collection-if)
Ino too HTML/Java nadari — vali kheyli ghashang-e:
```dart
Column(children: [
  Text('salam'),
  if (photo.captionText != null)      // faghat age shart bood, in widget ezafe she
    Text(photo.captionText!),
])
```

### Spread `...` — baz kardan-e yek list darun-e list-e dige
```dart
final all = [
  ...photos,    // hameye photos ro inja beriz
  ...albums,    // hameye albums ro ham
];
```

### `enum` — daghighan mesle Java
```dart
enum HomeViewMode { photos, albums, mixed }
// estefade: HomeViewMode.photos
```

### `switch` — mesle Java vali too Flutter baraye entekhab-e widget
```dart
switch (_viewMode) {
  case HomeViewMode.photos:
    return ListView(...);
  case HomeViewMode.albums:
    return GridView(...);
}
```

---

## 11. `@override` va `_` (underscore)

### `@override`
Daghighan mesle Java: "man daram method-e class-e pedar ro dobare minevisam".
```dart
@override
Widget build(BuildContext context) { ... }
```

### `_` (underscore) — private
Java `private` dare. Dart kalame nadare — **age esm ba `_` shoroo she, private-e**.
```dart
String _query = '';          // private field
class _FeedPage { ... }      // private class (faghat too hamin file)
void _handleLogin() { ... }  // private method
```

> Pas har vaght `_` didi jelo-ye esm, ya'ni "in faghat too hamin file kar dare".

---

## 12. Jadval-e tarjome-ye sari' (Java → Dart)

| Java | Dart |
|------|------|
| `String s = "x";` | `String s = 'x';` |
| `x -> x.name` | `(x) => x.name` |
| `new Photo()` | `Photo()` (bedoone new) |
| `list.stream().filter(...)` | `list.where(...)` |
| `list.stream().map(...)` | `list.map(...)` |
| `"a" + b` | `'a $b'` |
| `private String x` | `String _x` |
| `System.out.println(x)` | `print(x)` |
| `@Override` | `@override` |
| `Map<K,V> m = new HashMap<>()` | `Map<K,V> m = {}` |
| `obj.method1(); obj.method2();` | `obj..method1()..method2()` |

---
