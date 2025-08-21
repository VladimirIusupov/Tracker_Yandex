final class TrackerCategoryViewModel {
    
    // MARK: - Public Properties
    let trackerCategory: TrackerCategory
    var isSelected: Bool = false

    // MARK: - Init
    init(trackerCategory: TrackerCategory) {
        self.trackerCategory = trackerCategory
    }
}
