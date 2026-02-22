# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **Event Calendar**, a KDE Plasma 5 plasmoid (widget) that provides a calendar+agenda with weather integration and Google Calendar sync. Plugin ID: `org.kde.plasma.eventcalendar`.

- **Target platform**: Plasma 5 (Qt 5.12+, KDE Frameworks 5.68+, Plasma 5.18+)
- **Language**: QML/JavaScript for UI and logic, Python 3 for backend scripts
- **No C++ component** — this is a pure QML plasmoid

## Build & Development Commands

```bash
# Install the plasmoid locally (converts metadata, runs kpackagetool5)
sh ./install

# Install and restart plasmashell to see changes immediately
sh ./install --restart

# Build a distributable .plasmoid file (runs translations, creates zip)
sh ./build

# Update from git and reinstall
sh ./update

# Uninstall the plasmoid
sh ./uninstall

# Test with plasmoidviewer (from plasma-sdk package)
sh package/translate/plasmoidlocaletest

# Run translation extraction and merge
cd package/translate && sh ./merge

# Build translation .mo files
cd package/translate && sh ./build
```

**Key tools required**: `kreadconfig5`, `kpackagetool5`, `desktoptojson`, `xgettext`, `msgmerge`, `msgfmt`, `zip`, `python3`

## Architecture

### Entry Point & Core Models

`package/contents/ui/main.qml` is the main entry point. It instantiates all core singletons:

- **TimeModel** — wraps Plasma's "time" DataSource engine, tracks timezones
- **EventModel** — aggregates events from all calendar sources into a unified format
- **AgendaModel** — processes EventModel data into date-grouped agenda display
- **TimerModel** — countdown timer state machine
- **AppletConfig** — typed access to configuration with color utilities
- **ConfigMigration** — handles config key renames between versions

### Calendar Manager Pattern

Calendar sources live in `package/contents/ui/calendars/` and follow a common pattern:

- **CalendarManager.qml** — base type with shared signals (`fetchingData`, `allDataFetched`, `calendarFetched`, `eventAdded/Updated/Removed`)
- **GoogleCalendarManager.qml** — Google Calendar API via OAuth 2.0 (uses `GoogleApiSession.qml`)
- **GoogleTasksManager.qml** — Google Tasks API
- **ICalManager.qml** — ICS files via Python `icsjson.py` backend
- **PlasmaCalendarManager.qml** — KDE native calendar plugins (Evolution Data Server, etc.)

All calendar managers normalize their data to **Google Calendar API JSON format** (`{ "items": [...] }`).

### Views

`package/contents/ui/PopupView.qml` is the main popup layout, supporting single-column and dual-column modes. Key views:

- **MonthView** — calendar grid with event indicators (DayDelegate cells)
- **AgendaView** — date-grouped event list (AgendaListItem, AgendaEventItem, AgendaTaskItem)
- **MeteogramView** — graphical weather forecast
- **TimerView** — countdown timer with presets
- **ClockView** — configurable clock display (panel representation)

### Weather Providers

Located in `package/contents/ui/weather/`:
- **WeatherApi.js** — abstraction layer selecting provider from config
- **OpenWeatherMap.js** and **WeatherCanada.js** — provider implementations

### Configuration

- **Schema**: `package/contents/config/main.xml` — 230+ config keys in groups (General, Calendar, Agenda, Events, Weather, Google Calendar, etc.)
- **Config UI tabs**: `package/contents/config/config.qml` maps to `package/contents/ui/config/Config*.qml` files
- **Access pattern**: `plasmoid.configuration.keyName` in QML

### Utilities

`package/contents/ui/lib/` contains reusable components: Logger, ExecUtil, ConfigWidgets, ColorUtil, Async helpers, Base64Json storage.

### Backend Scripts

`package/contents/scripts/`:
- `icsjson.py` — converts ICS to JSON (Google Calendar API format)
- `konsolekalendar.py` — wraps KDE's konsolekalendar CLI for adding events
- `notification.py` — desktop notification dispatch

## Translation (i18n)

Translations are in `package/translate/`. The workflow:

1. Use `i18n()`, `i18nc()`, `i18np()`, `i18ncp()` in QML/JS for translatable strings
2. `sh ./merge` extracts strings to `template.pot` and updates all `*.po` files
3. `sh ./build` compiles `*.po` → `*.mo` files into `contents/locale/`
4. Translations are bundled in the `.plasmoid` archive

The `build` script **will fail** if there are uncommitted translation changes (it runs `git diff` check). Always commit translation updates before building.

## Important Conventions

- **Debugging**: controlled by `plasmoid.configuration.debugging`; use `logger.debug()`, `logger.info()`, `logger.warn()`, `logger.error()` (Logger defined in main.qml)
- **Event data format**: all calendar sources normalize to Google Calendar API JSON format
- **Config migrations**: when renaming config keys, add migration logic in `ConfigMigration.qml`
- **QML imports**: use Plasma 5 module paths (`org.kde.plasma.plasmoid 2.0`, `org.kde.plasma.core 2.0`, `org.kde.plasma.components 3.0`)
- **metadata.desktop**: the canonical metadata file; `metadata.json` is auto-generated from it by build/install scripts using `desktoptojson`
- **Section markers**: use `//---` comments for visual grouping in QML files

## Active Technologies
- QML (Qt 6) / JavaScript (ES6) / Python 3 (helper scripts) + Qt 6, KDE Frameworks 6 (Kirigami, KSvg, Plasma5Support, KItemModels), PlasmaComponents 3, KCMUtils (001-plasma6-port)
- KConfig via `plasmoid.configuration` (main.xml KConfigXT schema, unchanged) (001-plasma6-port)

## Recent Changes
- 001-plasma6-port: Added QML (Qt 6) / JavaScript (ES6) / Python 3 (helper scripts) + Qt 6, KDE Frameworks 6 (Kirigami, KSvg, Plasma5Support, KItemModels), PlasmaComponents 3, KCMUtils
