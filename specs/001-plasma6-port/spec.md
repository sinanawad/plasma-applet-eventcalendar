# Feature Specification: Port Event Calendar to Plasma 6

**Feature Branch**: `001-plasma6-port`
**Created**: 2026-02-22
**Status**: Draft
**Input**: User description: "Port this Plasma 5 plasmoid to Plasma 6, iteratively, leveraging prior work, starting with basic features and extending each iteration."

## Assumptions

- The target is KDE Plasma 6 with Qt 6 and KDE Frameworks 6
- The Plasma 5 version (current master) is the source of truth for feature parity
- Zren's upstream `plasma6` branch and ALikesToCode's fork exist as prior art and will be evaluated for quality before adoption
- Users currently running Event Calendar on Plasma 5 expect the same features and appearance on Plasma 6
- The widget will be distributed as a `.plasmoid` package via KDE Store (same as Plasma 5), not as a CMake-built KDE project
- All 20+ existing translations will be preserved
- The `plasmoidviewer` or `plasmawindowed` tool from plasma-sdk is available for testing during development

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Metadata and Build Infrastructure (Priority: P1)

A developer checks out the ported branch, runs `sh ./build`, and
produces a valid `.plasmoid` file. The build scripts, metadata, and
translation workflow all work with Plasma 6 tooling.

**Why this priority**: Nothing else can be tested until the widget
can be packaged and installed on a Plasma 6 system. This is the
foundation for every subsequent story.

**Independent Test**: Run `sh ./build` to produce a `.plasmoid`
file, then `kpackagetool6 -t Plasma/Applet -i <file>` to install
it. The widget appears in the "Add Widgets" panel (even if it
fails to render).

**Acceptance Scenarios**:

1. **Given** a fresh checkout of the ported branch, **When** the
   developer runs `sh ./build`, **Then** a `.plasmoid` file is
   produced without errors
2. **Given** the built `.plasmoid` file, **When** installed via
   `kpackagetool6 -t Plasma/Applet -i <file>`, **Then** the
   widget appears in Plasma 6's widget list with correct name,
   icon, and description
3. **Given** the ported metadata.json, **When** Plasma 6 reads it,
   **Then** it recognizes the widget as Plasma 6 compatible
   (no "unknown older version" warning)
4. **Given** existing `.po` translation files, **When** the
   translation build script runs, **Then** `.mo` files are
   generated and the metadata.json contains translated Name and
   Description fields for all 20+ locales

---

### User Story 2 - Widget Loads and Displays Clock (Priority: P2)

A user adds the Event Calendar widget to their Plasma 6 panel. The
widget loads without QML errors and displays the current time in
the panel (compact representation). The clock is readable and
updates every minute.

**Why this priority**: The clock is the always-visible panel
element. If it renders correctly, it proves the core QML
infrastructure (PlasmoidItem, TimeModel, imports) is working.

**Independent Test**: Add the widget to a Plasma 6 panel. The
clock shows the current time, updates each minute, and no errors
appear in `journalctl --user -f` QML output.

**Acceptance Scenarios**:

1. **Given** the widget is installed on Plasma 6, **When** the
   user adds it to a panel, **Then** the compact representation
   shows the current time
2. **Given** the clock is displaying, **When** a minute passes,
   **Then** the displayed time updates
3. **Given** the widget is loaded, **When** the user checks the
   system journal, **Then** there are no QML errors from the
   widget
4. **Given** the widget is in the panel, **When** the user
   right-clicks it, **Then** the context menu shows correctly
   with the "Copy to Clipboard" and "Adjust Date and Time"
   actions

---

### User Story 3 - Popup Opens with Calendar and Agenda (Priority: P3)

A user clicks the clock in the panel and the popup opens showing
both the month calendar and the agenda view. The calendar
highlights today's date and the agenda shows the correct date
range.

**Why this priority**: The popup is the primary interaction point.
Calendar and agenda are the two core views that define this
widget's purpose.

