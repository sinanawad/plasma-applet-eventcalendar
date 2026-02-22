<!--
  Sync Impact Report
  ==================
  Version change: 0.0.0 → 1.0.0 (initial ratification)

  Added principles:
    - I. Plasma 6 API Compliance
    - II. Leverage Prior Art
    - III. Mechanical-First, Manual-Second
    - IV. Feature Parity Preservation
    - V. Incremental Verification
    - VI. Translation Continuity
    - VII. Minimal Divergence

  Added sections:
    - Reference Architecture (Plasma 6 import mappings and root element)
    - Porting Workflow (phased approach)
    - Governance

  Removed sections: None (initial version)

  Templates requiring updates:
    - .specify/templates/plan-template.md ⚠️ pending
      (Constitution Check section needs Plasma 6 gates)
    - .specify/templates/spec-template.md ⚠️ pending
      (User stories should map to widget subsystems)
    - .specify/templates/tasks-template.md ⚠️ pending
      (Phases should align with porting workflow)

  Follow-up TODOs:
    - Fetch Zren's plasma6 branch and ALikesToCode's fork for
      reference when implementing
-->

# Event Calendar Plasma 6 Port Constitution

## Core Principles

### I. Plasma 6 API Compliance

Every QML file MUST use exclusively Plasma 6 / Qt 6 / KF6 APIs
upon completion of the port. Specifically:

- All QML imports MUST be unversioned (`import QtQuick`, not
  `import QtQuick 2.0`)
- Root element in `main.qml` MUST be `PlasmoidItem` (not `Item`)
- Display properties (`toolTipItem`, `compactRepresentation`,
  `fullRepresentation`, `hideOnWindowDeactivate`, `expanded`)
  MUST be direct properties on PlasmoidItem, not `Plasmoid.`
  attached properties
- `PlasmaCore.Units` / `PlasmaCore.Theme` / `PlasmaCore.ColorScope`
  MUST be replaced with `Kirigami.Units` / `Kirigami.Theme`
- `PlasmaCore.Svg` / `SvgItem` / `FrameSvgItem` MUST use
  `KSvg.*` from `org.kde.ksvg`
- `PlasmaCore.DataSource` MUST use `Plasma5Support.DataSource`
  from `org.kde.plasma.plasma5support`
- PlasmaComponents 2 MUST NOT be used; all components MUST come
  from PlasmaComponents 3 (`org.kde.plasma.components`)
- `PlasmaCore.SortFilterModel` MUST be replaced with
  `KItemModels.KSortFilterProxyModel`
- `metadata.json` MUST include `"KPackageStructure": "Plasma/Applet"`
  and `"X-Plasma-API-Minimum-Version": "6.0"`
- Actions MUST use declarative `Plasmoid.contextualActions` with
  `PlasmaCore.Action`, not imperative `setAction()`/`action_*()`
- Config pages MUST use `KCM.SimpleKCM` as root element
- Signal handlers MUST use `function onSignalName()` syntax
  (not bare `onSignalName:` with implicit parameters)

### II. Leverage Prior Art

Before implementing any subsystem port, the existing work MUST be
consulted as reference:

- **Zren's `plasma6` branch** on upstream
  (`github.com/Zren/plasma-applet-eventcalendar`, branch `plasma6`):
  Completed context actions, clock line 1, 2-column layout,
  executable DataEngine, and import porting. Use as reference for
  those subsystems.
- **ALikesToCode's fork**
  (`github.com/ALikesToCode/plasma-applet-eventcalendar`):
  More complete port with working Google Calendar, Weather, Agenda,
  and config panels. Use as reference for those subsystems.
- **Zren's `kpac` tool**
  (`github.com/Zren/plasma-applet-lib/blob/master/kpac`):
  Automates bulk mechanical replacements. Run `python3 ./kpac plasma6`
  as the first step for mechanical changes.
- **KDE official Digital Clock** (in `plasma-workspace/applets/
  digital-clock/`): The canonical Plasma 6 clock/calendar widget.
  Use as the authoritative reference for patterns, especially
  PlasmoidItem usage, contextual actions, and calendar integration.

Prior art MUST be evaluated for correctness before adoption.
Blindly copying code from forks is not permitted — each adopted
pattern MUST be verified against the official KDE porting guide
and Plasma 6 Digital Clock source.

### III. Mechanical-First, Manual-Second

Porting MUST proceed in two distinct phases per file or subsystem:

