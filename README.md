# Jinterest

In document, checklist-e requiremenet haye `Proje AP Bahar 1405` ast. PDF baraye item haye emtiazi score-e adadi nagoofte; pas `⭐ Emtiazi` yani optional, va baghiye item ha `Lazem` hastand.

## Functional requirements

Status: `[x]` complete ast; `[ ]` yani incomplete, partial, ya moredi ke az code ghabel-e verify nabood.

| ID | Bakhsh | Requirement | Noe | Status |
| --- | --- | --- | --- | --- |
| F-01 | Login / Signup | User ba username va password login konad va pas az login be safhehaye asli beravad. | Lazem | [x] |
| F-02 | Login / Signup | Session-e login save shavad ta dar execution haye badi Login screen neshan dade nashavad; Login faghat bad az install ya logout neshan dade shavad. | Lazem | [x] |
| F-03 | Login / Signup | Signup-e user-e jadid vojood dashte bashad; username mitavanad email ya shomare mobile bashad. | Lazem | [x] |
| F-04 | Login / Signup | Password hadaghal 8 character, shamel horoof bozorg/koochak va adad bashad; username ra nadaste bashad; validation ba Regular Expression anjam shavad. | Lazem | [x] |
| F-05 | Login / Signup | Error haye server ba toast notification neshan dade shavand; field haye naghes ya format-e ghalat ham warning-e monaseb dashte bashand. | Lazem | [x] |
| F-06 | Login / Signup | Login ba fingerprint be jaye password. | ⭐ Emtiazi | [ ] |
| F-07 | Home | List-e ax haye hame user ha neshan dade shavad va ba entekhab har ax, Details screen baz shavad. | Lazem | [ ] |
| F-08 | Home | Filter va sort bar asas tarikh-e ezafe shodan, name-e file, va like shodan vojood dashte bashad. | Lazem | [ ] |
| F-09 | Home | Select-e chand ax, delete-e hamzaman, transfer be album, va share-e anha mojood bashad. | Lazem | [ ] |
| F-10 | Home | Pagination-e monaseb baraye neshan dadan ax ha (pishnahad: Lazy Loading) estefade shavad. | Lazem | [ ] |
| F-11 | Home | Download-e hame ax haye Home. | ⭐ Emtiazi | [ ] |
| F-12 | Home | Estefade az Shimmer hengam load shodan ax ha. | ⭐ Emtiazi | [ ] |
| F-13 | Home | Share kardan ax ha va album ha beyn user haye mokhtalef. | ⭐ Emtiazi | [ ] |
| F-14 | Upload | Upload-e ax az device va neshan dadan result-e movafagh/namovafagh ba payam-e monaseb. | Lazem | [x] |
| F-15 | Upload | Daryaft metadata: name, album ha, tag ha, afrad/ashya-e mojood dar ax va ...; ax-e upload shode dar Home va bakhsh haye marboot neshan dade shavad. | Lazem | [ ] |
| F-16 | Upload | Field haye name, date-e ezafe shodan, caption, tag va album baraye har ax vojood dashte bashand; value-e caption/tag/album mitavanad khali/null bashad. | Lazem | [x] |
| F-17 | Upload | Ax haye upload shode ya gerefte shode ba camera dar hesab-e user save shavand va az device haye digar ham ghabel-e moshahede bashand. | Lazem | [x] |
| F-18 | Upload | Gereftan ax ba camera. | ⭐ Emtiazi | [x] |
| F-19 | Details | Ba entekhab ax, joloyat va etelaat-e asli ax neshan dade shavad. | Lazem | [x] |
| F-20 | Details | Emkan-e neveshtan caption haye moteaddad va like kardan ax vojood dashte bashad. | Lazem | [ ] |
| F-21 | Details | Sabt-e comment rooye ax haye share shode. | ⭐ Emtiazi | [x] |
| F-22 | Details | Owner betavanad tajhizat-e share ra taein konad; mesalan mojavez-e comment baraye digaran ra. | ⭐ Emtiazi | [ ] |
| F-23 | Albums | Create, delete, va edit-e ax haye album ha vojood dashte bashad. | Lazem | [ ] |
| F-24 | Albums | List-e album ha va ax haye dakhel har album neshan dade shavad. | Lazem | [x] |
| F-25 | Albums | Har ax betavanad dar album ha va category haye moteaddad gharar begirad. | Lazem | [x] |
| F-26 | Albums | Sort-e ax haye album va transfer-e ax az yek album be album-e digar vojood dashte bashad. | Lazem | [ ] |
| F-27 | Search | Search-e ax bar asas name, tarikh-e ezafe shodan, category, comment ha va tag ha. | Lazem | [ ] |
| F-28 | Profile | Username, tedad ax ha va tedad album haye user neshan dade shavad. | Lazem | [x] |
| F-29 | Profile | Taghir username/password, delete account, logout, va taghir permission/settings-e har ax va share-e an vojood dashte bashad. | Lazem | [ ] |
| F-30 | Profile | Dark mode va light mode. | ⭐ Emtiazi | [x] |
| F-31 | Admin | Admin panel-e terminali dar Java: modiriat user ha, didan tedad album/ax har user, va ban kardan user az login. | Lazem | [x] |
| F-32 | Admin | Admin panel-e graphical dar Java. | ⭐ Emtiazi | [ ] |

