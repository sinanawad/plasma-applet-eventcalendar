# Implementation Plan: Port Event Calendar to Plasma 6

**Branch**: `001-plasma6-port` | **Date**: 2026-02-22 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-plasma6-port/spec.md`

## Summary

Port the Event Calendar plasmoid from Plasma 5 to Plasma 6, starting
from Zren's upstream `plasma6` branch as a foundation (60-70% complete)
and incrementally completing the remaining subsystems. The port requires
migrating 105 QML/JS files to use Plasma 6 APIs (PlasmoidItem, unversioned
imports, Kirigami, KSvg, Plasma5Support, PC3, KCM.SimpleKCM) while
preserving all existing features and 20+ translations.

## Technical Context

**Language/Version**: QML (Qt 6) / JavaScript (ES6) / Python 3 (helper scripts)
**Primary Dependencies**: Qt 6, KDE Frameworks 6 (Kirigami, KSvg, Plasma5Support, KItemModels), PlasmaComponents 3, KCMUtils
**Storage**: KConfig via `plasmoid.configuration` (main.xml KConfigXT schema, unchanged)
**Testing**: Manual — `plasmoidviewer`/`plasmawindowed` + `journalctl --user -f` for QML errors
**Target Platform**: KDE Plasma 6 on Linux (X11 and Wayland)
**Project Type**: Desktop widget (KDE Plasmoid, .plasmoid package)
**Performance Goals**: Identical to Plasma 5 version (sub-second popup open, smooth scrolling)
**Constraints**: No C++ code; QML-only plasmoid distributed as `.plasmoid` zip via KDE Store
**Scale/Scope**: 105 QML/JS files, 9 config panels, 5 calendar backends, 2 weather providers, 20+ translations

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Plasma 6 API Compliance | PASS | All changes target Plasma 6 APIs per research mappings |
| II. Leverage Prior Art | PASS | Both forks evaluated; Zren's branch as starting point, ALikesToCode as reference |
| III. Mechanical-First, Manual-Second | PASS | Zren's branch provides mechanical base; manual changes follow |
| IV. Feature Parity Preservation | PASS | All 14 subsystems from constitution to be ported |
| V. Incremental Verification | PASS | 9 user stories provide incremental verification gates |
| VI. Translation Continuity | PASS | .po files unchanged; translation scripts updated for metadata.json |
| VII. Minimal Divergence | PASS | Port only, no refactoring or new features |

## Project Structure

### Documentation (this feature)

```text
specs/001-plasma6-port/
├── plan.md              # This file
├── research.md          # Phase 0: Prior art evaluation & technical decisions
├── data-model.md        # Phase 1: Entity mapping for porting
├── quickstart.md        # Phase 1: Developer quick-start guide
└── tasks.md             # Phase 2: Task breakdown (via /speckit.tasks)
```

### Source Code (repository root)

```text
package/
├── metadata.json            # NEW: Replaces metadata.desktop
├── translate/
│   ├── merge                # Updated for metadata.json
│   └── build                # Updated for metadata.json
└── contents/
    ├── config/
    │   └── main.xml         # KConfigXT schema (unchanged)
    ├── locale/              # Translation .mo files (build output)
    ├── ui/
    │   ├── main.qml         # PlasmoidItem root (was Item)
    │   ├── ClockView.qml    # Compact representation
    │   ├── PopupView.qml    # Full representation container
    │   ├── MonthView.qml    # Calendar month grid
    │   ├── DaysCalendar.qml # Day cell grid
    │   ├── DayDelegate.qml  # Individual day cell
    │   ├── AgendaView.qml   # Event/agenda list
    │   ├── AgendaModel.qml  # Agenda data model
    │   ├── EventModel.qml   # Event data model
    │   ├── MeteogramView.qml # Weather chart
    │   ├── NotificationManager.qml
    │   ├── TimeModel.qml
    │   ├── Logic.qml
    │   ├── config/          # 11 config page QML files → KCM.SimpleKCM
    │   ├── calendars/       # 10 calendar manager files
    │   ├── lib/             # 26 utility/component files
    │   └── badges/          # Event badge components
    └── code/                # (empty — JS is inline or in ui/)