1. **Mechanical replacements** (automatable, low risk):
   - Remove import version numbers
   - Rename import paths (PlasmaCore → Kirigami/KSvg/Plasma5Support)
   - Replace `PlasmaCore.Units.*` → `Kirigami.Units.*`
   - Replace `PlasmaCore.Theme.*` → `Kirigami.Theme.*`
   - Replace `PlasmaCore.IconItem` → `Kirigami.Icon`
   - Replace `PlasmaExtras.Heading` → `Kirigami.Heading`
   - Update build script tool names (kreadconfig5→6, kpackagetool5→6)

2. **Manual/structural changes** (require understanding, higher risk):
   - Root Item → PlasmoidItem conversion
   - Imperative actions → declarative contextualActions
   - PlasmaComponents 2 → 3 component replacements
   - Config page Item → KCM.SimpleKCM
   - Signal handler syntax modernization
   - SortFilterModel API migration
   - Context menu rewrite (PC2 ContextMenu → PC3 Menu)
   - Translation workflow rewrite for metadata.json

Mechanical changes SHOULD be batched and committed separately from
manual changes to keep diffs reviewable.

### IV. Feature Parity Preservation

The Plasma 6 port MUST maintain functional equivalence with the
Plasma 5 version. No features may be silently dropped.

The following subsystems MUST all be ported:
- Clock display (line 1, line 2, fonts, mouse wheel actions)
- Calendar month view (DaysCalendar, DayDelegate, event badges)
- Agenda view (date grouping, event items, task items)
- Google Calendar integration (OAuth, event CRUD, multi-calendar)
- Google Tasks integration
- ICalendar (.ics) integration via `icsjson.py`
- Plasma native calendar plugin integration
- Weather (OpenWeatherMap, Environment Canada)
- Meteogram view
- Timer with sound effects
- Tooltip view
- All 9 configuration panels
- Desktop notifications
- Timezone support
- Debug logging system

If a feature cannot be ported due to removed Plasma 6 APIs, this
MUST be documented with a rationale and the closest alternative
MUST be implemented.

### V. Incremental Verification

Each ported subsystem MUST be verified before moving to the next.
Verification means:

- The widget installs without errors via `kpackagetool6`
- The widget loads in Plasma 6 without QML errors in the console
- The specific subsystem's user-facing functionality works
  (visual rendering, data loading, user interaction)

The recommended verification order follows dependency chains:
1. Metadata + build scripts (widget installs)
2. main.qml + PlasmoidItem (widget loads, shows clock)
3. Core models (TimeModel, EventModel, AgendaModel)
4. Views (MonthView, AgendaView, MeteogramView, TimerView)
5. Calendar managers (Google, ICS, Plasma native)
6. Weather providers
7. Configuration panels
8. Tooltip, notifications, polish

Do NOT attempt to port all 105 QML files before testing.

### VI. Translation Continuity

All 20+ existing translations MUST be preserved through the port.

- The `.po` files in `package/translate/` MUST be carried over
  unchanged (translation content is language-agnostic of Plasma
  version)
- The `translate/merge` and `translate/build` scripts MUST be
  updated to work with `metadata.json` instead of `metadata.desktop`
- Metadata translations MUST be injected into `metadata.json`
  using the `KPlugin.Name[locale]` and `KPlugin.Description[locale]`
  key format
- `i18n()`, `i18nc()`, `i18np()`, `i18ncp()` calls in QML require
  no changes
- The translation bundling path
  (`contents/locale/{lang}/LC_MESSAGES/`) is unchanged

### VII. Minimal Divergence

Changes MUST be limited to what is required for Plasma 6
compatibility. This is a porting effort, not a rewrite.

- Do NOT refactor code structure beyond what the port requires
- Do NOT rename files or reorganize directories unless forced by
  Plasma 6 conventions
- Do NOT add new features during the port
- Do NOT change the widget's visual appearance or behavior
- Do NOT upgrade Python scripts unless they break on the target
  platform
- Do NOT introduce new dependencies beyond what Plasma 6 requires
- Preserve the existing coding style (camelCase, `//---` section
  markers, signal/property patterns) even when Plasma 6 examples
  use different conventions

Exception: `pragma ComponentBehavior: Bound` MAY be added to QML
files where it does not cause regressions, as it is the Plasma 6
best practice. This is opt-in per file, not mandatory.

## Reference Architecture

### Plasma 6 Import Mapping

