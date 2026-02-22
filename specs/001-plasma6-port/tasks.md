# Tasks: Port Event Calendar to Plasma 6

**Input**: Design documents from `/specs/001-plasma6-port/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Not included — manual testing via `plasmoidviewer` + `journalctl` per quickstart.md.

**Organization**: Tasks are grouped by user story. Starting from Zren's `upstream/plasma6` branch as the foundation (60-70% complete), then incrementally completing the remaining subsystems.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Branch Foundation)

**Purpose**: Establish the working branch by merging Zren's upstream/plasma6 changes as the starting point.

- [x] T001 Merge Zren's `upstream/plasma6` branch into `001-plasma6-port` branch, resolving any conflicts with master
- [x] T002 Remove `package/metadata.desktop` (replaced by `package/metadata.json` from Zren's branch)
- [x] T003 Verify `package/metadata.json` contains correct fields: KPlugin.Id = `org.kde.plasma.eventcalendar`, KPlugin.Version matches current, KPackageStructure = `Plasma/Applet`, X-Plasma-API-Minimum-Version = `6.0`

---

## Phase 2: Foundational (Mechanical Verification)

**Purpose**: Verify and complete the mechanical replacements from Zren's branch across ALL 105 QML/JS files. These MUST be complete before any user story work begins.

**CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T004 Audit all QML files for remaining versioned imports (e.g., `import QtQuick 2.0`) and remove version numbers in package/contents/ui/**/*.qml
- [ ] T005 [P] Audit all QML files for remaining `PlasmaCore.Units` references and replace with `Kirigami.Units` in package/contents/ui/**/*.qml
- [ ] T006 [P] Audit all QML files for remaining `PlasmaCore.Theme` references and replace with `Kirigami.Theme` in package/contents/ui/**/*.qml (note: `PlasmaCore.Theme.smallestFont` → `Kirigami.Theme.smallFont` is a property rename, not just a prefix swap)
- [ ] T007 [P] Audit all QML files for remaining `PlasmaCore.IconItem` references and replace with `Kirigami.Icon` in package/contents/ui/**/*.qml
- [ ] T008 [P] Audit all QML files for remaining `PlasmaCore.FrameSvgItem`/`SvgItem`/`Svg` references and replace with `KSvg.*` in package/contents/ui/**/*.qml
- [ ] T009 [P] Audit all QML files for remaining `PlasmaCore.DataSource` references and replace with `Plasma5Support.DataSource` in package/contents/ui/**/*.qml
- [ ] T010 [P] Audit all QML files for remaining `PlasmaExtras.Heading` references and replace with `Kirigami.Heading` in package/contents/ui/**/*.qml
- [ ] T011 [P] Remove all `colorGroup` properties from SVG items across package/contents/ui/**/*.qml
- [ ] T012 [P] Audit all QML files for `PlasmaCore.ColorScope` and replace with `Kirigami.Theme` in package/contents/ui/**/*.qml
- [ ] T013 [P] Replace `PlasmaCore.Units.devicePixelRatio` with `1` across package/contents/ui/**/*.qml
- [ ] T014 Verify all QML files have correct `import` statements with proper `as` aliases (Kirigami, KSvg, Plasma5Support, PlasmaComponents3) in package/contents/ui/**/*.qml
- [ ] T104 [P] Audit all QML files for `PlasmaCore.SortFilterModel` and replace with `KItemModels.KSortFilterProxyModel` — update `sortRole` → `sortRoleName`, `filterRegExp` → `filterRegularExpression` in package/contents/ui/**/*.qml

**Checkpoint**: All 105 QML/JS files use exclusively Plasma 6 import paths and type references. Widget may not load yet but the mechanical migration is complete.

---

## Phase 3: User Story 1 - Metadata and Build Infrastructure (Priority: P1)

**Goal**: `sh ./build` produces a valid `.plasmoid` file installable via `kpackagetool6`.

**Independent Test**: Run `sh ./build`, then `kpackagetool6 -t Plasma/Applet -i package.plasmoid`. Widget appears in "Add Widgets" panel.

### Implementation for User Story 1

- [ ] T015 [US1] Verify/fix `build` script — Zren's branch has initial updates; ensure it uses `kpackagetool6`, reads metadata from `package/metadata.json` instead of `package/metadata.desktop` in ./build
- [ ] T016 [P] [US1] Verify/fix `install` script — ensure it uses `kpackagetool6` and `kreadconfig6` (or Python JSON parsing) in ./install
- [ ] T017 [P] [US1] Verify/fix `uninstall` script — ensure it uses `kpackagetool6` in ./uninstall
- [ ] T018 [P] [US1] Verify/fix `update` script — ensure it uses `kpackagetool6` and removes `kstart5` references (use `kstart` or `systemctl --user restart plasma-plasmashell`) in ./update
- [ ] T019 [US1] **DEFERRED** (translations) Update `package/translate/merge` script to extract translatable strings from `package/metadata.json` (KPlugin.Name, KPlugin.Description) instead of `metadata.desktop`
- [ ] T020 [US1] **DEFERRED** (translations) Update `package/translate/build` script to inject translations as `KPlugin.Name[locale]` / `KPlugin.Description[locale]` keys into `package/metadata.json` and generate `.mo` files in `package/contents/locale/`
- [ ] T021 [US1] **DEFERRED** (translations) Verify all 20+ existing `.po` files in `package/translate/` produce valid `.mo` files and metadata.json contains all translated Name/Description fields

**Checkpoint**: `sh ./build` succeeds. `kpackagetool6 -t Plasma/Applet -i package.plasmoid` installs without errors. Widget visible in widget list.

---

## Phase 4: User Story 2 - Widget Loads and Displays Clock (Priority: P2)

**Goal**: Widget loads in Plasma 6 panel, displays current time, no QML errors in journal.

**Independent Test**: Add widget to panel. Clock shows time, updates each minute. `journalctl --user -f` shows no QML errors.

### Implementation for User Story 2

- [ ] T022 [US2] Verify `package/contents/ui/main.qml` uses `PlasmoidItem` as root element with direct properties (`compactRepresentation`, `fullRepresentation`, `toolTipItem`, `hideOnWindowDeactivate`, `expanded`)
- [ ] T023 [US2] Verify declarative `Plasmoid.contextualActions` array with `PlasmaCore.Action` entries (clipboard, adjust time, refresh) in package/contents/ui/main.qml
- [ ] T024 [US2] Port signal handlers in `package/contents/ui/main.qml` to `function onSignalName()` syntax
- [ ] T025 [US2] Port `package/contents/ui/ClockView.qml` — verify clock rendering, update signal handlers to function syntax, replace any PC2 components
- [ ] T026 [US2] Port `package/contents/ui/TimeModel.qml` — update `Plasma5Support.DataSource` usage, port signal handlers (especially `onNewData` with named parameters)
- [ ] T027 [US2] Port `package/contents/ui/Logic.qml` — update signal handlers, verify `plasmoid.configuration` references work
- [ ] T028 [US2] Port `package/contents/ui/ConfigMigration.qml` — verify config key migration logic works with Plasma 6
- [ ] T029 [US2] Port `package/contents/ui/AppletConfig.qml` — update config page registration for KCM.SimpleKCM root elements
- [ ] T030 [US2] Replace all `plasmoid.expanded` references with `root.expanded` across package/contents/ui/**/*.qml
- [ ] T031 [US2] Port `package/contents/ui/LocaleFuncs.js` — verify locale functions work with Qt 6 APIs
- [ ] T032 [US2] Port `package/contents/ui/TimeFormatSizeHelper.qml` — update any PlasmaCore references

**Checkpoint**: Widget loads in panel, clock displays and updates. No QML errors in journal. Context menu works (Copy to Clipboard, Adjust Date and Time).

---

## Phase 5: User Story 3 - Popup Opens with Calendar and Agenda (Priority: P3)

**Goal**: Clicking the clock opens popup with month calendar and agenda view. Navigation and date selection work.

**Independent Test**: Click widget in panel. Popup opens with calendar and agenda. Navigate months. Select a date.

### Implementation for User Story 3

- [ ] T033 [US3] Port `package/contents/ui/PopupView.qml` — fix PC2 remnants, verify single/dual column layout, update signal handlers
- [ ] T034 [US3] Port `package/contents/ui/MonthView.qml` — update rendering, signal handlers, verify month navigation
- [ ] T035 [US3] Port `package/contents/ui/DaysCalendar.qml` — update day cell grid rendering, replace any PC2 components
- [ ] T036 [P] [US3] Port `package/contents/ui/DayDelegate.qml` — update individual day cell rendering, event badge display
- [ ] T037 [P] [US3] Port `package/contents/ui/DateSelector.qml` — update date picker controls
- [ ] T038 [P] [US3] Port `package/contents/ui/DateTimeSelector.qml` — update date/time picker controls
- [ ] T039 [US3] Port `package/contents/ui/AgendaView.qml` — replace `flickableItem` with PC3 `ScrollView`, update signal handlers, fix scrolling
- [ ] T040 [P] [US3] Port `package/contents/ui/AgendaModel.qml` — update data model, signal handlers
- [ ] T041 [P] [US3] Port `package/contents/ui/AgendaListItem.qml` — update list item rendering
- [ ] T042 [P] [US3] Port `package/contents/ui/AgendaEventItem.qml` — update event item display
- [ ] T043 [P] [US3] Port `package/contents/ui/AgendaTaskItem.qml` — update task item display
- [ ] T044 [US3] Port `package/contents/ui/EventModel.qml` — update event data model, signal handlers
- [ ] T045 [P] [US3] Port `package/contents/ui/EventPropertyIcon.qml` — update icon rendering
- [ ] T046 [P] [US3] Port `package/contents/ui/LinkRect.qml` and `package/contents/ui/LinkText.qml` — update link components
- [ ] T047 [P] [US3] Port badge components in `package/contents/ui/badges/` — update all badge QML files
- [ ] T048 [US3] Port `package/contents/ui/CalendarSelector.qml` — update calendar source selector

**Checkpoint**: Popup opens with calendar and agenda. Today is highlighted. Month navigation works. Date selection scrolls agenda.

---

## Phase 6: User Story 4 - Configuration Panels Work (Priority: P4)

**Goal**: All 9 configuration tabs load, render controls, and persist settings.

**Independent Test**: Open settings, navigate each tab, change a setting, Apply, close/reopen, verify persistence.

### Implementation for User Story 4

- [ ] T049 [US4] Port `package/contents/ui/lib/ConfigPage.qml` — change root element from `Item` to `KCM.SimpleKCM`, add `import org.kde.kcmutils as KCM`
- [ ] T050 [US4] Port `package/contents/ui/config/ConfigGeneral.qml` — update to KCM.SimpleKCM root, replace PC2 components with PC3
- [ ] T051 [P] [US4] Port `package/contents/ui/config/ConfigLayout.qml` — update to KCM.SimpleKCM root, replace PC2 components
- [ ] T052 [P] [US4] Port `package/contents/ui/config/ConfigTimezones.qml` — update to KCM.SimpleKCM root, replace PC2 components
- [ ] T053 [P] [US4] Port `package/contents/ui/config/ConfigCalendar.qml` — update to KCM.SimpleKCM root, replace PC2 components
- [ ] T054 [P] [US4] Port `package/contents/ui/config/ConfigAgenda.qml` — update to KCM.SimpleKCM root, replace PC2 components
- [ ] T055 [P] [US4] Port `package/contents/ui/config/ConfigEvents.qml` — update to KCM.SimpleKCM root, replace PC2 components
- [ ] T056 [P] [US4] Port `package/contents/ui/config/ConfigICal.qml` — update to KCM.SimpleKCM root, replace PC2 components
- [ ] T057 [P] [US4] Port `package/contents/ui/config/ConfigGoogleCalendar.qml` — update to KCM.SimpleKCM root, replace PC2 components
- [ ] T058 [P] [US4] Port `package/contents/ui/config/ConfigWeather.qml` — update to KCM.SimpleKCM root, replace PC2 components
- [ ] T059 [US4] Port config utility components: `package/contents/ui/lib/ConfigCheckBox.qml`, `ConfigComboBox.qml`, `ConfigColor.qml`, `ConfigDimension.qml`, `ConfigFontFamily.qml`, `ConfigNotification.qml`, `ConfigRadioButtonGroup.qml`, `ConfigSection.qml`, `ConfigSlider.qml`, `ConfigSound.qml`, `ConfigSpinBox.qml`, `ConfigString.qml`, `ConfigAdvanced.qml` — update all PC2 references to PC3
- [ ] T060 [P] [US4] Port `package/contents/ui/lib/ColorGrid.qml` — update color picker component
- [ ] T061 [P] [US4] Port `package/contents/ui/config/ColorTextButton.qml` — update color button component
- [ ] T062 [P] [US4] Port `package/contents/ui/config/HeaderText.qml` and `package/contents/ui/config/LockIcon.qml` — update header/lock components
- [ ] T063 [US4] Port `package/contents/ui/config/ConfigSerializedString.qml` — update serialized string config handling

**Checkpoint**: All 9 config tabs open without errors, controls render, settings persist across close/reopen.

---

## Phase 7: User Story 5 - Google Calendar Integration (Priority: P5)

**Goal**: Google Calendar OAuth flow completes, events sync and display in agenda and as calendar badges.

**Independent Test**: Complete OAuth flow in Google Calendar settings tab. Events appear in agenda and on calendar day cells.

### Implementation for User Story 5

- [ ] T064 [US5] Un-comment and port `package/contents/ui/calendars/CalendarManager.qml` — restore calendar orchestrator, update signal handlers and imports
- [ ] T065 [US5] Un-comment and port `package/contents/ui/calendars/GoogleCalendarManager.qml` — restore Google Calendar sync, update signal handlers, reference ALikesToCode fork for per-calendar error resilience patterns
- [ ] T066 [US5] Un-comment and port `package/contents/ui/calendars/GoogleApiSession.qml` — restore OAuth session management, update signal handlers
- [ ] T067 [US5] Port `package/contents/ui/config/GoogleLoginManager.qml` — update OAuth login UI flow
- [ ] T068 [US5] Un-comment and port `package/contents/ui/calendars/GoogleTasksManager.qml` — restore Google Tasks sync
- [ ] T069 [US5] Port `package/contents/ui/EditEventForm.qml` — update event creation/editing form, replace PC2 components
- [ ] T070 [P] [US5] Port `package/contents/ui/EditTaskForm.qml` — update task editing form, replace PC2 components
- [ ] T071 [P] [US5] Port `package/contents/ui/NewEventForm.qml` — update new event form, replace PC2 components
- [ ] T072 [US5] Wire CalendarManager back into `package/contents/ui/main.qml` and `package/contents/ui/Logic.qml` — ensure event data flows to AgendaView and MonthView

**Checkpoint**: OAuth flow completes. Events from Google Calendar appear in agenda. Event badges show on calendar dates. Multi-calendar selection works.

---

## Phase 8: User Story 6 - ICalendar and Plasma Native Calendar (Priority: P6)

**Goal**: ICalendar (.ics) URLs and Plasma native calendar plugins provide events alongside Google Calendar.

**Independent Test**: Configure an .ics URL. Events appear in agenda. Enable Plasma calendar plugin. Its events also appear.

### Implementation for User Story 6

- [ ] T073 [US6] Un-comment and port `package/contents/ui/calendars/ICalManager.qml` — restore .ics file/URL fetching, update signal handlers and imports
- [ ] T074 [US6] Un-comment and port `package/contents/ui/calendars/PlasmaCalendarManager.qml` — restore native Plasma calendar plugin integration, update `org.kde.plasma.workspace.calendar` import, update signal handlers
- [ ] T075 [US6] Verify `package/contents/ui/calendars/PlasmaCalendarUtils.js` works with Plasma 6 calendar API
- [ ] T076 [US6] Verify multi-source event merging in CalendarManager — events from Google, ICS, and Plasma native all appear with correct colors

**Checkpoint**: ICalendar and Plasma native calendar events appear alongside Google Calendar events in agenda and on calendar day cells.

---

## Phase 9: User Story 7 - Weather and Meteogram (Priority: P7)

**Goal**: Weather forecast displays in meteogram and agenda day headers.

**Independent Test**: Configure a city in Weather settings. Meteogram renders. Weather icons appear in agenda.

### Implementation for User Story 7

- [ ] T077 [US7] Port `package/contents/ui/MeteogramView.qml` — update Canvas rendering, replace PC2 components, update signal handlers
- [ ] T078 [US7] Port weather data fetching in `package/contents/ui/Logic.qml` — verify OpenWeatherMap API calls work with Qt 6 XMLHttpRequest
- [ ] T079 [P] [US7] Port `package/contents/ui/config/OpenWeatherMapCityDialog.qml` — update city search dialog, replace PC2 components
- [ ] T080 [P] [US7] Port `package/contents/ui/config/WeatherCanadaCityDialog.qml` — update Environment Canada city search dialog, replace PC2 components
- [ ] T081 [US7] Verify weather icons display in agenda day headers in `package/contents/ui/AgendaView.qml`

**Checkpoint**: Meteogram renders with forecast data. Weather icons appear in agenda. Both OpenWeatherMap and Environment Canada providers work.

---

## Phase 10: User Story 8 - Timer, Tooltip, and Notifications (Priority: P8)

**Goal**: Timer counts down with sound. Tooltip shows upcoming events. Notifications fire for reminders.

**Independent Test**: Start a short timer, verify countdown and sound. Hover over panel widget for tooltip. Configure event reminder and verify notification.

### Implementation for User Story 8

- [ ] T082 [US8] Port timer view (in `package/contents/ui/PopupView.qml` timer section) — replace PC2 ContextMenu with PC3 Menu for timer presets
- [ ] T083 [US8] Port `package/contents/ui/lib/ContextMenu.qml` — replace PlasmaComponents 2 `ContextMenu` with PlasmaComponents 3 `Menu`
- [ ] T084 [US8] Port `package/contents/ui/lib/MenuItem.qml` — replace PlasmaComponents 2 `MenuItem` with PlasmaComponents 3 equivalent
- [ ] T085 [US8] Port `package/contents/ui/DurationSelector.qml` — update timer duration picker, replace PC2 components
- [ ] T086 [US8] Port tooltip rendering in `package/contents/ui/main.qml` — verify `toolTipItem` displays upcoming events on hover
- [ ] T087 [US8] Port `package/contents/ui/NotificationManager.qml` — update notification dispatching, verify `Plasma5Support.DataSource` for executable engine works with `notify-send` or KDE notification system
- [ ] T088 [US8] Port `package/contents/ui/lib/ExecUtil.qml` — verify command execution via `Plasma5Support.DataSource` executable engine

**Checkpoint**: Timer counts down and plays sound. Tooltip shows upcoming events. Notifications fire for event reminders.

---

## Phase 11: User Story 9 - Full Feature Parity and Polish (Priority: P9)

**Goal**: Every Plasma 5 feature works identically on Plasma 6.

**Independent Test**: Compare every feature from Plasma 5 config panels against Plasma 6 port.

### Implementation for User Story 9

- [ ] T089 [US9] Port Clock Line 2 support in `package/contents/ui/ClockView.qml` — verify second line of clock text renders
- [ ] T090 [P] [US9] Port mouse wheel actions on clock in `package/contents/ui/ClockView.qml` — verify `onWheel: (wheel) =>` syntax works
- [ ] T091 [P] [US9] Port timezone display in `package/contents/ui/PopupView.qml` — verify timezone list renders
- [ ] T092 [US9] Port `package/contents/ui/FontIcon.qml` — update custom font icon rendering
- [ ] T093 [US9] Port `package/contents/ui/NetworkMonitor.qml` and `package/contents/ui/NetworkMonitorPlasmaNM.qml` — update network monitoring for online/offline detection
- [ ] T094 [US9] Port `package/contents/ui/lib/MessageWidget.qml` — update message/warning widget
- [ ] T095 [US9] Port `package/contents/ui/lib/Logger.qml` — verify debug logging works with Qt 6
- [ ] T096 [US9] Port `package/contents/ui/lib/AppletVersion.qml` — update version display
- [ ] T097 [US9] Port remaining utility files: `package/contents/ui/Shared.js`, `package/contents/ui/ErrorType.js`, `package/contents/ui/lib/Async.js`, `package/contents/ui/lib/Requests.js`, `package/contents/ui/lib/ColorUtil.js`, `package/contents/ui/lib/Base64Json.qml`, `package/contents/ui/lib/Base64JsonListModel.qml`
- [ ] T098 [US9] Complete signal handler modernization: audit ALL remaining QML files for `onSignalName:` without `function` keyword and update to `function onSignalName()` syntax
- [ ] T099 [US9] Verify `package/contents/ui/calendars/DebugCalendarManager.qml` and `package/contents/ui/calendars/DebugGoogleCalendarManager.qml` work for development testing
- [ ] T100 [US9] Verify all `package/contents/ui/calendars/GoogleCalendarTests.js` test helpers work
- [ ] T101 [US9] **DEFERRED** (translations) Verify all 20+ translations display correctly — run `sh ./build` and check `.mo` files are bundled, test with `LANGUAGE=de plasmoidviewer -a org.kde.plasma.eventcalendar`
- [ ] T102 [US9] Verify config key compatibility — install on system with existing Plasma 5 config and verify settings are preserved, including that existing Google OAuth tokens from Plasma 5 still work without re-authorization
- [ ] T103 [US9] Full integration test: verify all 11 success criteria (SC-001 through SC-011) from spec.md pass
- [ ] T105 [US9] Add graceful degradation when `plasma5support` package is not installed — DataSource-dependent features (time, command execution) should display a meaningful error message rather than crash the widget
- [ ] T106 [US9] Optionally add `pragma ComponentBehavior: Bound` to QML files where it does not cause regressions (Plasma 6 best practice, per constitution opt-in)

**Checkpoint**: All Plasma 5 features work on Plasma 6. All 20+ translations correct. Config keys compatible. Full feature parity confirmed.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (branch merged)
- **US1 (Phase 3)**: Depends on Phase 2 (mechanical replacements complete)
- **US2 (Phase 4)**: Depends on US1 (widget must install to test loading)
- **US3 (Phase 5)**: Depends on US2 (widget must load to test popup)
- **US4 (Phase 6)**: Depends on US2 (widget must load to test config)
- **US5 (Phase 7)**: Depends on US3 + US4 (agenda view + config panels needed)
- **US6 (Phase 8)**: Depends on US5 (CalendarManager must be working)
- **US7 (Phase 9)**: Depends on US3 (agenda view for weather icons)
- **US8 (Phase 10)**: Depends on US3 (popup must work for timer/tooltip)
- **US9 (Phase 11)**: Depends on ALL previous user stories

### User Story Dependencies

```
US1 (Metadata/Build)
 └─▶ US2 (Clock/Load)
      ├─▶ US3 (Popup/Calendar/Agenda)
      │    ├─▶ US5 (Google Calendar) ←── also needs US4
      │    │    └─▶ US6 (ICalendar/Plasma Native)
      │    ├─▶ US7 (Weather)
      │    └─▶ US8 (Timer/Tooltip/Notifications)
      └─▶ US4 (Config Panels)
           └─▶ US5 (Google Calendar)

