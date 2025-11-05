import Foundation

final class NewCategoryViewModel {
    
    var onCategorySaved: (() -> Void)?
    
    private let store = TrackerCategoryStore()
    
    func saveCategory(name: String) {
        let category = TrackerCategory(name: name, trackers: [])
        store.addCategory(category)
        onCategorySaved?()
    }
    
}
