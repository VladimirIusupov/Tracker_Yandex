import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func updateQuantity(cell: TrackerCollectionViewCell)
}

protocol CreationDelegate: AnyObject {
    func didCreateTracker(name: String, category: TrackerCategory, emoji: Character, color: UIColor, schedule: Set<Day>)
    func didCreateEvent(name: String, category: TrackerCategory, emoji: Character, color: UIColor)
    func didCreateCategory(name: String)
}

protocol UserTrackersServiceDelegate: AnyObject {
    func reloadData()
}

final class TrackersListViewController: UIViewController {
    
    // MARK: - Private Properties
    private var userTrackersService: UserTrackersServiceProtocol = TrackerService()
    
    private lazy var cellWidth = ceil((UIScreen.main.bounds.width - sideInset * 2 - 10)/2)
    private let cellHeight: CGFloat = 148
    private let sideInset: CGFloat = 16
    private let minimumCellSpacing: CGFloat = 9
    
    private let calendar = Calendar.current
    private var currentDate: Date = Date()
    private let today = Date()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.clearButtonMode = .never
        searchBar.setValue("Отменить", forKey: "cancelButtonText")
        searchBar.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        return searchBar
    }()
    
    private lazy var starImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "star"))
        return imageView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
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
        
        emptyView.isHidden = userTrackersService.getAllTrackersCount() > 0
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        view.addSubview(collectionView)
        view.addSubview(emptyView)
        emptyView.addSubview(errorView)
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        errorView.addSubview(starImageView)
        errorView.addSubview(errorLabel)

    }
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            starImageView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            starImageView.topAnchor.constraint(equalTo: errorView.topAnchor),
            starImageView.heightAnchor.constraint(equalToConstant: 80),
            starImageView.widthAnchor.constraint(equalToConstant: 80),
            
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 8),
            errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupNavBarItems() {
        let blackColor: UIColor = .ypBlack

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "plus"),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = blackColor

        let datePicker = UIDatePicker()
        datePicker.tintColor = blackColor
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setTrackersForFayOfWeek(_ day: Day) {
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
                return
            }
        }
        emptyView.isHidden = false
    }

    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        guard let selectedDay = sender.date.dayOfWeek(calendar: calendar) else { return }
        currentDate = sender.date
        setTrackersForFayOfWeek(selectedDay)
    }
    
    @objc
    private func plusButtonTapped() {
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
        cell.setupCell(tracker: tracker, days: days, isCompletedToday: isCompletedAtPickedDay)
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
    
    func didCreateCategory(name: String) {
        let newCategory = TrackerCategory(name: name, trackers: [])
        userTrackersService.addCategory(newCategory)
        userTrackersService.setFilteredCategories(userTrackersService.getAllCategories())
    }
}

// MARK: - UserTrackersServiceDelegate
extension TrackersListViewController: UserTrackersServiceDelegate {
    func reloadData() {
        emptyView.isHidden = userTrackersService.getAllTrackersCount() > 0
        collectionView.reloadData()
    }
}

// MARK: - TrackerCollectionViewCellDelegate
extension TrackersListViewController: TrackerCollectionViewCellDelegate {
    func updateQuantity(cell: TrackerCollectionViewCell) {
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
        // пользователь может отметить трекер выполненным только если сегодня тот же день недели

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

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