build                        # Updated for kpackagetool6
install                      # Updated for kpackagetool6
uninstall                    # Updated for kpackagetool6
update                       # Updated for kpackagetool6
```

**Structure Decision**: Existing structure preserved per constitution
principle VII (Minimal Divergence). Only file content changes; no
directory reorganization. The single new file is `metadata.json`
replacing `metadata.desktop`.

## Porting Phases

### Phase 1: Setup (Branch Foundation)

Merge Zren's `upstream/plasma6` branch into `001-plasma6-port` as
the starting point. This provides the 60-70% mechanical port base.

### Phase 2: Foundational (Mechanical Verification)

Zren's branch covers most mechanical replacements. Verify and complete
across all 105 QML/JS files:
- All import version numbers removed
- All `PlasmaCore.Units` → `Kirigami.Units`
- All `PlasmaCore.Theme` → `Kirigami.Theme` (including
  `smallestFont` → `smallFont` property rename)
- All `PlasmaCore.IconItem` → `Kirigami.Icon`
- All `PlasmaCore.FrameSvgItem` → `KSvg.FrameSvgItem`
- All `PlasmaCore.DataSource` → `Plasma5Support.DataSource`
- All `PlasmaCore.SortFilterModel` → `KItemModels.KSortFilterProxyModel`
  (with `sortRole` → `sortRoleName`, `filterRegExp` →
  `filterRegularExpression`)
- `PlasmaExtras.Heading` → `Kirigami.Heading`
- Remove `colorGroup` properties from SVG items

### Phase 3: Metadata & Build Scripts (User Story 1)

Starting from Zren's branch which already has `metadata.json` and
updated build scripts. Verify and fix:
- Verify/fix `metadata.json` fields match current Plasma 5 version
- Verify/fix build/install/uninstall/update scripts for Plasma 6
- Update `translate/merge` and `translate/build` for `metadata.json`
- Verify all 20+ locales produce valid `.mo` files

### Phase 4: Structural Core (User Story 2)

Zren's branch has `main.qml` PlasmoidItem done. Complete:
- Verify `expanded` property references use `root.expanded`
- Verify contextual actions work (clipboard, adjust time)
- Port `TimeModel.qml` signal handlers to `function` syntax
- Port `Logic.qml` signal handlers
- Verify clock displays and updates in panel

### Phase 5: Popup, Calendar & Agenda (User Story 3)

Port each view, un-commenting/fixing Zren's work:
- `PopupView.qml` — fix PC2 remnants, verify 2-column layout
- `MonthView.qml` / `DaysCalendar.qml` / `DayDelegate.qml` — port
  rendering and event badges
- `AgendaView.qml` — replace `flickableItem` with PC3 ScrollView,
  fix signal handlers

### Phase 6: Configuration Panels (User Story 4)

Port all config pages to `KCM.SimpleKCM`:
- `lib/ConfigPage.qml` wrapper → `KCM.SimpleKCM` root
- All 9 config pages (`ConfigGeneral`, `ConfigLayout`, `ConfigTimezones`,
  `ConfigCalendar`, `ConfigAgenda`, `ConfigEvents`, `ConfigICal`,
  `ConfigGoogleCalendar`, `ConfigWeather`)
- Replace PC2 components in config dialogs and utility widgets

### Phase 7: Google Calendar (User Story 5)

Un-comment and port each calendar backend:
- `CalendarManager.qml` — main orchestrator
- `GoogleCalendarManager.qml` / `GoogleApiSession.qml` — OAuth flow,
  event sync (reference ALikesToCode for resilience patterns)
- `GoogleTasksManager.qml` — task sync
- Wire CalendarManager back into `main.qml` and `Logic.qml`

### Phase 8: ICalendar & Plasma Native Calendar (User Story 6)

Un-comment and port remaining calendar backends:
- `ICalManager.qml` — .ics file/URL parsing
- `PlasmaCalendarManager.qml` — native Plasma calendar plugin
- Verify multi-source event merging

### Phase 9: Weather & Meteogram (User Story 7)

Port weather data fetching and display:
- `MeteogramView.qml` — Canvas rendering, weather chart
- OpenWeatherMap and Environment Canada city dialogs
- Weather icons in agenda day headers

### Phase 10: Timer, Tooltip & Notifications (User Story 8)

Port secondary features:
- `PopupView.qml` timer section — replace PC2 ContextMenu with PC3 Menu
- `main.qml` `toolTipItem` — port tooltip rendering
- `NotificationManager.qml` — port notification dispatching
- `lib/ContextMenu.qml` / `lib/MenuItem.qml` — replace PC2 with PC3

### Phase 11: Full Feature Parity & Polish (User Story 9)

- Clock Line 2, mouse wheel actions, timezone display
- Complete signal handler modernization across all files
- Graceful degradation when `plasma5support` is unavailable
- Verify `ConfigMigration.qml` and config key compatibility
- Verify existing Plasma 5 OAuth tokens still work
- Full integration testing against all success criteria
- Verify all 20+ translations display correctly

## Complexity Tracking

No constitution violations. All changes follow the minimal-divergence
porting approach without introducing new architecture or features.
