# Blackjack Coach — Architektur- & Feature-Plan

> Ziel: Eine funktional gleichwertige Neuentwicklung der App „Blackjack Wiz: Card Counting"
> als **Flutter**-App (iOS, Android, optional Web/Desktop). Reiner Trainings- und Lern-Zweck,
> kein Echtgeld-Glücksspiel. Die gesamte Fachlogik (Hi-Lo, Basic Strategy, Deviations,
> House Edge) ist öffentlich bekanntes Blackjack-Wissen und wird von Grund auf implementiert —
> **nichts** wird aus der fremden App extrahiert.

---

## 1. Feature-Umfang (aus der App-Store-Analyse abgeleitet)

| # | Feature | Beschreibung |
|---|---------|--------------|
| F1 | **Basic Strategy Trainer** | Adaptive Drills zum Einüben der mathematisch korrekten Spielentscheidung (Hit/Stand/Double/Split/Surrender). |
| F2 | **Card Counting Trainer** | Interaktives Austeilen, Spieler zählt mit; App prüft Running Count & True Count. |
| F3 | **Speed Count Drills** | Ganzen Shoe gegen die Uhr herunterzählen; Genauigkeit + Zeit werden gemessen. |
| F4 | **Deviation Charts / Index Plays** | Wann man von der Basic Strategy abweicht (Illustrious 18, Fab 4). |
| F5 | **Custom Rules Engine** | S17/H17, DAS, Surrender, Resplit Aces, Deck-Anzahl, Penetration. |
| F6 | **House Edge Calculator** | Zeigt, wie der Regelsatz die Hausvorteile/den Spielerrand verändert. |
| F7 | **Realtime-Tracking & Feedback** | Laufende Anzeige von Running/True Count + sofortiges Korrektur-Feedback bei Fehlern. |
| F8 | **Offline-Betrieb** | Vollständig ohne Internet nutzbar. |
| F9 | **Fortschritt / Statistiken** | Trefferquoten, Streaks, Verlauf pro Drill-Typ (lokal gespeichert). |
| F10 | *(optional später)* | Account-Login, Cloud-Sync, Abo/Premium — bewusst **Phase 4**, nicht MVP-kritisch. |

---

## 2. Domänenlogik — das Fachwissen

### 2.1 Hi-Lo Zählsystem
- Karten 2–6 → **+1**, 7–9 → **0**, 10/J/Q/K/A → **−1**
- **Running Count (RC):** Summe über alle gesehenen Karten.
- **True Count (TC):** `RC / verbleibende Decks` (verbleibende Decks = verbleibende Karten / 52).
  Üblich auf das nächste halbe oder ganze Deck gerundet — konfigurierbar.
- Balanciertes System: ein komplett gezählter Shoe endet bei RC = 0 (gute Selbstkontrolle für F3).

### 2.2 Basic Strategy
- Tabellen als Daten (nicht hartcodierte if-Ketten), abhängig vom Regelsatz:
  - **Hard Totals**, **Soft Totals**, **Pairs** → je eine Matrix [Spielerhand × Dealer-Upcard] → Aktion.
  - Aktionen: `H` (Hit), `S` (Stand), `D` (Double, sonst Hit), `Ds` (Double, sonst Stand),
    `P` (Split), `R` (Surrender, sonst Hit).
- Zwei Grundtabellen: **S17** (Dealer steht auf Soft 17) und **H17** (Dealer zieht).
- Modifikatoren: DAS an/aus, Surrender an/aus ändern einzelne Zellen.

### 2.3 Deviations / Index Plays (F4)
- Abweichung von Basic Strategy abhängig vom **True Count**.
- **Illustrious 18** + **Fab 4 Surrenders** als Datentabelle:
  jede Regel = `{Hand, DealerUpcard, Index-TC, Aktion ≥ Index, Aktion < Index}`.
  Beispiel: 16 vs 10 → Stand wenn TC ≥ 0, sonst Hit.