**Independent Test**: Click the widget in the panel. The popup
opens with a visible month calendar and agenda area. Navigate
months forward/backward. Select a date and see the agenda update.

**Acceptance Scenarios**:

1. **Given** the widget is in a panel, **When** the user clicks
   it, **Then** the popup opens showing the month calendar and
   agenda in the configured layout (single or dual column)
2. **Given** the popup is open, **When** the user looks at the
   calendar, **Then** today's date is highlighted and the current
   month is displayed
3. **Given** the popup is open, **When** the user clicks the
   next/previous month arrows, **Then** the calendar navigates
   to the adjacent month
4. **Given** the popup is open, **When** the user clicks a date
   in the calendar, **Then** the agenda scrolls to show that
   date's events
5. **Given** the popup is open in dual-column mode, **When** the
   user resizes the popup, **Then** both columns adjust
   proportionally

---

### User Story 4 - Configuration Panels Work (Priority: P4)

A user right-clicks the widget, opens settings, and can navigate
all configuration tabs (General, Layout, Timezones, Calendar,
Agenda, Events, ICalendar, Google Calendar, Weather). Each tab
loads, displays its controls, and saves changes.

**Why this priority**: Users must be able to configure the widget
to connect to their calendars, set their location for weather,
and customize appearance. Without configuration, features like
Google Calendar and weather remain inaccessible.

**Independent Test**: Open settings, navigate to each tab, change
a setting, click Apply, close and reopen settings, verify the
setting persisted.

**Acceptance Scenarios**:

1. **Given** the widget is in a panel, **When** the user opens
   settings, **Then** all configuration tabs are visible and
   labeled correctly
2. **Given** a configuration tab is selected, **When** the tab
   loads, **Then** all controls render without errors and reflect
   current saved values
3. **Given** the user changes a setting, **When** they click
   Apply, **Then** the setting is persisted and takes effect
   immediately
4. **Given** the user closes and reopens settings, **When** they
   view a previously changed setting, **Then** the saved value is
   displayed correctly

---

### User Story 5 - Google Calendar Integration (Priority: P5)

A user connects their Google account through the settings panel,
authorizes the widget, and sees their Google Calendar events
displayed in the agenda and as badges on calendar dates.

**Why this priority**: Google Calendar sync is the headline feature
that distinguishes this widget from the default Plasma clock. It is
the most-used integration.

**Independent Test**: Go to Google Calendar settings tab, complete
OAuth flow, wait for sync, verify events from Google Calendar
appear in the agenda and on calendar day cells.

**Acceptance Scenarios**:

1. **Given** the Google Calendar config tab is open, **When** the
   user initiates the OAuth flow, **Then** they receive a code
   and can authorize at the provided URL
2. **Given** the OAuth flow is completed, **When** the widget
   syncs, **Then** events from the user's Google Calendar appear
   in the agenda
3. **Given** events are synced, **When** the user views the month
   calendar, **Then** dates with events show event indicator badges
4. **Given** events are displayed, **When** the user clicks an
   event in the agenda, **Then** the event details are shown
   (time, location, description)
5. **Given** the user has multiple Google Calendars, **When** they
   select which calendars to display in settings, **Then** only
   events from selected calendars appear

---

### User Story 6 - ICalendar and Plasma Native Calendar Integration (Priority: P6)

A user configures ICalendar (.ics) URLs or enables Plasma native
calendar plugins, and events from those sources appear alongside
Google Calendar events in the agenda and calendar views.

**Why this priority**: These are the other two calendar backends.
They enable users who don't use Google Calendar (or use it alongside
local calendars) to see all their events in one place.

**Independent Test**: Configure an ICalendar URL pointing to a
public .ics file. Verify events from that file appear in the
agenda. Enable a Plasma calendar plugin and verify its events
also appear.

**Acceptance Scenarios**:

1. **Given** an ICalendar URL is configured in settings, **When**
   the widget fetches the .ics file, **Then** events from the file
   appear in the agenda
