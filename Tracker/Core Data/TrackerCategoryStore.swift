import CoreData

final class TrackerCategoryStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addCategory(_ category: TrackerCategory) {
        let categoryCD = TrackerCategoryCoreData(context: context)
        categoryCD.name = category.name        
        try? context.save()
    }
}
