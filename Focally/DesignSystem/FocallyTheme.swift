import SwiftUI

@Observable
class FocallyTheme {
    var colorScheme: ColorScheme = .light

    var isDark: Bool {
        colorScheme == .dark
    }
}

// Environment key for FocallyTheme
private struct FocallyThemeKey: EnvironmentKey {
    static let defaultValue = FocallyTheme()
}

extension EnvironmentValues {
    var focallyTheme: FocallyTheme {
        get { self[FocallyThemeKey.self] }
        set { self[FocallyThemeKey.self] = newValue }
    }
}
