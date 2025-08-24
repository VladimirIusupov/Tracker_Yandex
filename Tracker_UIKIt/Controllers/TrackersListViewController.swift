import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func updateQuantity(cell: TrackerCollectionViewCell)
    func delete(cell: TrackerCollectionViewCell)
    func update(cell: TrackerCollectionViewCell)
    func togglePin(cell: TrackerCollectionViewCell)
}

protocol CreationDelegate: AnyObject {
    func didCreateTracker(name: String, category: TrackerCategory, emoji: Character, color: UIColor, schedule: Set<Day>)
    func didCreateEvent(name: String, category: TrackerCategory, emoji: Character, color: UIColor)
    func didCreateCategory(name: String)
    func didUpdate(tracker: Tracker, with category: TrackerCategory)
}

protocol UserTrackersServiceDelegate: AnyObject {
    func reloadData()
}

final class TrackersListViewController: UIViewController {

    // MARK: - Private Properties
    enum ErrorLabelState {
        case noData
        case emptySearch
    }
    private var userTrackersService: UserTrackersServiceProtocol = TrackerService()
    private var currentFilter: Filter = .all
    private lazy var cellWidth = ceil((UIScreen.main.bounds.width - sideInset * 2 - 10)/2)
    private let cellHeight: CGFloat = 148
    private let sideInset: CGFloat = 16
    private let minimumCellSpacing: CGFloat = 9

    private let calendar = Calendar.current
    private var currentDate: Date = Date()
    private let today = Date()