### 2.4 House Edge (F6)
- Basis-Hausvorteil ~0,5 % bei typischen Regeln, modifiziert durch Deltas je Regel:
  Tabelle von Regel-Effekten (z. B. H17 ≈ +0,2 %, 6:5 Blackjack ≈ +1,4 %,
  DAS ≈ −0,14 %, Surrender ≈ −0,08 %, Deck-Anzahl-Effekt usw.).
  Summierung aus Basiswert + aktiven Modifikatoren.

### 2.5 Regelsatz (F5) — zentrales Konfigurationsobjekt
```
RuleSet {
  decks: int (1,2,4,6,8)
  dealerHitsSoft17: bool      // S17 / H17
  doubleAfterSplit: bool      // DAS
  surrenderAllowed: bool      // late surrender
  resplitAces: bool
  maxSplitHands: int
  blackjackPayout: enum {3:2, 6:5}
  penetration: double         // Anteil des Shoes, der ausgeteilt wird
}
```

---

## 3. Technische Architektur (Flutter)

### 3.1 Schichten
```
┌─────────────────────────────────────────────┐
│  Presentation  (Widgets, Screens, Theme)     │  ← Flutter UI
├─────────────────────────────────────────────┤
│  State / Controller  (Riverpod Notifiers)    │  ← App-Zustand, Drill-Ablauf
├─────────────────────────────────────────────┤
│  Domain  (pure Dart, KEINE Flutter-Imports)  │  ← Engine, testbar ohne UI
│   • Shoe / Card / Dealer / Hand             │
│   • BasicStrategy / Deviations / HiLoCounter │
│   • HouseEdgeCalculator / RuleSet            │
├─────────────────────────────────────────────┤
│  Data  (Repositories, Persistenz)            │  ← Statistiken, Settings
│   • SharedPreferences / Isar (lokal, offline)│
└─────────────────────────────────────────────┘
```

**Wichtigstes Prinzip:** Der gesamte `domain/`-Layer ist **reines Dart** ohne Flutter-Abhängigkeit
→ vollständig unit-testbar, deterministisch (Seedbarer RNG für den Shoe).

### 3.2 State Management
- **Riverpod** (empfohlen) — gut testbar, kein BuildContext-Zwang in der Logik.
- Ein `DrillController` je Trainer-Typ, der die Domain-Engine antreibt und UI-State liefert.

### 3.3 Persistenz / Offline
- **Isar** oder **SharedPreferences** für Settings (RuleSet) und Statistiken.
- Alles lokal → F8 (Offline) ist automatisch erfüllt.
- Cloud-Sync (F10) wäre später ein zusätzliches Repository hinter demselben Interface.

### 3.4 Projektstruktur
```
lib/
  main.dart
  app.dart                      # MaterialApp, Routing, Theme
  domain/
    models/        card.dart, hand.dart, rule_set.dart, action.dart
    engine/        shoe.dart, dealer.dart, game_round.dart
    strategy/      basic_strategy.dart, deviations.dart, strategy_tables.dart
    counting/      hilo_counter.dart, true_count.dart
    analysis/      house_edge.dart
  data/
    repositories/  settings_repository.dart, stats_repository.dart
    sources/       local storage impl
  state/           providers.dart, drill_controller.dart, ...
  presentation/
    screens/       home, basic_strategy_drill, counting_drill,
                   speed_count, deviation_chart, rules_settings,
                   house_edge, stats
    widgets/       playing_card.dart, count_display.dart, action_buttons.dart,
                   feedback_banner.dart, strategy_matrix.dart
    theme/
test/
  domain/          Unit-Tests für JEDE Engine-Komponente
  golden/          (optional) UI-Golden-Tests
assets/
  data/            strategy_s17.json, strategy_h17.json, deviations.json,
                   house_edge_modifiers.json
```

---

## 4. Screens / UI (Mapping zu Features)

