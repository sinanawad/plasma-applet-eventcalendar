# Phase 0 Research: Plasma 6 Port

**Feature**: 001-plasma6-port | **Date**: 2026-02-22

## Prior Art Evaluation

### Zren's `plasma6` Branch (upstream)

**Source**: `github.com/Zren/plasma-applet-eventcalendar`, branch `plasma6`
**Scope**: 63 files changed, +2,321 / -1,113 lines, 14 commits

#### What's Done Correctly (60-70% of port)

- **PlasmoidItem migration**: `main.qml` correctly uses `PlasmoidItem` root
  with direct properties (`compactRepresentation`, `fullRepresentation`,
  `toolTipItem`, `hideOnWindowDeactivate`, `expanded`)
- **Import modernization**: Most imports unversioned; correct module renames
  (`org.kde.kirigami`, `org.kde.ksvg`, `org.kde.plasma.plasma5support`)
- **Contextual actions**: Declarative `Plasmoid.contextualActions` with
  `PlasmaCore.Action` (copy clipboard, adjust time, refresh, set locale)
- **ClipboardMenu**: Uses `org.kde.plasma.private.digitalclock` for
  the multi-format clipboard submenu (matches official Digital Clock)
- **KSvg migration**: `PlasmaCore.FrameSvgItem` → `KSvg.FrameSvgItem`
  with `colorGroup` properties removed
- **Kirigami migration**: `PlasmaCore.Units` → `Kirigami.Units`,
  `PlasmaCore.Theme` → `Kirigami.Theme`, `PlasmaCore.IconItem` →
  `Kirigami.Icon`
- **Plasma5Support**: `PlasmaCore.DataSource` → `Plasma5Support.DataSource`
- **metadata.json**: Correct format with `KPackageStructure` and
  `X-Plasma-API-Minimum-Version: "6.0"`
- **Build scripts**: `kpackagetool5` → `kpackagetool6`,
  `kreadconfig5` → `kreadconfig6`
- **Clock Line 1**: `ClockView.qml` ported with `TimeModel` working
- **2-column layout**: `PopupView.qml` updated

#### What's NOT Done

- **Calendar managers**: `GoogleCalendarManager`, `ICalManager`,
  `PlasmaCalendarManager` all commented out with
  `// TODO: temporarily disabled till widget is working`
- **Config pages**: `ConfigPage.qml` still uses Qt5 `Item` wrapper
  (not ported to `KCM.SimpleKCM`)
- **Timer context menu**: Still uses PC2 `ContextMenu`/`MenuItem`
- **PC2 remnants**: `lib/ContextMenu.qml` and `lib/MenuItem.qml`
  still PlasmaComponents 2
- **AgendaView scrolling**: Uses `flickableItem` (removed in PC3 ScrollView)
- **Signal handlers**: Many still use old `onSignalName:` syntax
  without `function` keyword
- **Clock Line 2**: Not ported
- **Tooltip**: Not ported
- **Notifications**: Not ported
- **Weather**: Not ported

#### Recommendation: USE AS STARTING POINT

Clean 14-commit history, minimal divergence from Plasma 5 codebase,
correct patterns for the structural changes. The remaining 30-40%
is well-scoped and can be completed incrementally.

---

### ALikesToCode's Fork

**Source**: `github.com/ALikesToCode/plasma-applet-eventcalendar`
**Scope**: 129 files changed, +8,250 / -1,830 lines, 155 commits

#### What's Done Correctly

- **PlasmoidItem**: Correct root element migration
- **Imports**: Unversioned, correct module renames
- **Signal handlers**: Updated to `function onClicked(mouse)` syntax
- **metadata.json**: Correct Plasma 6 format
- **main.xml**: Full KCFG XML config schema added
- **Contextual actions**: Correct `PlasmaCore.Action` array syntax
- **Calendar imports**: `org.kde.plasma.workspace.calendar` correct
- **Calendar managers**: All wired up and functional
- **Config pages**: Functional (but over-engineered, see below)

#### Problems

- **Massive divergence**: Mixes porting with new features (multi-account
  Google Calendar, PKCE OAuth, new OAuth client ID, hosted redirect)
- **ConfigBridge over-engineering**: `ConfigPage.qml` rewritten from
  38 lines to 401 lines with an abstraction layer that adds complexity
  throughout all config pages
