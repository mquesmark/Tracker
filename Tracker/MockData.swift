import Foundation

enum MockData {
    static let categoriesMock: [TrackerCategory] = [
        TrackerCategory(name: "Домашний уют", trackers: [
            Tracker(id: UUID(), name: "Протереть пыль", emoji: "💨", color: .colorSelection14, schedule: [.monday, .wednesday, .friday, .saturday]),
            Tracker(id: UUID(), name: "Купить чай", emoji: "🍃", color: .colorSelection9, schedule: [.tuesday, .thursday, .saturday])
        ]),
        TrackerCategory(name: "Здоровье", trackers: [
            Tracker(id: UUID(), name: "Утренняя зарядка", emoji: "🏃‍♂️", color: .colorSelection2, schedule: [.monday, .thursday, .saturday]),
            Tracker(id: UUID(), name: "Медитация", emoji: "🧘‍♀️", color: .colorSelection3, schedule: [.wednesday, .friday, .saturday])
        ]),
        TrackerCategory(name: "Развитие", trackers: [
            Tracker(id: UUID(), name: "Чтение книги", emoji: "📚", color: .colorSelection5, schedule: [.monday, .thursday]),
            Tracker(id: UUID(), name: "Изучение языка", emoji: "🗣", color: .colorSelection6, schedule: [.wednesday, .friday])
        ]),
        TrackerCategory(name: "Работа", trackers: [
            Tracker(id: UUID(), name: "Работа над проектом", emoji: "💻", color: .colorSelection10, schedule: [.monday, .wednesday, .thursday, .friday]),
            Tracker(id: UUID(), name: "Планирование дня", emoji: "📝", color: .colorSelection8, schedule: [.monday, .thursday])
        ]),
        TrackerCategory(name: "Отдых", trackers: [
            Tracker(id: UUID(), name: "Прогулка", emoji: "🚶‍♂️", color: .colorSelection1, schedule: [.thursday, .saturday]),
            Tracker(id: UUID(), name: "Вечерний отдых", emoji: "🛀", color: .colorSelection4, schedule: [.friday, .saturday])
        ]),
        TrackerCategory(name: "Социальное", trackers: [
            Tracker(id: UUID(), name: "Звонок другу", emoji: "📞", color: .colorSelection11, schedule: [.monday, .wednesday, .friday]),
            Tracker(id: UUID(), name: "Поход с друзьями", emoji: "🍻", color: .colorSelection12, schedule: [.saturday])
        ])
    ]
}
