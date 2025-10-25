import Foundation

final class HabitCategoriesViewModel {
    
    var onCategoriesUpdated: (() -> Void)?
    var onCategoryPicked: ((TrackerCategory) -> Void)?
    
    var countOfCategories: Int {
        categories.count
    }
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?()
        }
    }
    
    private let store = TrackerCategoryStore()
    
    private(set) var selectedIndex: Int?

    func isSelectedCategory(at index: Int) -> Bool {
        return selectedIndex == index
    }

    func userSelectedCategory(at index: Int) {
        guard categories.indices.contains(index) else { return }
        selectedIndex = index
        onCategoryPicked?(categories[index])
        onCategoriesUpdated?()
    }
    
    func viewDidLoad() {
        loadCategories()
    }

    func fetchCategoryNames() -> [String] {
        store.fetchAllCategoriesWithoutFetchingIncludedTrackers()
            .filter { !$0.name.isEmpty }
            .map { $0.name }
    }
    
    func categoryName(at index: Int) -> String {
        categories[index].name
    }
    
    func loadCategories() {
        categories = store.fetchAllCategoriesWithoutFetchingIncludedTrackers()
            .filter { !$0.name.isEmpty }
    }
    
    func reloadCategories() {
        loadCategories()
    }
    
}