2. **Given** a Plasma native calendar plugin is enabled, **When**
   the widget loads, **Then** events from that plugin source appear
   in the agenda
3. **Given** events from multiple sources exist on the same date,
   **When** the user views the agenda, **Then** all events are
   shown with their source calendar's color

---

### User Story 7 - Weather and Meteogram (Priority: P7)

A user configures their location for weather, and the meteogram
view displays the weather forecast. Weather information also
appears in the agenda for upcoming days.

**Why this priority**: Weather integration is a popular feature
but is independent of calendar functionality. It can be ported
after calendar features are stable.

**Independent Test**: Configure a city in the Weather settings tab.
Verify the meteogram renders with temperature and precipitation
data. Check that weather icons appear in the agenda's day headers.

**Acceptance Scenarios**:

1. **Given** a weather location is configured, **When** the widget
   fetches weather data, **Then** the meteogram displays a forecast
   graph
2. **Given** weather data is loaded, **When** the popup is open,
   **Then** weather icons and temperatures appear in the agenda's
   day headers
3. **Given** the OpenWeatherMap provider is selected, **When**
   weather data is requested, **Then** data is fetched and rendered
   correctly
4. **Given** the Environment Canada provider is selected, **When**
   weather data is requested, **Then** data is fetched and rendered
   correctly

---

### User Story 8 - Timer, Tooltip, and Notifications (Priority: P8)

The timer widget works (start, pause, reset, sound on completion).
Hovering over the panel widget shows a tooltip with upcoming events.
Desktop notifications fire for event reminders.

**Why this priority**: These are secondary features that enhance
the experience but are not required for core calendar/weather
functionality.

**Independent Test**: Set a short timer duration, start it, verify
countdown and completion sound. Hover over the panel clock and
check the tooltip content. Configure a notification-enabled event
and verify the notification fires.

**Acceptance Scenarios**:

1. **Given** the timer is visible in the popup, **When** the user
   sets a duration and clicks start, **Then** the timer counts down
   and plays a sound on completion
2. **Given** events are synced, **When** the user hovers over the
   panel widget, **Then** a tooltip shows upcoming events
3. **Given** a calendar event has a reminder, **When** the
   reminder time arrives, **Then** a desktop notification is
   displayed with the event details

---

### User Story 9 - Full Feature Parity and Polish (Priority: P9)

All features from the Plasma 5 version work identically on Plasma
6. This includes: clock line 2, mouse wheel actions on the clock,
timezone display, Google Tasks, event creation/editing, all visual
styling options, and all keyboard interactions.

**Why this priority**: This is the final polish pass to ensure
nothing was missed. Individual features may be caught by earlier
stories, but this story ensures completeness.

**Independent Test**: Compare every feature listed in the Plasma 5
widget's configuration panels against the Plasma 6 port. Verify
each feature works identically.

**Acceptance Scenarios**:

1. **Given** the Plasma 5 feature list, **When** each feature is
   tested on Plasma 6, **Then** it works identically to the Plasma
   5 version
2. **Given** all translations are bundled, **When** a user runs
   Plasma 6 in a non-English locale, **Then** the widget displays
   translated text matching the Plasma 5 translation quality
3. **Given** a user's existing Plasma 5 configuration, **When**
   they install the Plasma 6 version, **Then** their settings
   are preserved (same config keys, same defaults)

---

### Edge Cases

- What happens when the widget is installed on a system still
  running Plasma 5? The metadata.json with
  `X-Plasma-API-Minimum-Version: "6.0"` ensures Plasma 5 ignores
  it. The Plasma 5 version (metadata.desktop) remains separate.
- What happens when Google OAuth tokens from the Plasma 5 version
  are present in the config? They should still work since OAuth
  tokens are independent of the widget's Plasma version.
- What happens when the `plasma5support` package is not installed?
  DataSource-dependent features (time, command execution) will
  fail. The widget should display a meaningful error rather than
  crash.
