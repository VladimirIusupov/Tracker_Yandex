import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Private Properties
    private let tableTitles: [String] = [
        L10n.Statistics.bestPeriod,
        L10n.Statistics.idealDays,
        L10n.Statistics.trackersCompleted,
        L10n.Statistics.average
    ]
    private var tableValues: [Int] = [0,0,0,0]
    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore.shared
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    private let calendar = Calendar.current
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(StatisticsContainerViewCell.self, forCellReuseIdentifier: StatisticsContainerViewCell.reuseIdentifier)
        
        return tableView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.text = L10n.Statistics.title
        return label
    }()
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var errorView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var errorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "nothingToAnalyze"))
        return imageView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Statistics.emptyState
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataUpdatedNotification),
            name: .trackersDataUpdated,
            object: nil
        )
        setupTableValues()
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        view.backgroundColor = .ypWhite
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        emptyView.addSubview(errorView)
        errorView.addSubview(errorImageView)
        errorView.addSubview(errorLabel)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 44),
            
            emptyView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
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
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 408),
            
        ])
    }
    
    private func setupTableValues() {
        let trackerRecords = trackerRecordStore.trackerRecords
        let trackers = trackerStore.trackers
        guard trackerRecords.isEmpty == false else {
            tableView.isHidden = true
            emptyView.isHidden = false
            return
        }
        tableView.isHidden = false
        emptyView.isHidden = true
        tableValues = [0,0,0,0]
        let trackersCompleted = trackerRecords.count
        
        var trackersDict = [Day: [UUID]]()
        trackers.forEach { tracker in
            tracker.schedule.forEach { day in
                if trackersDict[day] != nil {
                    trackersDict[day]?.append(tracker.id)
                } else {
                    trackersDict[day] = [tracker.id]
                }
            }
        }
        var trackerRecordsDict = [Date: [UUID]]()
        var reversedTrackerRecordsDict = [UUID: [Date]]()
        
        trackerRecords.forEach { record in
            let day = calendar.startOfDay(for: record.date)
            
            if trackerRecordsDict[day] != nil {
                trackerRecordsDict[day]?.append(record.trackerId)
            } else {
                trackerRecordsDict[day] = [record.trackerId]
            }
            if reversedTrackerRecordsDict[record.trackerId] != nil {
                reversedTrackerRecordsDict[record.trackerId]?.append(day)
            } else {
                reversedTrackerRecordsDict[record.trackerId] = [day]
            }
        }
        
        var bestPeriod = 0
        var currentPeriod = 0
        var lastDay: Date?
        reversedTrackerRecordsDict.forEach { trackerId, days in
            currentPeriod = 1
            days.sorted().forEach { day in
                if let lastDay,
                   calendar.date(byAdding: .day, value: 1, to: lastDay) == day {
                    currentPeriod += 1
                    bestPeriod = max(bestPeriod, currentPeriod)
                } else {
                    currentPeriod = 1
                    bestPeriod = max(bestPeriod, currentPeriod)
                }
                lastDay = day
            }
            lastDay = nil
        }
        
        var idealDays = 0
        trackerRecordsDict.forEach { day, trackers in
            guard let weekDay = day.dayOfWeek(calendar: calendar) else { return }
            if trackers.count >= trackersDict[weekDay]?.count ?? 0 {
                idealDays += 1
            }
        }
        
        var sum = 0
        trackerRecordsDict.values.forEach { trackers in
            sum += trackers.count
        }
        let average = sum/trackerRecordsDict.count
        tableValues = [bestPeriod, idealDays, trackersCompleted, average]
        tableView.reloadData()
    }
    
    @objc private func handleDataUpdatedNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.setupTableValues()
        }
    }
}

// MARK: - UITableView
extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticsContainerViewCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticsContainerViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: tableValues[indexPath.row], to: tableTitles[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
    
}