```
REMOVED (must migrate):
  org.kde.plasma.components 2.0  → org.kde.plasma.components (PC3)
  org.kde.kquickcontrolsaddons   → org.kde.kcmutils + org.kde.config

RENAMED (drop version, change path):
  org.kde.plasma.core 2.0 [Units/Theme] → org.kde.kirigami
  org.kde.plasma.core 2.0 [SVG]         → org.kde.ksvg
  org.kde.plasma.core 2.0 [DataSource]  → org.kde.plasma.plasma5support
  org.kde.plasma.calendar 2.0           → org.kde.plasma.workspace.calendar

DROP VERSION ONLY:
  org.kde.plasma.plasmoid 2.0           → org.kde.plasma.plasmoid
  org.kde.plasma.components 3.0         → org.kde.plasma.components
  org.kde.plasma.extras 2.0             → org.kde.plasma.extras
  org.kde.plasma.configuration 2.0      → org.kde.plasma.configuration
  org.kde.kirigami 2.x                  → org.kde.kirigami
  org.kde.plasma.private.digitalclock 1.0 → org.kde.plasma.private.digitalclock
  QtQuick 2.x                           → QtQuick
  QtQuick.Layouts 1.x                   → QtQuick.Layouts
  QtQuick.Controls 2.x                  → QtQuick.Controls
```

### Root Element Pattern

```qml
// main.qml — Plasma 6
import QtQuick
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    toolTipItem: ...
    compactRepresentation: ...
    fullRepresentation: ...
    preferredRepresentation: ...
    hideOnWindowDeactivate: !Plasmoid.configuration.pin

    Plasmoid.contextualActions: [
        PlasmaCore.Action { ... }
    ]
}
```

### metadata.json Format

```json
{
    "KPlugin": {
        "Authors": [{"Email": "...", "Name": "..."}],
        "Category": "Date and Time",
        "Description": "...",
        "Icon": "view-calendar",
        "Id": "org.kde.plasma.eventcalendar",
        "License": "GPL",
        "Name": "Event Calendar",
        "Version": "77",
        "Website": "..."
    },
    "KPackageStructure": "Plasma/Applet",
    "X-Plasma-API-Minimum-Version": "6.0",
    "X-Plasma-Provides": [
        "org.kde.plasma.time",
        "org.kde.plasma.date"
    ]
}
```

## Porting Workflow

### Phase Order

1. **Metadata & Build Scripts** — Convert metadata.desktop →
   metadata.json, update build/install/uninstall/update scripts
   for KF6 tools
2. **Translation Scripts** — Update merge/build scripts for
   metadata.json handling
3. **Mechanical Replacements** — Run kpac or equivalent across
   all QML/JS files (import versions, module renames, Units/Theme)
4. **Structural Core** — Port main.qml (PlasmoidItem), actions,
   config model, core models
5. **Views** — Port each view (ClockView, MonthView, AgendaView,
   MeteogramView, TimerView, PopupView, TooltipView)
6. **Calendar Managers** — Port each calendar backend
7. **Weather Providers** — Port weather subsystem
8. **Configuration Panels** — Port all 9+ config pages to
   KCM.SimpleKCM
9. **Polish** — PC2 remnant cleanup, signal syntax, edge cases,
   full integration testing

### Verification Gates

Each phase MUST pass its verification gate before the next phase
begins:
- Phase 1-2: `sh ./build` completes without errors
- Phase 3: Widget installs via `kpackagetool6`
- Phase 4: Widget loads in Plasma 6, clock displays
- Phase 5-7: Each view/manager renders and functions correctly
- Phase 8: All config panels open and save settings
- Phase 9: Full feature parity confirmed

## Governance

This constitution governs all work on the Plasma 5 → Plasma 6
port of Event Calendar. It supersedes ad-hoc decisions.

- **Amendments** require documenting the change, rationale, and
  updating the version number
- **Versioning**: MAJOR for principle removal/redefinition, MINOR
  for new principles or expanded guidance, PATCH for clarifications
- **Compliance**: Every PR/commit SHOULD be reviewable against
  these principles
- **Reference**: The consolidated research document at
  `.specify/research/plasma6-porting-research.md` contains the
  full technical details backing these principles
- **Runtime guidance**: See `CLAUDE.md` for build commands and
  codebase architecture

**Version**: 1.0.0 | **Ratified**: 2026-02-22 | **Last Amended**: 2026-02-22
