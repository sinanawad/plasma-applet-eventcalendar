# Testing Guide: Plasma 6 Port

## Primary Tool: `plasmoidviewer` (non-intrusive, no install needed)

**Install**: `sudo apt install plasma-sdk` / `sudo pacman -S plasma-sdk`

```bash
cd /data/dev/plasma-applet-eventcalendar/package

# Desktop widget mode
QT_LOGGING_RULES="qml.debug=true" plasmoidviewer -a .

# Panel mode (compact representation → click to open popup)
QT_LOGGING_RULES="qml.debug=true" plasmoidviewer -a . -l topedge -f horizontal

# Vertical panel
plasmoidviewer -a . -l leftedge -f vertical

# Custom size
plasmoidviewer -a . -s 400x600

# HiDPI
QT_SCALE_FACTOR=2 plasmoidviewer -a .
```

**What works**: compact view, popup, config dialogs (right-click → Configure), QML error output.
**What doesn't**: tooltips, config persistence (resets each launch), real panel sizing.

## Config Persistence Testing: `plasmawindowed`

Avoid overwriting your existing Plasma 5 widget by using a dev symlink:

```bash
ln -s /data/dev/plasma-applet-eventcalendar/package \
      ~/.local/share/plasma/plasmoids/org.kde.plasma.eventcalendar.dev

plasmawindowed org.kde.plasma.eventcalendar.dev
```

Remove when done: `rm ~/.local/share/plasma/plasmoids/org.kde.plasma.eventcalendar.dev`

## QML Debugging

```bash
# Show console.log/warn/error output
QT_LOGGING_RULES="qml.debug=true" plasmoidviewer -a .

# Debug import resolution issues
QML_IMPORT_TRACE=1 plasmoidviewer -a .

# Verbose plugin loading
QT_DEBUG_PLUGINS=1 plasmoidviewer -a .
```

## Auto-Restart on File Changes

Requires `inotify-tools` (`sudo apt install inotify-tools`):

```bash
#!/bin/bash
DIR="/data/dev/plasma-applet-eventcalendar/package"
while true; do
    QT_LOGGING_RULES="qml.debug=true" plasmoidviewer -a "$DIR" &
    PV_PID=$!
    inotifywait -r -e modify,create,delete "$DIR/contents"
    kill $PV_PID 2>/dev/null
    wait $PV_PID 2>/dev/null
    echo "Files changed, restarting..."
    sleep 0.3
done
```

## Full Integration Testing (intrusive — use sparingly)

Only after `plasmoidviewer` confirms zero QML errors:

```bash
kpackagetool6 -t Plasma/Applet -u /data/dev/plasma-applet-eventcalendar/package
systemctl --user restart plasma-plasmashell
```

Clear QML cache if stale: `rm -rf ~/.cache/plasmashell/qmlcache/`

## Method Comparison

| Method | Install? | Non-Intrusive? | Config Persists? | Panel View? |
|---|---|---|---|---|
| `plasmoidviewer -a .` | No | Yes | No | Partial (flags) |
| `plasmawindowed` | Symlink | Mostly | Yes | No |
| `plasmashell` restart | Yes | **No** | Yes | Yes |
