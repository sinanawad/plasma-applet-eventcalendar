# Plasma 5 → Plasma 6 Porting Research

Consolidated research from 5 parallel agents. This document covers everything needed to port plasma-applet-eventcalendar from Plasma 5 to Plasma 6.

---

## Existing Ports of This Widget

Two existing ports were found:

1. **Zren's official `plasma6` branch** (WIP, incomplete) — https://github.com/Zren/plasma-applet-eventcalendar/issues/362
   - Done: Context Actions, Clock Line 1, 2-column layout, Executable DataEngine, import porting
   - NOT done: Tooltip, popup click/shortcut, Clock Line 2, Notifications, Timer, Google Events/Calendar/Tasks, MonthView model/rendering/badges, Agenda, ALL config panels, Weather
   - Uses Zren's `kpac` automation tool for bulk replacements

2. **ALikesToCode's fork** (more complete) — https://github.com/ALikesToCode/plasma-applet-eventcalendar
   - 113 files changed, 5603 insertions, 1685 deletions
   - Has working Google Calendar, Weather, Agenda, Config panels
   - Added multi-account Google support, PKCE OAuth flow

---

## 1. Root Element Change (CRITICAL)

```qml
// PLASMA 5
import QtQuick 2.0
import org.kde.plasma.plasmoid 2.0
Item {
    id: root
    Plasmoid.toolTipItem: Loader { ... }
    Plasmoid.compactRepresentation: ...
    Plasmoid.fullRepresentation: ...
    Plasmoid.preferredRepresentation: ...
}

// PLASMA 6
import QtQuick
import org.kde.plasma.plasmoid
PlasmoidItem {
    id: root
    toolTipItem: Loader { ... }        // Direct property, NO Plasmoid. prefix
    compactRepresentation: ...
    fullRepresentation: ...
    preferredRepresentation: ...
    hideOnWindowDeactivate: !Plasmoid.configuration.pin
}
```

Properties that move from `Plasmoid.X` attached to PlasmoidItem direct properties:
- `toolTipItem`, `toolTipMainText`, `toolTipSubText`, `toolTipTextFormat`
- `compactRepresentation`, `fullRepresentation`, `preferredRepresentation`
- `switchWidth`, `switchHeight`
- `hideOnWindowDeactivate`
- `expanded` (was `plasmoid.expanded`, now `root.expanded`)
- `activationTogglesExpanded`

---

## 2. QML Import Changes

**ALL version numbers must be removed.**

| Plasma 5 | Plasma 6 |
|---|---|
| `import QtQuick 2.0` | `import QtQuick` |
| `import QtQuick.Layouts 1.1` | `import QtQuick.Layouts` |
| `import QtQuick.Controls 2.5` | `import QtQuick.Controls` |
| `import org.kde.plasma.plasmoid 2.0` | `import org.kde.plasma.plasmoid` |
| `import org.kde.plasma.core 2.0 as PlasmaCore` | `import org.kde.plasma.core as PlasmaCore` |
| `import org.kde.plasma.components 2.0` | **REMOVED** (must use PC3) |
| `import org.kde.plasma.components 3.0 as PC3` | `import org.kde.plasma.components as PlasmaComponents3` |
| `import org.kde.plasma.extras 2.0 as PlasmaExtras` | `import org.kde.plasma.extras as PlasmaExtras` |
| `import org.kde.plasma.configuration 2.0` | `import org.kde.plasma.configuration` |
| `import org.kde.plasma.calendar 2.0` | `import org.kde.plasma.workspace.calendar` |
| `import org.kde.kirigami 2.x as Kirigami` | `import org.kde.kirigami as Kirigami` |
| `import org.kde.kquickcontrolsaddons 2.0` | **REMOVED** (see KCMUtils below) |
| `import org.kde.plasma.private.digitalclock 1.0` | `import org.kde.plasma.private.digitalclock` |
| `import QtGraphicalEffects 1.0` | `import Qt5Compat.GraphicalEffects` |
| `import org.kde.kcoreaddons` | `import org.kde.coreaddons` |

