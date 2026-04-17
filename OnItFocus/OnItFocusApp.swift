import SwiftUI

@main
struct OnItFocusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(appDelegate.slackService)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var eventMonitor: Any?
    let timerService = FocusTimerService()
    let dndService = DNDService()
    let slackService = SlackService()
    private var timerUpdate: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "hourglass.circle.fill", accessibilityDescription: "OnItFocus")
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Setup popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 350)
        popover.behavior = .transient

        let contentView = FocusMenuHost(
            timerService: timerService,
            dndService: dndService
        )
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover

        // Observe timer changes
        timerService.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateStatusBar()
            }
        }.store(in: &cancellables)

        // Observe session start/end for Slack
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSessionStarted),
            name: .focusSessionStarted,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSessionEnded),
            name: .focusSessionEnded,
            object: nil
        )

        // Timer to update menu bar text
        timerUpdate = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStatusBar()
        }

        // Click-outside monitor to close popover
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()

    @objc private func onSessionStarted() {
        let expiration = Int(Date().timeIntervalSince1970) + (timerService.durationMinutes * 60)
        slackService.setStatus(
            emoji: timerService.currentEmoji,
            text: timerService.currentActivity,
            expirationTimestamp: expiration
        )
    }

    @objc private func onSessionEnded() {
        slackService.clearStatus()
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }

        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            showContextMenu(button: button)
            return
        }

        if popover.isShown {
            popover.performClose(button)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func showContextMenu(button: NSButton) {
        let menu = NSMenu()

        if timerService.isActive {
            let extendItem = NSMenuItem(title: "Extend +5 min", action: #selector(extendSession), keyEquivalent: "")
            extendItem.image = NSImage(systemSymbolName: "forward.fill", accessibilityDescription: "Extend")
            menu.addItem(extendItem)

            let endItem = NSMenuItem(title: "End Session", action: #selector(endSession), keyEquivalent: "")
            endItem.image = NSImage(systemSymbolName: "stop.fill", accessibilityDescription: "End")
            menu.addItem(endItem)
            menu.addItem(NSMenuItem.separator())
        }

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "Settings")
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit OnItFocus", action: #selector(quitApp), keyEquivalent: "q")
        menu.addItem(quitItem)

        menu.delegate = self
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
    }

    @objc func extendSession() {
        timerService.extendFiveMinutes()
    }

    @objc func endSession() {
        timerService.cancelSession()
        dndService.deactivateDND()
    }

    @objc func openSettings() {
        if popover?.isShown == true {
            popover?.performClose(nil)
        }
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    private func updateStatusBar() {
        guard let button = statusItem?.button else { return }

        if timerService.isActive {
            button.image = NSImage(systemSymbolName: "play.circle.fill", accessibilityDescription: "Focus Active")
            let newText = " \(timerService.currentEmoji) \(timerService.remainingMinutesString) — \(timerService.currentActivity)"
            if button.title != newText {
                button.title = newText
            }
        } else {
            button.image = NSImage(systemSymbolName: "hourglass.circle.fill", accessibilityDescription: "OnItFocus")
            button.title = ""
        }

        statusItem?.length = NSStatusItem.variableLength
    }
}

extension AppDelegate: NSMenuDelegate {}

struct FocusMenuHost: View {
    @ObservedObject var timerService: FocusTimerService
    @ObservedObject var dndService: DNDService

    var body: some View {
        FocusMenuView()
            .environmentObject(timerService)
            .environmentObject(dndService)
    }
}

// Notification names for Slack integration
extension Notification.Name {
    static let focusSessionStarted = Notification.Name("focusSessionStarted")
    static let focusSessionEnded = Notification.Name("focusSessionEnded")
}

import Combine
