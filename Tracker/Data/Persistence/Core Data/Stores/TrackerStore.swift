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
    // MARK: - Singleton
    static let shared = TrackerStore()
    
    // MARK: - Properties
    
    // MARK: - Public API: Read / Counts
    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    
    // MARK: - Internal State
    private var currentDate: Date = Date()
    private var currentSearchText: String? = nil
    private var currentFilter: TrackerFilter? = nil
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
    
    // MARK: - Lifecycle
    private override init() {
        context = DataBaseStore.shared.context
        super.init()
        
        setupFetchedResultsController(for: Date())
        try? fetchedResultsController?.performFetch()
    }
    
    private func setupFetchedResultsController(for date: Date) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = buildPredicate(for: date, searchText: currentSearchText)
        
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
    
    func numberOfItems(in section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections,
              section >= 0, section < sections.count else { return 0 }
        return sections[section].numberOfObjects
    }

    // MARK: - Public API: Accessors
    func tracker(at indexPath: IndexPath) -> TrackerCoreData {
        guard let frc = fetchedResultsController else {
            preconditionFailure("FetchedResultsController is not configured")
        }
        return frc.object(at: indexPath)
    }
    
    // MARK: - Conversion Helpers
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
    
    // MARK: - Section Titles
    func titleForSection(_ section: Int) -> String {
        guard let sections = fetchedResultsController?.sections,
              section >= 0, section < sections.count else {
            return NSLocalizedString("default_category", comment: "Default category text")
        }
        let name = sections[section].name
        return name.isEmpty ? NSLocalizedString("default_category", comment: "Default category text") : name
    }
    
    // MARK: - Create / Add
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
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.storeDidReloadData(self)
            }
            
            } catch {}
    }

    // MARK: - Private Helpers (Predicates)
    private func buildPredicate(for date: Date, searchText text: String?) -> NSPredicate? {
        var predicates: [NSPredicate] = []
                
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekdayNumber = calendar.component(.weekday, from: date)
        let adjusted = weekdayNumber == 1 ? 7 : weekdayNumber - 1

        if let weekday = WeekDay(rawValue: adjusted) {
            let schedulePredicate = NSPredicate(format: "schedule CONTAINS %@", NSNumber(value: weekday.rawValue))
            predicates.append(schedulePredicate)
        }
        
        if let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            let namePredicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
            predicates.append(namePredicate)
        }
        
        if currentFilter == .completed || currentFilter == .notCompleted {
            let ids = completedTrackerIDs(on: date)
            if currentFilter == .completed {
                predicates.append(NSPredicate(format: "id IN %@", ids as [UUID]))
            } else if currentFilter == .notCompleted {
                predicates.append(NSPredicate(format: "NOT (id IN %@)", ids as [UUID]))
            }
        }
        if predicates.isEmpty {
            return nil
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private func completedTrackerIDs(on date: Date) -> [UUID] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        
        request.predicate = NSPredicate(format: "dateLogged >= %@ AND dateLogged < %@", start as NSDate, end as NSDate)
        
        do {
            let records = try context.fetch(request)
            return records.compactMap { $0.tracker?.id }
        } catch {
            return []
        }
    }
    
    // MARK: - Query Updates (Date / Search / Filter)
    func updateDate(_ newDate: Date) {
        currentDate = newDate
        fetchedResultsController?.fetchRequest.predicate = buildPredicate(for: newDate, searchText: currentSearchText)
        try? fetchedResultsController?.performFetch()
#if DEBUG
        self.debugLogSections("after updateDate")
#endif
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.storeDidReloadData(self)
        }
    }
    
    func updateSearchText(_ text: String?) {
        currentSearchText = text
        fetchedResultsController?.fetchRequest.predicate = buildPredicate(for: currentDate, searchText: currentSearchText)
        try? fetchedResultsController?.performFetch()
#if DEBUG
        self.debugLogSections("after updateSearchText")
#endif
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.storeDidReloadData(self)
        }
    }

    func updateFilter(_ filter: TrackerFilter?) {
        currentFilter = filter
        fetchedResultsController?.fetchRequest.predicate = buildPredicate(for: currentDate, searchText: currentSearchText)
        try? fetchedResultsController?.performFetch()
#if DEBUG
        self.debugLogSections("after updateFilter")
#endif
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.storeDidReloadData(self)
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    // MARK: - NSFetchedResultsControllerDelegate
    
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

// MARK: - CRUD (Edit & Delete) Stubs
extension TrackerStore {

    /// Updates an existing tracker by id and fields. Creates the category if it doesn't exist.
    func updateTracker(id: UUID,
                       name: String,
                       categoryName: String,
                       schedule: [WeekDay],
                       color: UIColor,
                       emoji: String) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)

        do {
            guard let trackerCD = try context.fetch(request).first else { return }

            // Update primitive fields
            trackerCD.name = name
            trackerCD.emoji = emoji
            trackerCD.color = color
            trackerCD.schedule = schedule as NSArray

            // Ensure category exists (or create) and assign
            let catRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            catRequest.fetchLimit = 1
            catRequest.predicate = NSPredicate(format: "name == %@", categoryName)
            let categoryCD = try context.fetch(catRequest).first ?? {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.name = categoryName
                return newCategory
            }()
            trackerCD.category = categoryCD

            try context.save()

            do {
                try self.fetchedResultsController?.performFetch()
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.storeDidReloadData(self)
                }
            } catch { }
        } catch { }
    }

    /// Delete an existing tracker. Implementation to be added.
    func deleteTracker(at indexPath: IndexPath) {
        let cd = tracker(at: indexPath)
        guard let id = cd.id else { return }
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        
        do {
            guard let cd = try context.fetch(request).first else { return }
            
            let recordsRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            recordsRequest.predicate = NSPredicate(format: "tracker == %@", cd)
            if let records = try? context.fetch(recordsRequest) {
                records.forEach { context.delete($0)}
            }
            
            context.delete(cd)
            try context.save()
            // FRC delegate will update UI; do not force refetch or reload
        } catch {}
    }
}

extension TrackerStore {
    // MARK: - Records (Toggle Completion)
    
    func toggleRecord(for tracker: Tracker, for date: Date) {
        let rs = TrackerRecordStore.shared
        let record = TrackerRecord(trackerId: tracker.id, dateLogged: date)
        if rs.isCompleted(trackerId: tracker.id, date: date) {
            rs.removeRecord(record)
            print("✅ Removed record for", tracker.name)
        } else {
            rs.addRecord(record)
            print("✅ Added record for", tracker.name)
        }
        // Rebuild predicate because Completed/NotCompleted filters depend on records
        fetchedResultsController?.fetchRequest.predicate = buildPredicate(for: currentDate, searchText: currentSearchText)
        do {
            try fetchedResultsController?.performFetch()
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.storeDidReloadData(self)
            }
        } catch {
            print("❌ performFetch after toggleRecord failed:", error)
        }
    }
}


#if DEBUG
extension TrackerStore {
    fileprivate func debugLogSections(_ note: String) {
        if let secs = fetchedResultsController?.sections {
            let parts = secs.enumerated().map { "\($0.offset): \($0.element.name) [\($0.element.numberOfObjects)]" }.joined(separator: ", ")
            print("📦 FRC \(note) — sections=\(secs.count) { \(parts) }")
        } else {
            print("📦 FRC \(note) — sections=nil")
        }
    }
}
#endif