## Backend, architecture, va data requirements

| ID | Bakhsh | Requirement | Noe | Status |
| --- | --- | --- | --- | --- |
| B-01 | Stack | Project ba Java baraye backend va Flutter baraye mobile app piade sazi shavad. | Lazem | [x] |
| B-02 | OOP | Class ha, property ha va method ha bar asas OOP design shavand; encapsulation, inheritance va polymorphism estefade shavand. | Lazem | [x] |
| B-03 | Socket API | API Server ruye yek port listen konad, request-e client ra begirad va response-e monaseb bargardand. | Lazem | [x] |
| B-04 | Socket API | Server stateless bashad; state-e client ha ra beyn request ha negah nadarad. | Lazem | [x] |
| B-05 | Socket API | Server multi-threaded bashad va hamzaman be chand client response dahad. | Lazem | [x] |
| B-06 | Socket API | Ertebat faghat ba Socket/TCP-e piade sazi shode tavasot-e khodetan bashad; library haye amade-ye REST mojaz nistand. | Lazem | [x] |
| B-07 | Socket API | Protocol-e ekhtesasi request/response design shavad; JSON mojaz ast va GSON baraye JSON mojaz ast. | Lazem | [x] |
| B-08 | Socket API | Server no-e request ra tashkhis dahad va be module-e marboot (database/file server) route konad. | Lazem | [x] |
| B-09 | Socket API | Structure-e daghigh-e JSON request/response, field ha, format va example-e har operation to README/documentation mostanad shavad. | Lazem | [ ] |
| B-10 | Database | Yek module-e joda baraye negahdari state-e tamam object ha va CRUD vojood dashte bashad. | Lazem | [x] |
| B-11 | Database | State belafasele ba har taghir to yek file JSON save shavad va dar startup-e backend restore shavad. | Lazem | [x] |
| B-12 | Database | SQL va database haye amade mesle MySQL, MongoDB ya PostgreSQL mamnoo ast. | Lazem | [x] |
| B-13 | Database | Access be database faghat az tarigh-e API Server bashad. | ⭐ Emtiazi | [ ] |
| B-14 | File server | Module-e file server baraye create/search/browse va modiriat file ha vojood dashte bashad. | Lazem | [ ] |
| B-15 | File server | File ha to masir-e moshakhas ruye filesystem save va modiriat shavand. | Lazem | [x] |

> Note: to chand jay-e PDF be "music/audio files" eshare shode, vali title va requirement haye UI project "modiriat tasavir va album ha" hastand. Dar in checklist, file server baraye ax ha dar nazar gerefte shode.

## Delivery va evaluation requirements

| ID | Requirement | Noe | Status |
| --- | --- | --- |--------|
| D-01 | Project ba group-e 2 nafari anjam shavad. | Lazem | [x]    |
| D-02 | Repository ruye GitHub negahdari shavad va ta akhar Private bemanad. | Lazem | [x]    |
| D-03 | Git/GitHub dorost estefade shavad va har do ozv commit haye ghabel-e barresi dashte bashand. | Lazem | [x]    |
| D-04 | Server ba bastan nabayad hich data-i ra az dast bedahad. | Lazem | [x]    |
| D-05 | README dar nahayat tozihat, report ha va screenshot haye project ra dashte bashad. | Lazem | [x]    |
| D-06 | Har do ozv bayad be tamam bakhsh haye project mosallat bashand. | Lazem | [x]    |
| D-07 | Output-e app bayad ruye device-e fiziki ya emulator run shavad. | Lazem | [x]    |
| D-08 | Quality, zibaie UI va creativity-e bishtar dar feature ha emtiaz-e ezafi darand. | ⭐ Emtiazi | [XXXX] |

TODO:\
stable MasonryGridView\
hight and width and aspect ratio\
album tumbnail\
pfp\
icon for app\
change password\
add to album and delete from home screen\
save?\
download button\
prettier toast\
cache\
save password hash\
likable comments\
fix dark mode\
use theme of context\
notifications\
some refactoring stuff\
suggest\
even more tests\
times (server logs?)

TODON'T:\
AI based photo finding