    private let datePicker = UIDatePicker()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        return collectionView
    }()

    private lazy var emptyView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var errorView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Trackers.filters, for: .normal)
        button.setTitleColor(.ypAlwaysWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypBlue
        button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Trackers.title
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = L10n.Trackers.search
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.clearButtonMode = .never
        searchBar.setValue(L10n.General.cancel, forKey: "cancelButtonText")
        searchBar.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        searchBar.searchTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        return searchBar
    }()

    private lazy var errorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "star"))
        return imageView
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Trackers.emptyState
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite

        userTrackersService.delegate = self
        setupNavBarItems()
        setupSubviews()
        setupConstraints()

        let condition = userTrackersService.getAllTrackersCount() > 0
        emptyView.isHidden = condition
        filtersButton.isHidden = !condition
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.reportEvent(event: "open", screen: "Main")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.reportEvent(event: "close", screen: "Main")
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        view.addSubview(collectionView)
        view.addSubview(emptyView)
        emptyView.addSubview(errorView)
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        errorView.addSubview(errorImageView)
        errorView.addSubview(errorLabel)
        view.addSubview(filtersButton)
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        filtersButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 1),

            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            emptyView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            errorView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor),

            errorImageView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorImageView.topAnchor.constraint(equalTo: errorView.topAnchor),
            errorImageView.heightAnchor.constraint(equalToConstant: 80),
            errorImageView.widthAnchor.constraint(equalToConstant: 80),

            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 8),
            errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)

        ])
    }

    private func setupNavBarItems() {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        let blackColor: UIColor = .ypBlack

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "plus"),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = blackColor

        datePicker.tintColor = .ypAlwaysBlack
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setCompletedTrackers(for date: Date) {
        let allCategoriesForDate = categoriesForDate(date)
        let completedCategories = filterCategories(allCategoriesForDate, date: date, showCompleted: true)

        userTrackersService.setFilteredCategories(completedCategories)
        collectionView.reloadData()
        updateEmptyViewVisibility(filteredCategories: completedCategories, initialCategories: allCategoriesForDate)
    }

    private func setUncompletedTrackers(for date: Date) {
        let allCategoriesForDate = categoriesForDate(date)
        let uncompletedCategories = filterCategories(allCategoriesForDate, date: date, showCompleted: false)

        userTrackersService.setFilteredCategories(uncompletedCategories)
        collectionView.reloadData()
        updateEmptyViewVisibility(filteredCategories: uncompletedCategories, initialCategories: allCategoriesForDate)
    }

    private func categoriesForDate(_ date: Date) -> [TrackerCategory] {
        guard let day = date.dayOfWeek(calendar: calendar) else {
            return []
        }
        return userTrackersService.getAllCategories().compactMap { category in
            let trackersForDate = category.trackers.filter {
                $0.schedule.contains(day)
            }

            return trackersForDate.isEmpty ? nil : TrackerCategory(name: category.name, trackers: trackersForDate)
        }
    }

    private func updateEmptyViewVisibility(
        filteredCategories: [TrackerCategory],
        initialCategories: [TrackerCategory]
    ) {
        let hasTrackersAfterFilter = filteredCategories.contains { !$0.trackers.isEmpty }
        let hadTrackersBeforeFilter = initialCategories.contains { !$0.trackers.isEmpty }

        emptyView.isHidden = hasTrackersAfterFilter
        filtersButton.isHidden = !hadTrackersBeforeFilter

        if !hasTrackersAfterFilter {
            setErrorView(with: .emptySearch)
        }
    }

    private func filterCategories(
        _ categories: [TrackerCategory],
        date: Date,
        showCompleted: Bool
    ) -> [TrackerCategory] {
        categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let isCompleted = userTrackersService.completedTrackers.contains {
                    $0.trackerId == tracker.id && calendar.isDate($0.date, inSameDayAs: date)
                }
                return showCompleted ? isCompleted : !isCompleted
            }

            return filteredTrackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: filteredTrackers)
        }
    }

    private func setTrackersForDayOfWeek(_ day: Day) {
        var filteredCategories: [TrackerCategory] = []
        for category in userTrackersService.getAllCategories() {
            let filteredTrackers = TrackerCategory(name: category.name, trackers: (category.trackers.filter { $0.schedule.contains(day) }))
            filteredCategories.append(filteredTrackers)
        }
        userTrackersService.setFilteredCategories(filteredCategories)
        collectionView.reloadData()
        for category in userTrackersService.categories {
            if !category.trackers.isEmpty {
                emptyView.isHidden = true
                filtersButton.isHidden = false
                return
            }
        }
        setErrorView(with: .emptySearch)
        emptyView.isHidden = false
        filtersButton.isHidden = true
    }

    private func setSearchedTrackers(for searchText: String) {
        var filteredCategories: [TrackerCategory] = []
        for category in userTrackersService.categories {
            let filteredTrackers = TrackerCategory(name: category.name, trackers: (category.trackers.filter { $0.name.lowercased().contains(searchText.lowercased()) }))
            filteredCategories.append(filteredTrackers)
        }
        userTrackersService.setFilteredCategories(filteredCategories)
        collectionView.reloadData()
        for category in userTrackersService.categories {
            if !category.trackers.isEmpty {
                emptyView.isHidden = true
                filtersButton.isHidden = false
                return
            }
        }
        setErrorView(with: .emptySearch)
        emptyView.isHidden = false
        filtersButton.isHidden = true
    }

    private func filter() {
        if userTrackersService.getAllCategories().isEmpty {
            errorLabel.text = L10n.Trackers.emptyState
            errorImageView.image = UIImage(named: "star")
            emptyView.isHidden = false
            filtersButton.isHidden = true
            return
        }
        emptyView.isHidden = true
        filtersButton.isHidden = false
        switch currentFilter {
        case .all,.today:
            guard let selectedDay = currentDate.dayOfWeek(calendar: calendar) else { return }
            setTrackersForDayOfWeek(selectedDay)
        case .completed:
            setCompletedTrackers(for: currentDate)
        case .uncompleted:
            setUncompletedTrackers(for: currentDate)
        }
    }

    private func setErrorView(with state: ErrorLabelState) {
        switch state {
        case .emptySearch:
            errorLabel.text = L10n.Trackers.emptySearch
            errorImageView.image = UIImage(named: "nothingFound")
        case .noData:
            errorLabel.text = L10n.Trackers.emptyState
            errorImageView.image = UIImage(named: "star")
        }
    }

    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        filter()
    }

    @objc
    private func plusButtonTapped() {
        AnalyticsService.reportEvent(event: "click", screen: "Main", item: "add_track")
        let viewController = TrackerTypeChoiceViewController()
        viewController.delegate = self
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }

    @objc
    private func hideKeyboard() {
        self.view.endEditing(true)
    }

    @objc func textDidChange(_ searchField: UISearchTextField) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            setSearchedTrackers(for: searchText)
        } else {
            userTrackersService.setFilteredCategories(categoriesForDate(currentDate))
            filter()
            emptyView.isHidden = true
            collectionView.reloadData()
        }
    }

    @objc
    private func onButtonTapped() {
        AnalyticsService.reportEvent(event: "click", screen: "Main", item: "filter")
        let viewController = FiltersViewController()
        viewController.delegate = self
        viewController.currentFilter = currentFilter
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userTrackersService.categories[section].trackers.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return userTrackersService.categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = userTrackersService.categories[indexPath.section]
        let tracker = category.trackers[indexPath.row]

        let days = userTrackersService.completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isCompletedAtPickedDay = userTrackersService.completedTrackers.contains { record in
            record.trackerId == tracker.id && calendar.isDate(record.date, inSameDayAs: currentDate)
        }
        cell.delegate = self
        cell.setupCell(tracker: tracker, days: days, isCompletedToday: isCompletedAtPickedDay,isPinned: userTrackersService.isPinned(trackerId: tracker.id))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.identifier,
            for: indexPath
        ) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }

        headerView.setTitle(userTrackersService.categories[indexPath.section].name)
        return headerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if userTrackersService.categories[section].trackers.isEmpty {
            return .zero
        }
        return CGSize(width: collectionView.frame.width, height: 46)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumCellSpacing
    }
}

