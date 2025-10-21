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
        trackerFetch.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)
        trackerFetch.fetchLimit = 1
        
        do {
            guard let trackerCD = try context.fetch(trackerFetch).first else {
                print("⚠️ Tracker with ID \(record.trackerId) not found. File \(#file), line:  \(#line) ")
                return
            }
            
            guard !isCompleted(trackerId: record.trackerId, date: record.dateLogged) else {
                return
            }
            
            let recordCD = TrackerRecordCoreData(context: context)
            recordCD.dateLogged = record.dateLogged
            recordCD.tracker = trackerCD
            
            print("💾 Saving record...")
            try context.save()
            print("✅ Context save complete")
            print("✅ Saved record for \(record.trackerId) on \(record.dateLogged)")
        } catch {
            print("❌ Error saving record for trackerID \(record.trackerId): \(error). File \(#file), line:  \(#line)")
        }
    }
    
    func removeRecord(_ record: TrackerRecord) {
        let (start, end) = dayBounds(for: record.dateLogged)
        
        let fetch = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(
            format: "tracker.id == %@ AND (dateLogged >= %@ AND dateLogged < %@)",
            record.trackerId as CVarArg, start as CVarArg, end as CVarArg
        )
        fetch.fetchLimit = 1
        
        do {
            if let recordCD = try context.fetch(fetch).first {
                context.delete(recordCD)
                print("💾 Saving record...")
                try context.save()
                print("✅ Context save complete")
                print("🗑 Removed record for \(record.trackerId) at \(record.dateLogged)")
            }
        } catch {
            print("❌ Error removing record for trackerID \(record.trackerId): \(error). File \(#file), line \(#line)")
        }
    }
    
    func isCompleted(trackerId: UUID, date: Date) -> Bool {
        print("🔍 Checking if completed for \(trackerId) on \(date)")
        let (start, end) = dayBounds(for: date)
        
        let fetch = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(
            format: "tracker.id == %@ AND (dateLogged >= %@ AND dateLogged < %@)",
            trackerId as CVarArg, start as CVarArg, end as CVarArg
        )
        
        do {
            let result = try context.count(for: fetch) > 0
            print("🔍 Completed check result: \(result)")
            return result
        } catch {
            print("❌ Error checking completion for trackerID \(trackerId): \(error). File \(#file), line \(#line)")
            return false
        }
    }
    
    func countRecords(for trackerId: UUID) -> Int {
        print("🔍 Counting records for \(trackerId)")
        let fetch = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        do {
            let count = try context.count(for: fetch)
            print("🔍 Found \(count) records for \(trackerId)")
            return count
        } catch {
            print("❌ Error counting records for trackerID \(trackerId): \(error)")
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
