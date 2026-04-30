import AppKit
import ApplicationServices
import Foundation
import os.log

class DNDService: ObservableObject {
    private enum AccessibilityPermissionState: String {
        case unknown
        case trusted
        case denied
    }

    private static let accessibilityStateDefaultsKey = "dndAccessibilityPermissionState"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.focally.mac", category: "DNDService")

    @Published var isDNDActive = false
    private var hasShownSetupAlert = false
    private var hasShownAccessibilityAlertThisLaunch = false
    private var shouldSkipAccessibilityChecksUntilRelaunch = false
    private var accessibilityPermissionState: AccessibilityPermissionState

    init() {
        let savedState = UserDefaults.standard.string(forKey: Self.accessibilityStateDefaultsKey)
        self.accessibilityPermissionState = AccessibilityPermissionState(rawValue: savedState ?? "") ?? .unknown
    }

    func activateDND() {
        logger.info("activateDND called. isDNDActive=\(self.isDNDActive, privacy: .public), cachedPermissionState=\(self.accessibilityPermissionState.rawValue, privacy: .public), shouldSkipAccessibilityChecksUntilRelaunch=\(self.shouldSkipAccessibilityChecksUntilRelaunch, privacy: .public)")
        guard !isDNDActive else { return }
        guard ensureAccessibilityPermission() else {
            presentAccessibilityAlert()
            return
        }

        if toggleDNDShortcut() {
            isDNDActive = true
            logger.info("DND activated")
        } else {
            presentFocusShortcutAlert()
        }
    }

    func deactivateDND() {
        logger.info("deactivateDND called. isDNDActive=\(self.isDNDActive, privacy: .public), cachedPermissionState=\(self.accessibilityPermissionState.rawValue, privacy: .public), shouldSkipAccessibilityChecksUntilRelaunch=\(self.shouldSkipAccessibilityChecksUntilRelaunch, privacy: .public)")
        guard isDNDActive else { return }
        guard ensureAccessibilityPermission() else { return }

        if toggleDNDShortcut() {
            isDNDActive = false
            logger.info("DND deactivated")
        } else {
            logger.error("Failed to deactivate DND")
        }
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

    private func presentAccessibilityAlert() {
        guard !hasShownSetupAlert, !hasShownAccessibilityAlertThisLaunch else { return }
        hasShownSetupAlert = true
        hasShownAccessibilityAlertThisLaunch = true
        logger.info("Presenting Accessibility setup alert")

        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "Accessibility permission is required"
            alert.informativeText = "Focally needs Accessibility access to trigger your Focus shortcut. Enable it in System Settings > Privacy & Security > Accessibility, then try Do Not Disturb again."
            alert.addButton(withTitle: "Open Accessibility Settings")
            alert.addButton(withTitle: "OK")

            let response = alert.runModal()
            self?.logger.info("Accessibility setup alert dismissed with response \(response.rawValue, privacy: .public)")
            if response == .alertFirstButtonReturn {
                self?.openAccessibilitySettings()
            }

            self?.hasShownSetupAlert = false
        }
    }

    private func presentFocusShortcutAlert() {
        guard !hasShownSetupAlert else { return }
        hasShownSetupAlert = true
        logger.info("Presenting Focus shortcut setup alert")

        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "Focally could not toggle Do Not Disturb"
            alert.informativeText = "macOS usually requires a Focus keyboard shortcut for this automation. Set one in System Settings > Keyboard > Keyboard Shortcuts > Focus, then try again."
            alert.addButton(withTitle: "Open Keyboard Settings")
            alert.addButton(withTitle: "Open Accessibility Settings")
            alert.addButton(withTitle: "OK")

            let response = alert.runModal()
            self?.logger.info("Focus shortcut alert dismissed with response \(response.rawValue, privacy: .public)")
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
        logger.info("Opening Accessibility settings")
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    private func openKeyboardSettings() {
        logger.info("Opening Keyboard settings")
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.keyboard") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
