import Foundation

enum WeekDay: Int, CaseIterable, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var title: String {
        switch self {
        case .monday:    return NSLocalizedString("weekday_monday", comment: "")
        case .tuesday:   return NSLocalizedString("weekday_tuesday", comment: "")
        case .wednesday: return NSLocalizedString("weekday_wednesday", comment: "")
        case .thursday:  return NSLocalizedString("weekday_thursday", comment: "")
        case .friday:    return NSLocalizedString("weekday_friday", comment: "")
        case .saturday:  return NSLocalizedString("weekday_saturday", comment: "")
        case .sunday:    return NSLocalizedString("weekday_sunday", comment: "")
        }
    }
    var titleShort: String {
        switch self {
        case .monday:    return NSLocalizedString("weekday_monday_short", comment: "")
        case .tuesday:   return NSLocalizedString("weekday_tuesday_short", comment: "")
        case .wednesday: return NSLocalizedString("weekday_wednesday_short", comment: "")
        case .thursday:  return NSLocalizedString("weekday_thursday_short", comment: "")
        case .friday:    return NSLocalizedString("weekday_friday_short", comment: "")
        case .saturday:  return NSLocalizedString("weekday_saturday_short", comment: "")
        case .sunday:    return NSLocalizedString("weekday_sunday_short", comment: "")
        }
    }
}
