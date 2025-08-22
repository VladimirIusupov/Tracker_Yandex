import Foundation

typealias Binding<T> = (T) -> Void

protocol TrackerCategoryListViewModelDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

enum CategoryState {
    case empty
    case containsItems
}

final class TrackerCategoryListViewModel {

    // MARK: - Public Properties
    weak var delegate: TrackerCategoryListViewModelDelegate?

    var categoryStateBinding: Binding<Bool>?
    var categoryBinding: (() -> Void)?
    var navigateToCreateCategory: (() -> Void)?
    var navigateBack: (() -> Void)?

    // MARK: - Private Properties
    private var selectedCategory: TrackerCategoryViewModel?
    private var trackerCategoryStore: TrackerCategoryStoreProtocol
    private var categoryState: CategoryState = .empty {
        didSet {
            if categoryState == .containsItems {
                categoryStateBinding?(true)
            } else {
                categoryStateBinding?(false)
            }
        }
    }
    private(set) var categories: [TrackerCategoryViewModel] = [] {
        didSet {
            updateCategoryState()
            categoryBinding?()
        }
    }

    // MARK: - Init
    init(trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore.shared) {
        self.trackerCategoryStore = trackerCategoryStore
        self.categories = getCategoriesFromStore()
        updateCategoryState()
    }

    // MARK: - Public Methods
    func categorySelected(at index: Int) {
        guard index < categories.count else { return }
        selectedCategory?.isSelected = false
        selectedCategory = categories[index]
        categories[index].isSelected = true
        categoryBinding?()
        delegate?.didSelectCategory(categories[index].trackerCategory)
        navigateBack?()
    }

    func onButtonTapped() {
        navigateToCreateCategory?()
    }

    func updateCategoryState() {
        self.categoryState = categories.isEmpty ? .empty : .containsItems
    }
    
    func loadCategories() {
        self.categories = getCategoriesFromStore()
    }

    // MARK: - Private Methods
    private func getCategoriesFromStore() -> [TrackerCategoryViewModel] {
        let categories: [TrackerCategory] = trackerCategoryStore.categories
        return categories.map({TrackerCategoryViewModel(trackerCategory: $0)})
    }

}

// MARK: - CategoryCreationDelegate
extension TrackerCategoryListViewModel: CategoryCreationDelegate {
    func didCreateCategory(named name: String) {
        let category = TrackerCategory(name: name, trackers: [])
        do {
            try trackerCategoryStore.add(category)
            self.categories = getCategoriesFromStore()
        } catch {
            print("[TrackerCategoryListViewModel.didCreateCategory]: Не удалось добавить категорию")
            return
        }
    }
}