**New imports in Plasma 6:**
| New Import | Purpose |
|---|---|
| `import org.kde.plasma.plasma5support as Plasma5Support` | Replaces PlasmaCore.DataSource |
| `import org.kde.ksvg as KSvg` | Replaces PlasmaCore.Svg/SvgItem/FrameSvgItem |
| `import org.kde.config as KConfig` | KAuthorized |
| `import org.kde.kcmutils as KCMUtils` | KCMLauncher, SimpleKCM config pages |
| `import org.kde.kitemmodels as KItemModels` | Replaces PlasmaCore.SortFilterModel |

---

## 3. Component Migration (PlasmaCore → Kirigami/KSvg/Plasma5Support)

### Units & Theme → Kirigami
| Plasma 5 | Plasma 6 |
|---|---|
| `PlasmaCore.Units.gridUnit` | `Kirigami.Units.gridUnit` |
| `PlasmaCore.Units.smallSpacing` | `Kirigami.Units.smallSpacing` |
| `PlasmaCore.Units.largeSpacing` | `Kirigami.Units.largeSpacing` |
| `PlasmaCore.Units.devicePixelRatio` | `1` (always 1 in Qt6) |
| `PlasmaCore.Units.iconSizes.*` | `Kirigami.Units.iconSizes.*` |
| `PlasmaCore.Units.longDuration` | `Kirigami.Units.longDuration` |
| `PlasmaCore.Units.shortDuration` | `Kirigami.Units.shortDuration` |
| `PlasmaCore.Theme.textColor` | `Kirigami.Theme.textColor` |
| `PlasmaCore.Theme.highlightColor` | `Kirigami.Theme.highlightColor` |
| `PlasmaCore.Theme.backgroundColor` | `Kirigami.Theme.backgroundColor` |
| `PlasmaCore.Theme.linkColor` | `Kirigami.Theme.linkColor` |
| `PlasmaCore.Theme.positiveTextColor` | `Kirigami.Theme.positiveTextColor` |
| `PlasmaCore.Theme.neutralTextColor` | `Kirigami.Theme.neutralTextColor` |
| `PlasmaCore.Theme.negativeTextColor` | `Kirigami.Theme.negativeTextColor` |
| `PlasmaCore.Theme.disabledTextColor` | `Kirigami.Theme.disabledTextColor` |
| `PlasmaCore.Theme.defaultFont` | `Kirigami.Theme.defaultFont` |
| `PlasmaCore.Theme.smallestFont` | `Kirigami.Theme.smallFont` |
| `PlasmaCore.ColorScope.*` | `Kirigami.Theme.*` |
| `PlasmaCore.IconItem` | `Kirigami.Icon` |
| `PlasmaExtras.Heading` | `Kirigami.Heading` |

### SVG → KSvg
| Plasma 5 | Plasma 6 |
|---|---|
| `PlasmaCore.Svg` | `KSvg.Svg` |
| `PlasmaCore.SvgItem` | `KSvg.SvgItem` |
| `PlasmaCore.FrameSvgItem` | `KSvg.FrameSvgItem` |
| `colorGroup:` property on SVG items | REMOVED (automatic) |

### DataSource → Plasma5Support
| Plasma 5 | Plasma 6 |
|---|---|
| `PlasmaCore.DataSource` | `Plasma5Support.DataSource` |
| `PlasmaCore.DataModel` | `Plasma5Support.DataModel` |

### SortFilterModel → KItemModels
```qml
// Plasma 5
PlasmaCore.SortFilterModel { sortRole: "name"; filterRegExp: /pattern/ }

// Plasma 6
KItemModels.KSortFilterProxyModel { sortRoleName: "name"; filterRegularExpression: RegExp("pattern") }
```

---

