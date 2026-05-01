import Foundation
import SwiftUI

struct FocusBlock: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var color: BlockColor
    var isCurrentSession: Bool

    enum BlockColor: String, Codable, CaseIterable {
        case primary, tertiary, secondary

        var displayColor: Color {
            switch self {
            case .primary: return .focallyPrimary
            case .tertiary: return .focallyTertiaryContainer
            case .secondary: return .focallySecondaryContainer
            }
        }
    }

    var borderColor: Color {
        switch color {
        case .primary:
            return isCurrentSession ? .white : .focallyPrimary
        case .tertiary:
            return .focallyTertiaryContainer
        case .secondary:
            return .focallySecondaryContainer
        }
    }

    init(id: UUID = UUID(), title: String, startDate: Date, endDate: Date, color: BlockColor = .primary, isCurrentSession: Bool = false) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.isCurrentSession = isCurrentSession
    }
}
