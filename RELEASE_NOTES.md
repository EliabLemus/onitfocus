# v0.1.0 — MVP Menu Bar Focus Timer

## What's New

First release of **OnItFocus** — a minimal macOS menu bar app for focus sessions.

### Features
- 🕐 Menu bar icon with live countdown in minutes
- 🖱 Left-click: focus panel (start session, countdown, extend, end)
- 🖱 Right-click: context menu (settings, quit)
- 📝 Activity input with emoji picker (11 emojis)
- ⏱ Predefined durations: 25, 45, 60, 90 min + custom
- 🔕 Automatic Do Not Disturb via Focus Mode toggle
- 🔔 Beep + system notification when session ends
- ⚙️ Settings window (timer, tasks, connections, appearance)
- 💾 Remembers last used activity and duration

### Requirements
- macOS 14+ (Sonoma)
- Xcode 16+

### Permissions Needed
- Accessibility (for DND toggle)
- Notifications (for session end alerts)
- Automation (Apple Events for System Events)

See [README.md](README.md) for troubleshooting.