| Screen | Features | Kerninhalt |
|--------|----------|------------|
| **Home / Dashboard** | F9 | Trainer-Auswahl, letzte Statistiken, aktueller RuleSet-Hinweis |
| **Basic Strategy Drill** | F1, F7 | Spielerhand + Dealer-Upcard, Aktions-Buttons, Sofort-Feedback, Streak |
| **Counting Drill** | F2, F7 | Karten erscheinen, Eingabe des RC/TC, Prüfung, laufende Anzeige |
| **Speed Count** | F3 | Ganzer Shoe schnell durchlaufen, Timer, Endkontrolle RC |
| **Deviation Charts** | F4 | Interaktive Matrix (Illustrious 18 / Fab 4) + Drill-Modus |
| **Rules / Settings** | F5 | RuleSet-Editor; wirkt auf alle Trainer + House Edge |
| **House Edge** | F6 | Live-Berechnung aus aktuellem RuleSet mit Aufschlüsselung |
| **Stats** | F9 | Verlauf, Trefferquoten je Drill, Streaks |

---

## 5. Umsetzungs-Phasen (empfohlene Reihenfolge)

**Phase 1 — Domain-Engine (reines Dart, testgetrieben) — ✅ ABGESCHLOSSEN (2026-10-22)**
1. ✅ Models: `Card`, `Hand`, `RuleSet`, `PlayerAction/StrategyCode`, `Shoe` (seedbar), `Dealer`.
2. ✅ `HiLoCounter` + True-Count-Umrechnung.
3. ✅ `BasicStrategy` + Tabellen als **Dart-Konstanten** (S17/H17) — bewusst statt JSON,
      damit der `domain/`-Layer Flutter-frei und ohne Asset-Mocking testbar bleibt.
4. ✅ `Deviations` (Illustrious 18 + Fab 4, als Daten-Overlay über Basic Strategy).
5. ✅ `HouseEdgeCalculator` (Regel-Deltas, mit Aufschlüsselung).
6. ✅ 41 Unit-Tests grün, `flutter analyze` sauber.

> Toolchain: Flutter 3.47.7 (Dart 3.13.5) nach `C:\src\flutter`, git 2.55.0 — beides
> frisch installiert. PATH-Eintrag: `C:\src\flutter\bin`.

**Phase 2 — UI-Grundgerüst — ✅ ABGESCHLOSSEN (2026-10-22)**
7. ✅ App-Shell (`app.dart`), Casino-Theme (dark/gold), Routing, Home-Screen mit Trainer-Tiles.
8. ✅ Basic Strategy Drill + Counting Drill (Riverpod-Controller + Screens), wiederverwendbare
      Widgets (Karte, Action-Buttons, Feedback, Stats). Im Browser (Flutter Web) end-to-end
      getestet; 2 Widget-Tests + weiterhin 41 Engine-Tests grün, `flutter analyze` sauber.

> Hinweis Web-Preview: Debug-`web-server` rendert im App-Pane nicht (wartet auf dwds-Debug-
> Dienst). Für die visuelle Prüfung `flutter build web --release --no-web-resources-cdn` und
> `build/web` statisch servieren (siehe `.claude/launch.json` → Konfiguration `web-static`).

**Phase 3 — Restliche Screens — ✅ ABGESCHLOSSEN (2026-10-24)**
9. Screens:
   - ✅ **Rules/Settings + House Edge** (`rules_screen.dart`): Regelsatz-Editor (Decks,
        Auszahlung, S17/H17, DAS, Surrender, Resplit Aces, Penetration) mit Live-House-Edge
        und Aufschlüsselung. Im Browser verifiziert (H17 → 0.32 % ⇒ 0.54 %).
   - ✅ **Deviation Charts** (`deviations_screen.dart`): Tab „Übersicht" (Illustrious 18 +
        Fab 4 + Versicherung als lesbares Chart) und Tab „Üben" (Drill mit True-Count-Vorgabe,
        Grading gegen `Deviations.recommend`). Im Browser verifiziert.
   - ✅ **Speed Count** (`speed_count_screen.dart`, `speed_count_controller.dart`): ganzen
        Shoe (1/2 Decks) gegen die Uhr durchtippen, Stoppuhr live, am Ende finalen Running
        Count prüfen + Tempo (Karten/s). Im Browser verifiziert (52 Karten → RC 0).
   - ✅ **Stats-Screen** (`stats_screen.dart`): Lifetime-Quote/Treffer/Streak je Trainer +
        Speed-Bestzeit; alle Drill-Controller schreiben ihre Ergebnisse hinein.
