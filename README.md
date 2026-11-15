# Ugo: Pravěký hlad

Pravěká 2D plošinovka v Godotu 4, dělaná pro **Lenovo Legion Go S / SteamOS** (funguje na jakémkoliv Linuxu x86_64).
Jeskynní muž Ugo sbírá jídlo, mlátí dinosaury kyjem a hledá cestu do jeskyně.

## Stažení

Hotová hra se sestaví automaticky po každé změně:
**[Releases → nejnovější verze](https://github.com/zarybjir/duke/releases/latest)** → soubor `Ugo-linux.zip`.

## Instalace na Legion Go S (SteamOS)

1. **Desktop mód**: tlačítko Steam → *Napájení* → *Přepnout na plochu*.
2. Otevři prohlížeč (pokud žádný nemáš, nainstaluj Firefox z aplikace *Discover*).
3. Jdi na `github.com/zarybjir/duke/releases/latest` a stáhni `Ugo-linux.zip`.
4. Ve správci souborů (Dolphin) otevři *Stažené*, na zip klikni pravým → *Extract* → *Extract archive here*.
5. Složku `Ugo` přesuň třeba do *Domů* (aby se nesmazala při úklidu Stažených).
6. Otevři Steam → *Hry* → *Přidat do knihovny hru, která není ze Steamu* → *Procházet* →
   vyber `Ugo/Ugo.x86_64` (případně přepni filtr na „Všechny soubory“) → *Přidat vybrané programy*.
7. Ikonou *Návrat do herního režimu* na ploše se vrať. Hra je v Knihovně v sekci *Mimo Steam*.

**Aktualizace:** stáhni nový zip a rozbal ho přes starou složku (přepsat vše). Ve Steamu nic měnit nemusíš.

## Ovládání

| Akce | Gamepad | Klávesnice |
|---|---|---|
| Pohyb | levá páčka / D-pad | šipky, A, D |
| Skok | A | mezerník, Z |
| Kyj | X nebo B | X, J |
| Seskok z kmene | dolů + skok | dolů + skok |
| Pauza | Start | Esc |

## Pro vývoj

- Engine: **Godot 4.4** (renderer Compatibility), rozlišení 480×300 škálované celočíselně (na Legion Go S přesně 4×).
- Grafika je zatím „ASCII pixel art“ v `scripts/art.gd`, zvuky se generují v `scripts/sfx.gd`.
- Úrovně jsou textové mapy v `scripts/levels.gd` – legenda je na začátku souboru.
- CI (`.github/workflows/build.yml`) projekt naimportuje, spustí automatický test (`-- --smoke`) a vyexportuje Linux build do Releases.
