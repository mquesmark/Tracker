import CoreData

final class TrackerCategoryStore {
    
    private let context: NSManagedObjectContext
    
    init() {
        context = DataBaseStore.shared.context
    }
    
    func addCategory(_ category: TrackerCategory) {
        guard !isCategoryExists(category) else {
            return
        }
        let categoryCD = TrackerCategoryCoreData(context: context)
        categoryCD.name = category.name
        try? context.save()
    }
    
    func fetchAllCategoriesWithoutFetchingIncludedTrackers() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let categoriesCD = try context.fetch(fetchRequest)
            return categoriesCD.map { TrackerCategory(name: $0.name ?? "", trackers: []) }
        } catch {
            return []
        }
    }
    
    func isCategoryExists(_ category: TrackerCategory) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", category.name)

        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
    
}