## 4. Actions API (Imperative → Declarative)

```qml
// PLASMA 5 (imperative)
Component.onCompleted: {
    plasmoid.setAction("clipboard", i18n("Copy to Clipboard"), "edit-copy")
    plasmoid.setAction("KCMClock", i18n("Adjust Date and Time..."), "preferences-system-time")
}
function action_KCMClock() { KCMShell.open(["kcm_clock", "clock"]) }

// PLASMA 6 (declarative)
Plasmoid.contextualActions: [
    PlasmaCore.Action {
        text: i18n("Copy to Clipboard")
        icon.name: "edit-copy"
        onTriggered: copyCurrentDateTime()
    },
    PlasmaCore.Action {
        text: i18n("Adjust Date and Time...")
        icon.name: "preferences-system-time"
        visible: KConfig.KAuthorized.authorize("kcm_clock")
        onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_clock")
    }
]

// Internal actions:
// plasmoid.action("configure").trigger() → Plasmoid.internalAction("configure").trigger()
```

---

## 5. KCMShell → KConfig + KCMUtils

```qml
// PLASMA 5
import org.kde.kquickcontrolsaddons 2.0
KCMShell.open(["kcm_clock", "clock"])
KCMShell.authorize(["kcm_clock.desktop"])

// PLASMA 6
import org.kde.config as KConfig
import org.kde.kcmutils as KCMUtils
KConfig.KAuthorized.authorize("kcm_clock")
KCMUtils.KCMLauncher.openSystemSettings("kcm_clock")
```

---

## 6. Configuration Pages

```qml
// PLASMA 5 - root element is Item
Item {
    id: page
    property alias cfg_myOption: myCheckBox.checked
    ColumnLayout { CheckBox { id: myCheckBox } }
}

// PLASMA 6 - root element must be KCM type
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
KCM.SimpleKCM {
    id: page
    property alias cfg_myOption: myCheckBox.checked
    Kirigami.FormLayout {
        CheckBox { id: myCheckBox; Kirigami.FormData.label: i18n("My Option:") }
    }
}
```

`main.xml` KConfigXT schema format is **unchanged**.

---

## 7. metadata.desktop → metadata.json

```json
{
    "KPlugin": {
        "Authors": [{ "Email": "zrenfire@gmail.com", "Name": "Chris Holland" }],
        "Category": "Date and Time",
        "Description": "Plasmoid for a calendar+agenda with weather that syncs to Google Calendar.",
        "Icon": "view-calendar",
        "Id": "org.kde.plasma.eventcalendar",
        "License": "GPL",
        "Name": "Event Calendar",
        "Version": "76",
        "Website": "https://github.com/Zren/plasma-applet-eventcalendar"
    },
    "KPackageStructure": "Plasma/Applet",
    "X-Plasma-API-Minimum-Version": "6.0",
    "X-Plasma-Provides": ["org.kde.plasma.time", "org.kde.plasma.date"]
}
```

Key changes:
- `KPackageStructure: "Plasma/Applet"` replaces `X-KDE-ServiceTypes`
- `X-Plasma-API-Minimum-Version: "6.0"` is REQUIRED
- Remove: `X-Plasma-API`, `X-Plasma-MainScript`, `ServiceTypes`
- Directory name MUST match `KPlugin.Id`

---

## 8. Build/Install Script Changes

| Plasma 5 | Plasma 6 |
|---|---|
| `kreadconfig5` | `kreadconfig6` (or use Python to read metadata.json) |
| `kpackagetool5` | `kpackagetool6` |
| `kstart5 plasmashell` | `kstart plasmashell` |
| `desktoptojson` | No longer needed (metadata.json is native) |
| `metadata.desktop` parsing | `python3 -c 'import json; ...'` to read metadata.json |

---

## 9. Signal Handler Syntax (Qt 6)

