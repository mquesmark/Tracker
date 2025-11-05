import CoreData
import UIKit

final class TrackerRecordStore {
    
    static let shared = TrackerRecordStore()

    private let context: NSManagedObjectContext
    private let calendar = Calendar(identifier: .iso8601)
    
    private init() {
        context = DataBaseStore.shared.context
    }
    
    // MARK: - Public Methods
    
    func addRecord(_ record: TrackerRecord) {

        let trackerFetch = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        trackerFetch.predicate = NSPredicate(format: "id == %@", record.trackerId as NSUUID)
        trackerFetch.fetchLimit = 1
        
        do {
            guard let trackerCD = try context.fetch(trackerFetch).first else {
                return
            }
            
            guard !isCompleted(trackerId: record.trackerId, date: record.dateLogged) else {
                return
            }
            
            let recordCD = TrackerRecordCoreData(context: context)
            recordCD.dateLogged = record.dateLogged
            recordCD.tracker = trackerCD
            
            try context.save()
        } catch {
        }
    }
    
    func removeRecord(_ record: TrackerRecord) {
        let (start, end) = dayBounds(for: record.dateLogged)
        
        let fetch = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(
            format: "tracker.id == %@ AND (dateLogged >= %@ AND dateLogged < %@)",
            record.trackerId as NSUUID, start as NSDate, end as NSDate
        )
        fetch.fetchLimit = 1
        
        do {
            if let recordCD = try context.fetch(fetch).first {
                context.delete(recordCD)
                try context.save()
            }
        } catch {
        }
    }
    
    func isCompleted(trackerId: UUID, date: Date) -> Bool {
        let (start, end) = dayBounds(for: date)
        
        let fetch = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(
            format: "tracker.id == %@ AND (dateLogged >= %@ AND dateLogged < %@)",
            trackerId as NSUUID, start as NSDate, end as NSDate
        )
        
        do {
            let result = try context.count(for: fetch) > 0
            return result
        } catch {
            return false
        }
    }
    
    func countRecords(for trackerId: UUID) -> Int {
        let fetch = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(format: "tracker.id == %@", trackerId as NSUUID)
        do {
            let count = try context.count(for: fetch)
            return count
        } catch {
            return 0
        }
    }
    
    // MARK: - Helpers
    
    private func dayBounds(for date: Date) -> (Date, Date) {
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            assertionFailure("❌ Unable to calculate end of day for \(date)")
            return (date, date)
        }
        return (start, end)
    }
}