- What happens when a user has custom ICalendar URLs with special
  characters? The Python `icsjson.py` script is unchanged, so
  existing behavior is preserved.
- What happens if `plasmoid.configuration` keys differ between
  Plasma 5 and 6? The `main.xml` schema is unchanged, so config
  keys remain compatible. ConfigMigration handles older key names.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Widget MUST package as a `.plasmoid` file installable
  via `kpackagetool6 -t Plasma/Applet`
- **FR-002**: Widget MUST include a valid `metadata.json` with
  `KPackageStructure`, `X-Plasma-API-Minimum-Version: "6.0"`,
  and all required KPlugin fields
- **FR-003**: Widget MUST use `PlasmoidItem` as the root QML
  element in main.qml
- **FR-004**: Widget MUST use exclusively unversioned QML imports
- **FR-005**: Widget MUST NOT import or use PlasmaComponents 2
- **FR-006**: Widget MUST use Kirigami for Units, Theme, and Icon
  instead of PlasmaCore equivalents
- **FR-007**: Widget MUST use KSvg for SVG rendering instead of
  PlasmaCore SVG types
- **FR-008**: Widget MUST use Plasma5Support.DataSource for time
  data and command execution
- **FR-009**: Widget MUST use declarative contextual actions
  instead of imperative setAction/action_ pattern
- **FR-010**: All configuration pages MUST use KCM.SimpleKCM as
  their root element
- **FR-011**: Widget MUST display the current time in the panel
  compact representation
- **FR-012**: Widget MUST show a popup with calendar and agenda
  when clicked
- **FR-013**: Widget MUST sync with Google Calendar via OAuth
- **FR-014**: Widget MUST support ICalendar (.ics) file/URL
  sources
- **FR-015**: Widget MUST integrate with Plasma native calendar
  plugins
- **FR-016**: Widget MUST display weather forecasts via
  OpenWeatherMap and Environment Canada
- **FR-017**: Widget MUST include a working countdown timer
- **FR-018**: Widget MUST show a tooltip with upcoming events on
  hover
- **FR-019**: Widget MUST send desktop notifications for event
  reminders
- **FR-020**: Build scripts (build, install, uninstall, update)
  MUST work with Plasma 6 tooling (kpackagetool6, kreadconfig6
  or equivalent)
- **FR-021**: Translation scripts MUST produce correct .mo files
  and inject translations into metadata.json
- **FR-022**: All 20+ existing locale translations MUST be
  preserved and functional
- **FR-023**: All signal handlers MUST use Qt 6 function syntax

### Key Entities

- **PlasmoidItem**: The root QML element replacing Item, owns
  display properties (representations, tooltip, expanded state)
- **metadata.json**: Package descriptor replacing metadata.desktop,
  contains KPlugin info, KPackageStructure, and API version
- **Plasma5Support.DataSource**: Compatibility wrapper for data
  engines (time, executable), replacing PlasmaCore.DataSource
- **KCM.SimpleKCM**: Root element for configuration pages,
  replacing plain Item

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Widget installs and loads on Plasma 6 without any
  QML errors in the system journal
- **SC-002**: All 9 configuration tabs open, render controls, and
  persist settings correctly
- **SC-003**: Clock displays in the panel and updates on schedule
- **SC-004**: Calendar month view renders with correct dates,
  navigation, and event badges
- **SC-005**: Agenda displays events from all configured calendar
  sources
- **SC-006**: Google Calendar OAuth flow completes and events sync
  within one poll interval
- **SC-007**: Weather data loads and the meteogram renders for
  both supported providers
- **SC-008**: Timer counts down and plays sound on completion
- **SC-009**: Tooltip shows upcoming events when hovering over
  the panel widget
- **SC-010**: All 20+ translations display correctly in their
  respective locales
- **SC-011**: Every feature available in the Plasma 5 version
  has a working equivalent in the Plasma 6 version
