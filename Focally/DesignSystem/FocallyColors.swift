import SwiftUI

extension Color {
    // Primary
    static let focallyPrimary = Color(hex: "0058BC")
    static let focallyOnPrimary = Color(hex: "FFFFFF")
    static let focallyPrimaryContainer = Color(hex: "0070EB")
    static let focallyPrimaryFixed = Color(hex: "D8E2FF")
    static let focallyPrimaryFixedDim = Color(hex: "ADC6FF")
    static let focallyOnPrimaryFixed = Color(hex: "001A41")
    static let focallyOnPrimaryFixedVariant = Color(hex: "004493")
    static let focallyOnPrimaryContainer = Color(hex: "FEFCFF")

    // Tertiary
    static let focallyTertiary = Color(hex: "9E3D00")
    static let focallyTertiaryContainer = Color(hex: "C64F00")
    static let focallyTertiaryFixed = Color(hex: "FFDBCC")
    static let focallyTertiaryFixedDim = Color(hex: "FFB595")
    static let focallyOnTertiary = Color(hex: "FFFFFF")
    static let focallyOnTertiaryContainer = Color(hex: "FFFBFF")

    // Secondary
    static let focallySecondary = Color(hex: "5E5E5E")
    static let focallyOnSecondary = Color(hex: "FFFFFF")
    static let focallySecondaryContainer = Color(hex: "E1DFDF")
    static let focallySecondaryFixed = Color(hex: "E4E2E2")
    static let focallySecondaryFixedDim = Color(hex: "C7C6C6")
    static let focallyOnSecondaryContainer = Color(hex: "636262")
    static let focallyOnSecondaryFixed = Color(hex: "1B1C1C")
    static let focallyOnSecondaryFixedVariant = Color(hex: "464747")

    // Surface
    static let focallyOnSurface = Color(hex: "1A1C1C")
    static let focallyOnSurfaceVariant = Color(hex: "414755")
    static let focallyOutline = Color(hex: "717786")
    static let focallyOutlineVariant = Color(hex: "C1C6D7")
    static let focallySurface = Color(hex: "F9F9F9")
    static let focallySurfaceBright = Color(hex: "F9F9F9")
    static let focallySurfaceDim = Color(hex: "DADADA")
    static let focallySurfaceContainerLowest = Color(hex: "FFFFFF")
    static let focallySurfaceContainerLow = Color(hex: "F3F3F4")
    static let focallySurfaceContainer = Color(hex: "EEEEEE")
    static let focallySurfaceContainerHigh = Color(hex: "E8E8E8")
    static let focallySurfaceContainerHighest = Color(hex: "E2E2E2")
    static let focallySurfaceVariant = Color(hex: "E2E2E2")
    static let focallySurfaceTint = Color(hex: "005BC1")
    static let focallyBackground = Color(hex: "F9F9F9")
    static let focallyOnBackground = Color(hex: "1A1C1C")

    // Inverse
    static let focallyInverseSurface = Color(hex: "2F3131")
    static let focallyInverseOnSurface = Color(hex: "F0F1F1")
    static let focallyInversePrimary = Color(hex: "ADC6FF")

    // Error
    static let focallyError = Color(hex: "BA1A1A")
    static let focallyErrorContainer = Color(hex: "FFDAD6")
    static let focallyOnError = Color(hex: "FFFFFF")
    static let focallyOnErrorContainer = Color(hex: "93000A")

    // Card Border (computed for dark mode)
    static var focallyCardBorder: Color {
        Color(hex: "05000000") // 0.05 alpha black
    }

    private static let darkCardBorder = Color(hex: "08000000") // 0.08 alpha white
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
