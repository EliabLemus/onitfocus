import Foundation

struct PredefinedTask: Identifiable, Codable, Equatable {
    static let defaultsKey = "predefinedTasks"

    var id = UUID()
    let name: String
    let emoji: String
}
