import AppKit
import ApplicationServices
import Foundation
import os.log

class DNDService: ObservableObject {
    enum DNDMethod: String {
        case none = "None"
        case shortcuts = "Shortcuts"
        case appleScript = "AppleScript"
    }

    private enum AccessibilityPermissionState: String {
        case unknown
        case trusted
        case denied
    }

    private static let accessibilityStateDefaultsKey = "dndAccessibilityPermissionState"
    private static let preferredDNDMethodDefaultsKey = "preferredDNDMethod"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.focally.mac", category: "DNDService")

    @Published var isDNDActive = false
    @Published var dndMethod: DNDMethod
    private var hasShownSetupAlert = false
    private var hasShownAccessibilityAlertThisLaunch = false
    private var shouldSkipAccessibilityChecksUntilRelaunch = false
    private var accessibilityPermissionState: AccessibilityPermissionState

    init() {
        let savedState = UserDefaults.standard.string(forKey: Self.accessibilityStateDefaultsKey)
        self.accessibilityPermissionState = AccessibilityPermissionState(rawValue: savedState ?? "") ?? .unknown
        let savedMethod = UserDefaults.standard.string(forKey: Self.preferredDNDMethodDefaultsKey)
        self.dndMethod = DNDMethod(rawValue: savedMethod ?? "") ?? .none
    }

    func activateDND() {
        logger.info("activateDND called. isDNDActive=\(self.isDNDActive, privacy: .public), dndMethod=\(self.dndMethod.rawValue, privacy: .public), cachedPermissionState=\(self.accessibilityPermissionState.rawValue, privacy: .public), shouldSkipAccessibilityChecksUntilRelaunch=\(self.shouldSkipAccessibilityChecksUntilRelaunch, privacy: .public)")
        guard !isDNDActive else { return }

        if activateViaShortcuts() {
            isDNDActive = true
            updatePreferredMethod(.shortcuts)
            logger.info("DND activated")
            return
        }

        guard ensureAccessibilityPermission() else {
            presentSetupAlert()
            return
        }

        if toggleDNDShortcut() {
            isDNDActive = true
            updatePreferredMethod(.appleScript)
            logger.info("DND activated")
            return
        }

        presentSetupAlert()
    }

    func deactivateDND() {
        logger.info("deactivateDND called. isDNDActive=\(self.isDNDActive, privacy: .public), dndMethod=\(self.dndMethod.rawValue, privacy: .public), cachedPermissionState=\(self.accessibilityPermissionState.rawValue, privacy: .public), shouldSkipAccessibilityChecksUntilRelaunch=\(self.shouldSkipAccessibilityChecksUntilRelaunch, privacy: .public)")
        guard isDNDActive else { return }

        if deactivateUsingPreferredMethod() {
            isDNDActive = false
            logger.info("DND deactivated")
            return
        }

        logger.error("Failed to deactivate DND")
    }

    private func toggleDNDShortcut() -> Bool {
        let primaryShortcut = """
        tell application "System Events"
            key code 101 using {control down, option down, command down}
        end tell
        """

        logger.info("Attempting Focus toggle using primary shortcut: control+option+command + key code 101")
        if executeAppleScript(primaryShortcut) {
            return true
        }

        let fallbackShortcut = """
        tell application "System Events"
            key code 107 using {control down, option down, command down}
        end tell
        """

        logger.info("Attempting Focus toggle using fallback shortcut: control+option+command + key code 107")
        if executeAppleScript(fallbackShortcut) {
            logger.info("DND toggled using fallback shortcut")
            return true
        }

        logger.error("Both Focus toggle shortcuts failed. The configured macOS Focus shortcut may differ from the expected Sonoma mappings.")
        return false
    }

    private func activateViaShortcuts() -> Bool {
        logger.info("Attempting Focus activation using shortcuts CLI shortcut Focally-Focus-On")
        return runShortcut(named: "Focally-Focus-On")
    }

    private func deactivateViaShortcuts() -> Bool {
        logger.info("Attempting Focus deactivation using shortcuts CLI shortcut Focally-Focus-Off")
        return runShortcut(named: "Focally-Focus-Off")
    }

    private func runShortcut(named name: String) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        task.arguments = ["run", name]
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe

