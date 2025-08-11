import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: Character
    let schedule: Set<Day>
}