All ──▶ US9 (Full Parity/Polish)
```

### Parallel Opportunities

After US3 + US4 are complete, these can run in parallel:
- **US5** (Google Calendar) + **US7** (Weather) + **US8** (Timer/Tooltip)
- US6 must follow US5 (depends on CalendarManager)

Within phases, tasks marked [P] can run in parallel.

---

## Parallel Example: User Story 4

```
# Config pages can all be ported in parallel (different files):
Task: "Port ConfigLayout.qml"      → package/contents/ui/config/ConfigLayout.qml
Task: "Port ConfigTimezones.qml"   → package/contents/ui/config/ConfigTimezones.qml
Task: "Port ConfigCalendar.qml"    → package/contents/ui/config/ConfigCalendar.qml
Task: "Port ConfigAgenda.qml"      → package/contents/ui/config/ConfigAgenda.qml
Task: "Port ConfigEvents.qml"      → package/contents/ui/config/ConfigEvents.qml
Task: "Port ConfigICal.qml"        → package/contents/ui/config/ConfigICal.qml
Task: "Port ConfigGoogleCalendar.qml" → package/contents/ui/config/ConfigGoogleCalendar.qml
Task: "Port ConfigWeather.qml"     → package/contents/ui/config/ConfigWeather.qml
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup (merge Zren's branch)
2. Complete Phase 2: Foundational (verify mechanical replacements)
3. Complete Phase 3: US1 (build scripts + translations)
4. Complete Phase 4: US2 (widget loads, clock displays)
5. **STOP and VALIDATE**: Widget installs, loads, shows clock, no QML errors

### Incremental Delivery

1. Setup + Foundational + US1 + US2 → Widget loads with clock (MVP)
2. Add US3 → Popup with calendar and agenda
3. Add US4 → All config panels work
4. Add US5 → Google Calendar syncs
5. Add US6 → ICalendar and Plasma native calendars
6. Add US7 → Weather and meteogram
7. Add US8 → Timer, tooltip, notifications
8. Add US9 → Full feature parity confirmed

Each increment is independently testable and deployable.

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- All file paths are relative to repository root (`/data/dev/plasma-applet-eventcalendar/`)
- Reference Zren's `upstream/plasma6` for structural patterns
- Reference ALikesToCode's `alikestocode/master` for signal handler syntax and resilience patterns
- Commit after each completed phase or logical group of tasks
- Stop at any checkpoint to validate story independently
