enum Day: String, CaseIterable, Codable {
    case Monday = "Monday"
    case Tuesday = "Tuesday"
    case Wednesday = "Wednesday"
    case Thursday = "Thursday"
    case Friday = "Friday"
    case Saturday = "Saturday"
    case Sunday = "Sunday"

    var fullName: String {
        switch self {
        case .Monday: return L10n.WeekdayFull.monday
        case .Tuesday: return L10n.WeekdayFull.tuesday
        case .Wednesday: return L10n.WeekdayFull.wednesday
        case .Thursday: return L10n.WeekdayFull.thursday
        case .Friday: return L10n.WeekdayFull.friday
        case .Saturday: return L10n.WeekdayFull.saturday
        case .Sunday: return L10n.WeekdayFull.sunday
        }
    }

    var shortName: String {
        switch self {
        case .Monday: return L10n.WeekdayShort.monday
        case .Tuesday: return L10n.WeekdayShort.tuesday
        case .Wednesday: return L10n.WeekdayShort.wednesday
        case .Thursday: return L10n.WeekdayShort.thursday
        case .Friday: return L10n.WeekdayShort.friday
        case .Saturday: return L10n.WeekdayShort.saturday
        case .Sunday: return L10n.WeekdayShort.sunday
        }
    }
}
