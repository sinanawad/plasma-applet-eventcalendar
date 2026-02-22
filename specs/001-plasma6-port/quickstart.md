# Quick Start: Plasma 6 Port Development

**Feature**: 001-plasma6-port | **Date**: 2026-02-22

## Prerequisites

- KDE Plasma 6 desktop environment
- Qt 6, KDE Frameworks 6
- `kpackagetool6` (from `plasma-sdk` or `plasma-framework`)
- `plasmoidviewer` or `plasmawindowed` (from `plasma-sdk`)
- Python 3 (for translation and ICS scripts)
- `gettext` tools (`msgfmt`, `msgmerge`, `xgettext`)

## Setup

```bash
# Clone and checkout the feature branch
git clone https://github.com/sinanawad/plasma-applet-eventcalendar.git
cd plasma-applet-eventcalendar
git checkout 001-plasma6-port

# Remotes for reference (prior art)
git remote add upstream https://github.com/Zren/plasma-applet-eventcalendar.git
git remote add alikestocode https://github.com/ALikesToCode/plasma-applet-eventcalendar.git
git fetch upstream plasma6
git fetch alikestocode master
```

## Build & Install

```bash
# Build .plasmoid package
sh ./build

# Install (first time)
kpackagetool6 -t Plasma/Applet -i package.plasmoid

# Upgrade (after changes)
kpackagetool6 -t Plasma/Applet -u package.plasmoid

# Uninstall
kpackagetool6 -t Plasma/Applet -r org.kde.plasma.eventcalendar
```

## Testing

```bash
# Test in standalone window (no panel needed)
plasmoidviewer -a org.kde.plasma.eventcalendar

# Watch for QML errors
journalctl --user -f | grep -i "qml\|plasma\|eventcalendar"

# Quick iteration: uninstall + reinstall + test
kpackagetool6 -t Plasma/Applet -r org.kde.plasma.eventcalendar 2>/dev/null
kpackagetool6 -t Plasma/Applet -i package.plasmoid
plasmoidviewer -a org.kde.plasma.eventcalendar
```

## Referencing Prior Art

```bash
# View Zren's changes to a specific file
git diff master..upstream/plasma6 -- package/contents/ui/main.qml

# View ALikesToCode's changes to a specific file
git diff master..alikestocode/master -- package/contents/ui/main.qml

# Compare the two forks on a file
git diff upstream/plasma6..alikestocode/master -- package/contents/ui/main.qml
```

## Translation Workflow

```bash
# Rebuild translations after metadata.json changes
cd package/translate
sh ./build

# Merge new strings from QML files into .po files
sh ./merge
```

## Key Files to Understand

| File | Role |
|---|---|
| `package/metadata.json` | Package descriptor (was metadata.desktop) |
| `package/contents/config/main.xml` | Configuration schema (unchanged) |
| `package/contents/ui/main.qml` | Widget entry point (PlasmoidItem root) |
| `package/contents/ui/ClockView.qml` | Panel compact view (clock) |
| `package/contents/ui/PopupView.qml` | Popup full view container |
| `package/contents/ui/config/*.qml` | 11 configuration pages |
| `package/contents/ui/calendars/*.qml` | 5 calendar backends |
| `package/contents/ui/lib/*.qml` | 26 shared components |

## Porting Checklist Per File

When porting a QML file, verify:

1. All imports are unversioned
2. No `PlasmaCore.Units` / `PlasmaCore.Theme` (use Kirigami)
3. No `PlasmaCore.Svg*` (use KSvg)
4. No `PlasmaCore.DataSource` (use Plasma5Support)
5. No PlasmaComponents 2 imports or types
6. Signal handlers use `function onName()` syntax
7. `Connections` blocks use named function handlers
8. No `colorGroup` properties on SVG items
9. Config pages use `KCM.SimpleKCM` root (not `Item`)
10. No `plasmoid.expanded` (use `root.expanded`)
