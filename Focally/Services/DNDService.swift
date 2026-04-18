import AppKit
import ApplicationServices
import Foundation

class DNDService: ObservableObject {
    private enum AccessibilityPermissionState: String {
        case unknown
        case trusted
        case denied
    }

    private static let accessibilityStateDefaultsKey = "dndAccessibilityPermissionState"

    @Published var isDNDActive = false
    private var hasShownSetupAlert = false
    private var hasShownAccessibilityAlertThisLaunch = false
    private var hasCheckedAccessibilityThisLaunch = false
    private var shouldSkipAccessibilityChecksUntilRelaunch = false
    private var accessibilityPermissionState: AccessibilityPermissionState

    init() {
        let savedState = UserDefaults.standard.string(forKey: Self.accessibilityStateDefaultsKey)
        self.accessibilityPermissionState = AccessibilityPermissionState(rawValue: savedState ?? "") ?? .unknown
    }

    func activateDND() {
        guard !isDNDActive else { return }
        guard ensureAccessibilityPermission() else {
            presentAccessibilityAlert()
            return
        }

        if toggleDNDShortcut() {
            isDNDActive = true
            print("[Focally] DND activated")
        } else {
            presentFocusShortcutAlert()
        }
    }

    func deactivateDND() {
        guard isDNDActive else { return }
        guard ensureAccessibilityPermission() else { return }

        if toggleDNDShortcut() {
            isDNDActive = false
            print("[Focally] DND deactivated")
        } else {
            print("[Focally] Failed to deactivate DND")
        }
    }

    private func toggleDNDShortcut() -> Bool {
        let primaryShortcut = """
        tell application "System Events"
            key code 101 using {control down, option down, command down}
        end tell
        """

        if executeAppleScript(primaryShortcut) {
            return true
        }

        let fallbackShortcut = """
        tell application "System Events"
            key code 107 using {control down, option down, command down}
        end tell
        """

        if executeAppleScript(fallbackShortcut) {
            print("[Focally] DND toggled using fallback shortcut")
            return true
        }

        return false
    }

    private func ensureAccessibilityPermission() -> Bool {
        if shouldSkipAccessibilityChecksUntilRelaunch {
            return false
        }

        if !hasCheckedAccessibilityThisLaunch {
            hasCheckedAccessibilityThisLaunch = true
            if refreshAccessibilityPermissionState() {
                return true
            }
        } else if accessibilityPermissionState == .trusted {
            return true
        }

        shouldSkipAccessibilityChecksUntilRelaunch = true
        print("[Focally] Accessibility permission required: System Settings > Privacy & Security > Accessibility > Add Focally")
        return false
    }

    private func refreshAccessibilityPermissionState() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        let newState: AccessibilityPermissionState = isTrusted ? .trusted : .denied
        accessibilityPermissionState = newState
        UserDefaults.standard.set(newState.rawValue, forKey: Self.accessibilityStateDefaultsKey)
        return isTrusted
    }

    @discardableResult
    private func executeAppleScript(_ script: String) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", script]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()
            if task.terminationStatus == 0 { return true }
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            print("[Focally] AppleScript error: \(output)")
        } catch {
            print("[Focally] AppleScript error: \(error.localizedDescription)")
        }
        return false
    }

    private func presentAccessibilityAlert() {
        guard !hasShownSetupAlert, !hasShownAccessibilityAlertThisLaunch else { return }
        hasShownSetupAlert = true
        hasShownAccessibilityAlertThisLaunch = true

        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "Accessibility permission is required"
            alert.informativeText = "Focally needs Accessibility access to trigger your Focus shortcut. Enable it in System Settings > Privacy & Security > Accessibility, then relaunch the app before trying Do Not Disturb again."
            alert.addButton(withTitle: "Open Accessibility Settings")
            alert.addButton(withTitle: "OK")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                self?.openAccessibilitySettings()
            }

            self?.hasShownSetupAlert = false
        }
    }

    private func presentFocusShortcutAlert() {
        guard !hasShownSetupAlert else { return }
        hasShownSetupAlert = true

        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "Focally could not toggle Do Not Disturb"
            alert.informativeText = "macOS usually requires a Focus keyboard shortcut for this automation. Set one in System Settings > Keyboard > Keyboard Shortcuts > Focus, then try again."
            alert.addButton(withTitle: "Open Keyboard Settings")
            alert.addButton(withTitle: "Open Accessibility Settings")
            alert.addButton(withTitle: "OK")

            let response = alert.runModal()
            switch response {
            case .alertFirstButtonReturn:
                self?.openKeyboardSettings()
            case .alertSecondButtonReturn:
                self?.openAccessibilitySettings()
            default:
                break
            }

            self?.hasShownSetupAlert = false
        }
    }

    private func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    private func openKeyboardSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.keyboard") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
