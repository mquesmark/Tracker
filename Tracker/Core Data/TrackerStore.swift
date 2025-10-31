import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate)
    func storeDidReloadData(_ store: TrackerStore)
}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let from: IndexPath
        let to: IndexPath
    }
    let inserted: [IndexPath]
    let deleted: [IndexPath]
    let updated: [IndexPath]
    let moved: Set<Move>
    
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
    
    private var allTrackers: [Tracker] = []
    private var filteredTrackers: [Tracker] = []
    
    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    
    private var currentDate: Date = Date()
    private var context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    private var fetchedResultsController:
    NSFetchedResultsController<TrackerCoreData>?
    
    var insertedIndexPaths: [IndexPath]?
    var deletedIndexPaths: [IndexPath]?
    var updatedIndexPaths: [IndexPath]?
    var movedIndexPaths: Set<TrackerStoreUpdate.Move>?
    var insertedSections: IndexSet?
    var deletedSections: IndexSet?
    
    private override init() {
        context = DataBaseStore.shared.context
        super.init()
        
        setupFetchedResultsController(for: Date())
        try? fetchedResultsController?.performFetch()
    }
    
    func numberOfItems(in section: Int) -> Int {
        fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData {
        guard let frc = fetchedResultsController else {
            assertionFailure("❌ FRC is nil in tracker(at:)")
            return TrackerCoreData(context: context)
        }
        return frc.object(at: indexPath)
    }
    
    func convertToTracker(_ trackerCD: TrackerCoreData) -> Tracker? {
        guard let id = trackerCD.id,
              let name = trackerCD.name,
              let emoji = trackerCD.emoji else {
            return nil
        }
        
        let color: UIColor
        if let data = trackerCD.color as? Data,
           let decoded = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
            color = decoded
        } else if let storedColor = trackerCD.color as? UIColor {
            color = storedColor
        } else {
            return nil
        }
        
        guard let schedule = trackerCD.schedule as? [WeekDay] else {
            return nil
        }
        
        return Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: schedule
        )
    }
    func titleForSection(_ section: Int) -> String {
        fetchedResultsController?.sections?[section].name ?? "Категория по умолчанию"
    }
    
    
    func addTracker(_ tracker: Tracker, toCategoryWithName categoryName: String)
    {
        let request: NSFetchRequest<TrackerCategoryCoreData> =
        TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", categoryName)
        
        var category = try? context.fetch(request).first
        
        if category == nil {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = categoryName
            category = newCategory
        }
        let trackerCD = TrackerCoreData(context: context)
        trackerCD.name = tracker.name
        trackerCD.emoji = tracker.emoji
        trackerCD.id = tracker.id
        trackerCD.color = tracker.color
        trackerCD.schedule = tracker.schedule as NSArray
        trackerCD.category = category
        
        try? context.save()
        
        do {
            try self.fetchedResultsController?.performFetch()
            self.delegate?.storeDidReloadData(self)
        } catch {
        }
    }
    
    private func setupFetchedResultsController(for date: Date) {
        let request = TrackerCoreData.fetchRequest()
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekdayNumber = calendar.component(.weekday, from: date)
        let adjusted = weekdayNumber == 1 ? 7 : weekdayNumber - 1
        let weekday = WeekDay(rawValue: adjusted)
        if let weekday {
            request.predicate = NSPredicate(format: "schedule CONTAINS %@", NSNumber(value: weekday.rawValue))
        }
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.name, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]
        
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )
        frc.delegate = self
        self.fetchedResultsController = frc
    }
    
    func updateDate(_ newDate: Date) {
        currentDate = newDate
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekdayNumber = calendar.component(.weekday, from: newDate)
        let adjusted = weekdayNumber == 1 ? 7 : weekdayNumber - 1
        let weekday = WeekDay(rawValue: adjusted)
        
        if let weekday {
            fetchedResultsController?.fetchRequest.predicate = NSPredicate(
                format: "schedule CONTAINS %@", NSNumber(value: weekday.rawValue)
            )
        } else {
            fetchedResultsController?.fetchRequest.predicate = nil
        }
        
        try? fetchedResultsController?.performFetch()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.storeDidReloadData(self)
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        insertedIndexPaths = []
        deletedIndexPaths = []
        updatedIndexPaths = []
        movedIndexPaths = []
        insertedSections = []
        deletedSections = []
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let new = newIndexPath else { return }
            insertedIndexPaths?.append(new)
        case .delete:
            guard let old = indexPath else { return }
            deletedIndexPaths?.append(old)
        case .update:
            guard let idx = indexPath else { return }
            updatedIndexPaths?.append(idx)
        case .move:
            guard let old = indexPath, let new = newIndexPath else { return }
            movedIndexPaths?.insert(.init(from: old, to: new))
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            deletedSections?.insert(sectionIndex)
        case .insert:
            insertedSections?.insert(sectionIndex)
        default:
            break
        }
    }
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                inserted: insertedIndexPaths ?? [],
                deleted: deletedIndexPaths ?? [],
                updated: updatedIndexPaths ?? [],
                moved: movedIndexPaths ?? [],
                insertedSections: insertedSections ?? [],
                deletedSections: deletedSections ?? []
            )
        )
        insertedIndexPaths = nil
        deletedIndexPaths = nil
        updatedIndexPaths = nil
        movedIndexPaths = nil
        insertedSections = nil
        deletedSections = nil
    }
    
}

extension TrackerStore {
    
    func toggleRecord(for tracker: Tracker, for date: Date) {
        
        let rs = TrackerRecordStore.shared
        let record = TrackerRecord(trackerId: tracker.id, dateLogged: date)
        if rs.isCompleted(trackerId: tracker.id, date: date) {
            rs.removeRecord(record)
        } else {
            rs.addRecord(record)
        }
        context.refreshAllObjects()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let self else { return }
            do {
                try self.fetchedResultsController?.performFetch()
                self.delegate?.storeDidReloadData(self)
            } catch {
            }
        }
        
    }
}