// MARK: - CreationDelegate
extension TrackersListViewController: CreationDelegate {
    func didCreateEvent(name: String, category: TrackerCategory, emoji: Character, color: UIColor) {
        let newEvent = Tracker(id: UUID(), name: name, color: color, emoji: emoji,schedule: [])
        userTrackersService.addTracker(tracker: newEvent, to: category)
    }

    func didCreateTracker(name: String, category: TrackerCategory, emoji: Character, color: UIColor, schedule: Set<Day>) {
        let newTracker = Tracker(id: UUID(), name: name, color: color, emoji: emoji, schedule: schedule)
        userTrackersService.addTracker(tracker: newTracker, to: category)
    }

    func didUpdate(tracker: Tracker, with category: TrackerCategory) {
        userTrackersService.updateTracker(tracker, with: category)
    }

    func didCreateCategory(name: String) {
        let newCategory = TrackerCategory(name: name, trackers: [])
        userTrackersService.addCategory(newCategory)
        userTrackersService.setFilteredCategories(userTrackersService.getAllCategories())
    }
}

// MARK: - UserTrackersServiceDelegate
extension TrackersListViewController: UserTrackersServiceDelegate {
    func reloadData() {
        let condition = userTrackersService.getAllTrackersCount() > 0
        emptyView.isHidden = condition
        filtersButton.isHidden = !condition
        collectionView.reloadData()
    }
}

// MARK: - TrackerCollectionViewCellDelegate
extension TrackersListViewController: TrackerCollectionViewCellDelegate {
    func delete(cell: TrackerCollectionViewCell) {
        AnalyticsService.reportEvent(event: "click", screen: "Main", item: "delete")
        let alertController = UIAlertController(
            title: nil,
            message: L10n.TrackerActions.warning,
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(
            title: L10n.General.delete,
            style: .destructive
        ) { [weak self] _ in
            guard let tracker = cell.tracker else { return }
            self?.userTrackersService.deleteTracker(tracker)
        }

        let cancelAction = UIAlertAction(
            title: L10n.General.cancel,
            style: .cancel,
            handler: nil
        )

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func update(cell: TrackerCollectionViewCell) {
        AnalyticsService.reportEvent(event: "click", screen: "Main", item: "edit")
        guard
            let tracker = cell.tracker,
            let category = userTrackersService.getCategory(of: tracker)
        else { return }
        let viewController = TrackerUpdateViewController(with: tracker, in: category, completed: cell.days)
        viewController.delegate = self
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }

    func togglePin(cell: TrackerCollectionViewCell) {
        guard let trackerID = cell.trackerID else {return}
        userTrackersService.togglePin(trackerId: trackerID)
    }

    func updateQuantity(cell: TrackerCollectionViewCell) {
        AnalyticsService.reportEvent(event: "click", screen: "Main", item: "track")
        guard
            let trackerID = cell.trackerID,
            let schedule = cell.schedule,
            let weekDay = currentDate.dayOfWeek(calendar: calendar)
        else {return}

        let isCompletedAtPickedDay = userTrackersService.completedTrackers.contains { record in
            record.trackerId == trackerID && calendar.isDate(record.date, inSameDayAs: currentDate)
        }
        let isSameOrEarlierDay = calendar.compare(currentDate, to: today, toGranularity: .day) != .orderedDescending
        let isSameWeekDay = schedule.isEmpty || schedule.contains(weekDay)

        if isSameOrEarlierDay && !isCompletedAtPickedDay && isSameWeekDay {
            userTrackersService.addTrackerRecord(TrackerRecord(trackerId: trackerID, date: currentDate))
            cell.updateDays(days: userTrackersService.completedTrackers.filter() {$0.trackerId == trackerID}.count, isAddition: true)
        } else if isCompletedAtPickedDay && isSameWeekDay {
            userTrackersService.removeTrackerRecord(TrackerRecord(trackerId: trackerID, date: currentDate), forDate: currentDate, using: calendar)
            cell.updateDays(days: userTrackersService.completedTrackers.filter() {$0.trackerId == trackerID}.count, isAddition: false)
        }
    }
}

// MARK: - UISearchBarDelegate
extension TrackersListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.searchTextField.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        userTrackersService.setFilteredCategories(userTrackersService.getAllCategories())
        filter()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - FiltersProtocol
extension TrackersListViewController: FiltersProtocol {
    func didSelectFilter(_ filter: Filter) {
        self.currentFilter = filter
        switch currentFilter {
        case .all:
            guard let selectedDay = currentDate.dayOfWeek(calendar: calendar) else { return }
            setTrackersForDayOfWeek(selectedDay)
        case .today:
            guard let selectedDay = today.dayOfWeek(calendar: calendar) else { return }
            datePicker.date = today
            currentDate = today
            setTrackersForDayOfWeek(selectedDay)
        case .completed:
            setCompletedTrackers(for: currentDate)
        case .uncompleted:
            setUncompletedTrackers(for: currentDate)
        }
    }
}
