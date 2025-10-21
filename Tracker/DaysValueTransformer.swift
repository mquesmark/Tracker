import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    
    static let name = NSValueTransformerName(rawValue: "DaysValueTransformer")
    
    override class func transformedValueClass() -> AnyClass { NSArray.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data as Data)
    }
    
    static func register() {
        let transformer = DaysValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