        do {
            logger.info("Executing shortcuts CLI: /usr/bin/shortcuts run \(name, privacy: .public)")
            try task.run()
            task.waitUntilExit()
            let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            logger.info("Shortcuts CLI finished. exitCode=\(task.terminationStatus, privacy: .public), stdout=\(stdout, privacy: .public), stderr=\(stderr, privacy: .public)")
            return task.terminationStatus == 0
        } catch {
            logger.error("Shortcuts CLI execution failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    private func deactivateUsingPreferredMethod() -> Bool {
        switch dndMethod {
        case .shortcuts:
            if deactivateViaShortcuts() {
                updatePreferredMethod(.shortcuts)
                return true
            }
            return deactivateViaAppleScriptFallback()

        case .appleScript:
            if deactivateViaAppleScript() {
                updatePreferredMethod(.appleScript)
                return true
            }
            if deactivateViaShortcuts() {
                updatePreferredMethod(.shortcuts)
                return true
            }
            return false

        case .none:
            if deactivateViaShortcuts() {
                updatePreferredMethod(.shortcuts)
                return true
            }
            return deactivateViaAppleScriptFallback()
        }
    }

    private func deactivateViaAppleScriptFallback() -> Bool {
        guard ensureAccessibilityPermission() else { return false }
        if deactivateViaAppleScript() {
            updatePreferredMethod(.appleScript)
            return true
        }
        return false
    }

    private func deactivateViaAppleScript() -> Bool {
        toggleDNDShortcut()
    }

    private func ensureAccessibilityPermission() -> Bool {
        logger.info("Checking Accessibility permission. cachedPermissionState=\(self.accessibilityPermissionState.rawValue, privacy: .public), shouldSkipAccessibilityChecksUntilRelaunch=\(self.shouldSkipAccessibilityChecksUntilRelaunch, privacy: .public)")

        if refreshAccessibilityPermissionState(prompt: false) {
            return true
        }

        logger.error("Accessibility permission required: System Settings > Privacy & Security > Accessibility > Add Focally")
        return false
    }

    private func refreshAccessibilityPermissionState(prompt: Bool) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt]
        let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        let newState: AccessibilityPermissionState = isTrusted ? .trusted : .denied
        accessibilityPermissionState = newState
        UserDefaults.standard.set(newState.rawValue, forKey: Self.accessibilityStateDefaultsKey)
        logger.info("AXIsProcessTrustedWithOptions(prompt: \(prompt, privacy: .public)) returned \(isTrusted, privacy: .public). cachedPermissionState updated to \(newState.rawValue, privacy: .public)")
        return isTrusted
    }

    @discardableResult
    private func executeAppleScript(_ script: String) -> Bool {
        logger.info("Executing AppleScript via /usr/bin/osascript: \(script, privacy: .public)")
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", script]
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe

        do {
            try task.run()
            task.waitUntilExit()
            let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            logger.info("AppleScript finished. exitCode=\(task.terminationStatus, privacy: .public), stdout=\(stdout, privacy: .public), stderr=\(stderr, privacy: .public)")
            if task.terminationStatus == 0 { return true }
        } catch {
            logger.error("AppleScript execution failed: \(error.localizedDescription, privacy: .public)")
        }
        return false
    }

    private func updatePreferredMethod(_ method: DNDMethod) {
        dndMethod = method
        UserDefaults.standard.set(method.rawValue, forKey: Self.preferredDNDMethodDefaultsKey)
        logger.info("Updated preferred DND method to \(method.rawValue, privacy: .public)")
    }

    private func presentSetupAlert() {
        guard !hasShownSetupAlert else { return }
        hasShownSetupAlert = true
        logger.info("Presenting Focus setup alert")

        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "Set up Focus shortcuts for Focally"
            alert.informativeText = """
            Focally first tries two macOS Shortcuts and falls back to the Accessibility-based keyboard toggle.

            Create these shortcuts in the Shortcuts app:
            1. “Focally-Focus-On” → add Set Focus, choose Work, then Turn On until turned off.
            2. “Focally-Focus-Off” → add Set Focus, then Turn Off.

            If you prefer the keyboard-toggle fallback, also enable Accessibility access for Focally in System Settings > Privacy & Security > Accessibility.
            """
            alert.addButton(withTitle: "Open Shortcuts")
            alert.addButton(withTitle: "Open Accessibility Settings")
            alert.addButton(withTitle: "OK")

            let response = alert.runModal()
            self?.logger.info("Focus setup alert dismissed with response \(response.rawValue, privacy: .public)")
            switch response {
            case .alertFirstButtonReturn:
                self?.openShortcutsApp()
            case .alertSecondButtonReturn:
                self?.openAccessibilitySettings()
            default:
                break
            }

            self?.hasShownSetupAlert = false
        }
    }

    private func openAccessibilitySettings() {
        logger.info("Opening Accessibility settings")
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    private func openShortcutsApp() {
        logger.info("Opening Shortcuts app")
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.shortcuts") {
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
            return
        }

        guard let fallbackURL = URL(string: "shortcuts://") else { return }
        NSWorkspace.shared.open(fallbackURL)
    }
}