10. Persistenz:
    - ✅ **RuleSet** via SharedPreferences (`data/settings_repository.dart`, in
         `main.dart` initialisiert, `ruleSetProvider` lädt/speichert automatisch).
    - ✅ **Statistiken** via SharedPreferences (`data/stats_repository.dart`, `statsProvider`).
         Nach komplettem App-Reload im Browser verifiziert.

Tests: 57 grün (51 Domain/State + 6 Widget), `flutter analyze` sauber.

**→ App funktional vollständig (alle Features des Originals abgedeckt). Offen: Phase 4
(Account/Login, Cloud-Sync, Abo) — optional.**

**Zusatz — Anfängerfreundlichkeit / Lernhilfen (2026-10-24)**
- `StrategyExplainer`: kurze Begründung („Warum") nach jeder Basic-Strategy-Entscheidung
  (💡-Karte im Feedback) — erklärt die Dealer-Stärke-Logik verständlich.
- `InfoButton` + `help_texts.dart`: ℹ️-Konzept-Sheets in jedem Trainer (Basic Strategy,
  Hi-Lo, True Count, Deviations, Speed Count, House Edge) + „Neu hier?"-Einstieg auf Home.
- `DeviationExplainer`: Begründung auch im Deviation-Übungsmodus — erklärt, warum sich die
  Abweichung beim jeweiligen True Count lohnt (bzw. noch nicht).
- 65 Tests grün, `flutter analyze` sauber; im Browser verifiziert.

> Web-Preview-Hinweis: Der Browser-Pane cached `main.dart.js` hartnäckig (auch über Tabs via
> Disk-Cache). Zuverlässig frisch testet man über einen **neuen Port** (= neue Origin) — in
> `.claude/launch.json` liegt dafür `web2` auf 8087.

**Phase 4 — Optionale „Premium"-Schicht**
11. Account/Login, Cloud-Sync, Abo-Modell (nur falls gewünscht).

---

## 6. Rechtlicher Hinweis
- Nachbau der **Funktionalität** (allgemein bekanntes Blackjack-/Zähl-Wissen) ist unproblematisch.
- **Nicht übernehmen:** Markenname „Blackjack Wiz", Logo, konkrete Texte/Grafiken,
  oder 1:1 kopiertes UI-Design des Originals. Eigene Marke, eigene Assets.
- 18+ Alterskennzeichnung + „kein Echtgeld"-Disclaimer wie beim Original einplanen.

---

## 7. Getroffene Entscheidungen (Stand 2026-10-22)
- [x] **State-Management: Riverpod** — wenig Boilerplate, gut testbar, passend zur App-Größe.
- [x] **Persistenz: SharedPreferences zum Start** — reicht für RuleSet + einfache Statistiken.
      Wechsel auf Isar später möglich (gekapselt hinter der Repository-Schicht), falls
      detaillierte Rundenhistorie gebraucht wird.
- [x] **Zielplattformen: Web + Android zuerst** (laufen auf dem Windows-Entwicklungsrechner).
      iOS-Build später auf einem Mac — Engine & UI sind plattformunabhängig.
      ⚠️ Hinweis: Echter iOS-Store-Build erfordert macOS + Xcode.
- [x] **App-Name: „Coaches don't Play"** (Arbeits-/Produktname). Eigene Marke & Assets,
      nichts vom Original übernommen.
```