```qml
// OLD (deprecated, causes warnings)
Connections {
    target: someObject
    onSomeSignal: doSomething()
}

// NEW (required)
Connections {
    target: someObject
    function onSomeSignal() { doSomething() }
}

// Signal handlers with parameters:
// OLD: onNewData: { var cmd = sourceName }
// NEW: function onNewData(sourceName, data) { var cmd = sourceName }

// MouseArea:
// OLD: onClicked: console.log(mouse.x)
// NEW: onClicked: (mouse) => console.log(mouse.x)
```

CRITICAL: Do NOT mix old and new syntax in the same Connections block.

---

## 10. PlasmaComponents 2 Removal

PC2 is completely gone. Key migrations:
| PC2 | Replacement |
|---|---|
| `PlasmaComponents.ContextMenu` | `PlasmaComponents3.Menu` |
| `PlasmaComponents.MenuItem` | Custom MenuItem or PlasmaComponents3 |
| `separator: true` | `PlasmaComponents3.MenuSeparator {}` |
| `open(x, y)` | `popup(position.x, position.y)` |
| `PlasmaComponents.ListItem` | `ItemDelegate` |
| `PlasmaExtras.ScrollArea` | `PlasmaComponents3.ScrollView` |
| `TabGroup` | REMOVED (redesign with ComboBox/RadioButtons) |

---

## 11. Qt 5 → Qt 6 QML Changes

### Silent Behavioral Changes
- **URL resolution**: Relative URLs stay relative in Qt 6 (use `Qt.resolvedUrl()`)
- **`variant` properties**: No implicit string→type conversions (use concrete types)
- **FontLoader.name**: Now read-only
- **RegExpValidator** → `RegularExpressionValidator`
- **font.weight**: Changed from enum to int (use `Font.Bold` constants)

### Import Changes
- All imports unversioned
- `QtQuick.Controls 1.x` — REMOVED entirely
- `Qt.labs.settings` → `QtCore` Settings (deprecated in Qt 6.5)
- `Qt.labs.calendar` → graduated to `QtQuick.Controls`
- `QtGraphicalEffects` → `Qt5Compat.GraphicalEffects`
- `QtQuick.XmlListModel` → `QtQml.XmlListModel` (API changes)

### Required Properties (new best practice)
```qml
// Delegates should declare required properties instead of relying on context injection
ListView {
    delegate: Text {
        required property string name  // explicit
        text: name
    }
}
```

### `pragma ComponentBehavior: Bound`
All official KDE Plasma 6 QML files use this pragma for stricter scope binding.

---

## 12. PlasmaExtras.Representation (New)

Official Plasma 6 plasmoids wrap their fullRepresentation in:
```qml
PlasmaExtras.Representation {
    Layout.minimumWidth: Kirigami.Units.gridUnit * 45
    Layout.maximumWidth: Kirigami.Units.gridUnit * 80
    collapseMarginsHint: true
    header: PlasmaExtras.PlasmoidHeading { }
}
```

---

## 13. i18n System

- `i18n()`, `i18nc()`, `i18np()`, `i18ncp()` — **unchanged**
- xgettext workflow for QML/JS — **unchanged**
- Translation bundling path — **unchanged**: `contents/locale/{lang}/LC_MESSAGES/...`
- **metadata.json translations**: Need custom Python handling (no `msgfmt --desktop` for JSON)

---

## 14. Icon References

```qml
// Plasma 5
icon: plasmoid.file("", "icons/Google_Calendar_2020.svg")
// Plasma 6
icon: Qt.resolvedUrl("../icons/google_calendar_96px.png")
```

---

## 15. Zren's kpac Automation Tool

https://github.com/Zren/plasma-applet-lib/blob/master/kpac

`python3 ./kpac plasma6` automates bulk replacements (import versions, PlasmaCore→Kirigami, etc.)

Does NOT automate: Root Item→PlasmoidItem, setAction→contextualActions, PC2→PC3, config page KCM migration, complex signal handler changes.
