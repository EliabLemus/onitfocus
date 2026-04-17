# OnItFocus

> Focus timer for macOS with automatic Do Not Disturb, Slack status, and Google Calendar sync.

## Features (Iteración 1 — MVP)

- ⏱ Menu bar timer with countdown
- 🔕 Automatic Do Not Disturb when focus session starts
- 🔔 Beep + system notification when session ends
- 📝 Activity input with emoji picker
- ⏱ Predefined durations (25, 45, 60, 90 min) + custom
- 🔄 Extend session (+5 min)
- 💾 Remembers last used activity and duration

## Building

Requires Xcode 16+ and macOS 14+ (Sonoma).

```bash
# Using Xcode
xed .
# Then Cmd+R to build and run

# Using xcodebuild
xcodebuild build -scheme OnItFocus -configuration Debug -destination 'platform=macOS'
```

## Permissions

OnItFocus requires the following permissions to work correctly. You'll be prompted on first use, or you can set them manually in **System Settings → Privacy & Security**:

| Permission | Why needed | How to enable |
|---|---|---|
| **Accessibility** | Control Do Not Distumb via keyboard shortcut | System Settings → Privacy & Security → Accessibility → Add OnItFocus |
| **Notifications** | Show "Focus session ended" alerts | System Settings → Notifications → OnItFocus → Allow |
| **Automation (Apple Events)** | Run AppleScript to toggle Focus Mode | System Settings → Privacy & Security → Automation → OnItFocus → System Events → ✅ |

### Troubleshooting

**"Hourglass icon appears but nothing happens when I click it"**
- This shouldn't happen. If it does, try killing the app from Activity Monitor and relaunching.

**"DND doesn't activate when I start a focus session"**
- OnItFocus uses a keyboard shortcut (⌃⌥⌘F) to toggle Focus Mode.
- Make sure OnItFocus has **Accessibility** permissions (see table above).
- Also verify that Focus Mode shortcut is enabled in System Settings → Keyboard → Keyboard Shortcuts → Focus.

**"No notification when session ends"**
- Go to System Settings → Notifications → OnItFocus → Allow Notifications.

**"App asks for Automation permission repeatedly"**
- Go to System Settings → Privacy & Security → Automation.
- Find OnItFocus and check "System Events" → set to ✅.

## Roadmap

| # | Iteration | Status |
|---|-----------|--------|
| 1 | MVP Menu Bar + DND + Timer | ✅ Done |
| 2 | Slack Status | 🔜 Next |
| 3 | Google Calendar Read | Planned |
| 4 | Focus Planner (Calendar Write) | Planned |
| 5 | Calendar Sync (n8n WebSocket) | Planned |
| 6 | Polish + History | Planned |
| 7a | Distribution (Homebrew Tap) | Planned |
| 7b | Homebrew Cask (Official) | Future |

## License

MIT
