import CoreData
import UIKit

final class TrackerRecordStore {
    
    static let shared = TrackerRecordStore()

    private let context: NSManagedObjectContext
    private let calendar = Calendar(identifier: .iso8601)
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
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
            
            // Avoid duplicates for this day
            if isCompleted(trackerId: record.trackerId, date: record.dateLogged) {
                return
            }
            
            let recordCD = TrackerRecordCoreData(context: context)
            recordCD.dateLogged = record.dateLogged
            recordCD.tracker = trackerCD
            
            try context.save()
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
                try context.save()
                print("🗑 Removed record for \(record.trackerId) at \(record.dateLogged)")
            }
        } catch {
            print("❌ Error removing record for trackerID \(record.trackerId): \(error). File \(#file), line \(#line)")
        }
    }
    
    func isCompleted(trackerId: UUID, date: Date) -> Bool {
        let (start, end) = dayBounds(for: date)
        
        let fetch = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(
            format: "tracker.id == %@ AND (dateLogged >= %@ AND dateLogged < %@)",
            trackerId as CVarArg, start as CVarArg, end as CVarArg
        )
        
        do {
            return try context.count(for: fetch) > 0
        } catch {
            print("❌ Error checking completion for trackerID \(trackerId): \(error). File \(#file), line \(#line)")
            return false
        }
    }
    
    func countRecords(for trackerId: UUID) -> Int {
        let fetch = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        do {
            return try context.count(for: fetch)
        } catch {
            print("❌ Error counting records for trackerID \(trackerId): \(error)")
            return 0
        }
    }
    
    // MARK: - Helpers
    
    private func dayBounds(for date: Date) -> (Date, Date) {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return (start, end)
    }
}
