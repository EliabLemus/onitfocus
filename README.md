# OnItFocus

> Minimal macOS menu bar app for focus sessions. Start a timer, get in the zone, let OnItFocus handle the rest.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## Features

- 🕐 **Menu bar timer** — Live countdown in minutes while you focus
- 🖱 **Left-click** — Focus panel (start, countdown, extend +5 min, end)
- 🖱 **Right-click** — Context menu (settings, quit)
- 📝 **Activity input** — Text + emoji picker for what you're working on
- ⏱ **Flexible durations** — 25, 45, 60, 90 min presets + custom
- 🔕 **Auto DND** — Activates Do Not Disturb when you start focusing
- 🔔 **Alert on completion** — Beep + system notification when time's up
- ⚙️ **Settings** — Customizable durations, predefined tasks, sounds, appearance
- 💾 **Persistence** — Remembers your last activity and duration
- 🎨 **System theme** — Adapts to your macOS Light/Dark mode

## Installation

### Build from source

Requires Xcode 16+ and macOS 14+.

```bash
git clone https://github.com/EliabLemus/onitfocus.git
cd onitfocus
xed .
# Cmd+R to build and run
```

Or via command line:

```bash
xcodegen generate
xcodebuild build -scheme OnItFocus -configuration Debug -destination 'platform=macOS'
```

## Permissions

OnItFocus needs the following permissions. You'll be prompted on first use.

| Permission | Why | How to enable |
|---|---|---|
| **Accessibility** | Toggle Do Not Disturb via keyboard shortcut | System Settings → Privacy & Security → Accessibility → Add OnItFocus |
| **Notifications** | Show "Focus session ended" alerts | System Settings → Notifications → OnItFocus → Allow |
| **Automation** | Run AppleScript to control Focus Mode | System Settings → Privacy & Security → Automation → OnItFocus → System Events → ✅ |

## Troubleshooting

**DND doesn't activate**
- Ensure OnItFocus has Accessibility permissions (see above).
- Verify Focus Mode shortcut is enabled: System Settings → Keyboard → Keyboard Shortcuts → Focus.

**No notification when session ends**
- System Settings → Notifications → OnItFocus → Allow Notifications.

**Repeated Automation permission prompts**
- System Settings → Privacy & Security → Automation → OnItFocus → System Events → set to ✅.

## Roadmap

| # | Iteration | Status |
|---|-----------|--------|
| 1 | MVP Menu Bar + DND + Timer | ✅ v0.1.0 |
| 2 | Slack Status | 🔜 Next |
| 3 | Google Calendar Read | Planned |
| 4 | Focus Planner (Calendar Write) | Planned |
| 5 | Calendar Sync (n8n WebSocket) | Planned |
| 6 | Polish + History | Planned |
| 7a | Distribution (Homebrew Tap) | Planned |
| 7b | Homebrew Cask (Official) | Future |

## License

MIT
