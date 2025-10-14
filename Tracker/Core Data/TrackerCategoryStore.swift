import CoreData

final class TrackerCategoryStore {
    
    private let context: NSManagedObjectContext
    
    init() {
        context = DataBaseStore.shared.context
    }
    
    func addCategory(_ category: TrackerCategory) {
        let categoryCD = TrackerCategoryCoreData(context: context)
        categoryCD.name = category.name        
        try? context.save()
    }
}
