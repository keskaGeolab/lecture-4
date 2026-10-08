import Foundation

struct Product: Identifiable {
    let id = UUID()
    var name: String
    var emoji: String
    var isBought: Bool = false
}