- **Removed ClipboardMenu**: Replaced Plasma's multi-format clipboard
  with a simple `TextEdit` clipboard helper (functional regression)
- **Junk files**: `configGeneral.qml` contains unrelated counter widget
  template (dead code)
- **Over-scoped install script**: 454 lines that auto-installs system
  packages and switches git branches
- **Google OAuth client**: Tied to ALikesToCode's Google Cloud project
- **Messy history**: 155 commits with "try to fix", "new commit" etc.
- **Dynamic EventPluginsManager**: Uses `Qt.createQmlObject()` instead
  of standard singleton pattern

#### Recommendation: REFERENCE ONLY (do not use as starting point)

Too much divergence to cherry-pick cleanly. However, reference these
specific patterns:

1. Signal handler `function` syntax migrations throughout
2. `main.xml` KCFG config schema (comprehensive)
3. `PimCalendarsModel` import without version
4. `EventPluginsManager` try/catch resilience pattern
5. `notify-send` fallback in `NotificationManager`
6. iCal file picker fix for Plasma 6
7. Per-calendar error handling in `GoogleCalendarManager`

---

## Technical Decisions

### Decision 1: Starting Point

- **Decision**: Start from Zren's `upstream/plasma6` branch
- **Rationale**: Clean 14-commit history, correct structural patterns,
  minimal divergence from master. The 30-40% remaining work is
  well-defined and can be completed incrementally.
- **Alternative rejected**: ALikesToCode's fork — too much divergence
  (multi-account Google, PKCE, configBridge) tangled with porting changes

### Decision 2: Mechanical Replacement Strategy

- **Decision**: Apply Zren's mechanical changes as baseline, then
  manually complete remaining subsystems
- **Rationale**: The import/Units/Theme/SVG/DataSource replacements
  in Zren's branch are verified correct and cover most files
- **Alternative rejected**: Running `kpac plasma6` from scratch —
  Zren's branch already includes these changes plus manual fixes

### Decision 3: Config Page Migration

- **Decision**: Use `KCM.SimpleKCM` as root with standard `cfg_*`
  property aliases (matching Plasma 6 convention)
- **Rationale**: Standard pattern used by official KDE widgets,
  simple and maintainable
- **Alternative rejected**: ALikesToCode's ConfigBridge abstraction —
  over-engineered, adds unnecessary indirection

### Decision 4: PlasmaComponents 2 Replacement

- **Decision**: Replace PC2 `ContextMenu`/`MenuItem` with PC3
  `Menu`/`MenuItem`; replace `ScrollArea` with PC3 `ScrollView`
- **Rationale**: PC2 is completely removed in Plasma 6
- **Alternative rejected**: Custom context menu implementation —
  PC3 Menu provides equivalent functionality

### Decision 5: ClipboardMenu

- **Decision**: Use `org.kde.plasma.private.digitalclock` ClipboardMenu
  (matching Zren's approach and official Digital Clock)
- **Rationale**: Preserves multi-format date/time copy submenu
- **Alternative rejected**: ALikesToCode's TextEdit clipboard helper —
  functional regression losing format options

### Decision 6: Signal Handler Modernization

- **Decision**: Update all signal handlers to `function` syntax in
  Connections blocks; use arrow function syntax for MouseArea handlers
- **Rationale**: Required by Qt 6, prevents deprecation warnings
- **Reference**: ALikesToCode's fork has comprehensive examples

### Decision 7: Translation Workflow

- **Decision**: Update `translate/merge` and `translate/build` scripts
  to handle `metadata.json` instead of `metadata.desktop`; inject
  translations as `KPlugin.Name[locale]` / `KPlugin.Description[locale]`
- **Rationale**: `metadata.desktop` format is not used in Plasma 6
- **Constraint**: Cannot use `msgfmt --desktop` for JSON; need custom
  Python handling

### Decision 8: Testing Strategy

- **Decision**: Manual testing with `plasmoidviewer` / `plasmawindowed`
  and `journalctl --user -f` for QML errors, following incremental
  verification per constitution
- **Rationale**: No automated test framework exists for plasmoids;
  manual verification per subsystem is the standard approach
- **Alternative rejected**: Writing automated QML tests — disproportionate
  effort for a porting project with no existing test infrastructure
