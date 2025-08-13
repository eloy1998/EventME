import UIKit
import UserNotifications

class CalendarViewController: UIViewController {
    private let tableView = UITableView()

    // Master (all events), grouped by formatted date string
    private var eventsByDate: [String: [Event]] = [:]
    private var sortedDates: [String] = []

    // Filtered view when searching
    private var filteredByDate: [String: [Event]] = [:]
    private var filteredDates: [String] = []

    private lazy var dfDay: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        view.backgroundColor = .systemBackground

        configureTableView()
        configureSearch()
        configureThemeToggle()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(eventsDidUpdate),
                                               name: Notification.Name("eventsUpdated"),
                                               object: nil)

        group(events: EventService.shared.events)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI Setup
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func configureSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Events"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func configureThemeToggle() {
        let item = UIBarButtonItem(image: UIImage(systemName: isDarkModeEnabled ? "sun.max" : "moon"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(toggleDarkMode))
        navigationItem.rightBarButtonItem = item
    }

    // MARK: - Data Grouping
    private func group(events: [Event]) {
        var groups: [String: [Event]] = [:]
        for event in events {
            let key = dfDay.string(from: event.date)
            groups[key, default: []].append(event)
        }
        // Sort events within each day by time
        for key in groups.keys {
            groups[key]?.sort { $0.date < $1.date }
        }

        eventsByDate = groups
        sortedDates = groups.keys.sorted {
            guard let d1 = dfDay.date(from: $0), let d2 = dfDay.date(from: $1) else { return false }
            return d1 < d2
        }
        tableView.reloadData()
    }

    private func groupFiltered(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            filteredByDate = [:]; filteredDates = []
            tableView.reloadData(); return
        }
        let filtered = EventService.shared.events.filter { $0.matchesTitle(trimmed) }
        var groups: [String: [Event]] = [:]
        for e in filtered {
            let key = dfDay.string(from: e.date)
            groups[key, default: []].append(e)
        }
        for key in groups.keys { groups[key]?.sort { $0.date < $1.date } }
        filteredByDate = groups
        filteredDates = groups.keys.sorted {
            guard let d1 = dfDay.date(from: $0), let d2 = dfDay.date(from: $1) else { return false }
            return d1 < d2
        }
        tableView.reloadData()
    }

    private var isSearching: Bool {
        guard searchController.isActive else { return false }
        let text = searchController.searchBar.text ?? ""
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Theme
    private var isDarkModeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "EventME.isDarkMode") }
        set { UserDefaults.standard.set(newValue, forKey: "EventME.isDarkMode") }
    }

    @objc private func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: isDarkModeEnabled ? "sun.max" : "moon")
        NotificationCenter.default.post(name: Notification.Name("themeChanged"), object: nil)
    }

    // MARK: - Notifications & Updates
    @objc private func eventsDidUpdate() {
        if isSearching {
            groupFiltered(for: searchController.searchBar.text ?? "")
        } else {
            group(events: EventService.shared.events)
        }
    }

    private func scheduleLocalReminder(for event: Event) {
        guard let fireDate = event.reminderFireDate(minutesBefore: 30) else { return }
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Event"
        let df = DateFormatter(); df.timeStyle = .short; df.dateStyle = .none
        content.body = "\(event.title) starts at \(df.string(from: event.date))."
        content.sound = .default

        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        comps.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: event.notificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req) { if let error = $0 { print("[Notifications] schedule error:", error) } }
    }
}

// MARK: - Search
extension CalendarViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredByDate = [:]; filteredDates = []
            tableView.reloadData()
        } else {
            groupFiltered(for: text)
        }
    }
}

// MARK: - Table
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? filteredDates.count : sortedDates.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearching ? filteredDates[section] : sortedDates[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = isSearching ? filteredDates[section] : sortedDates[section]
        return (isSearching ? filteredByDate[key] : eventsByDate[key])?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let key = isSearching ? filteredDates[indexPath.section] : sortedDates[indexPath.section]
        if let event = (isSearching ? filteredByDate[key] : eventsByDate[key])?[indexPath.row] {
            cell.textLabel?.text = event.title
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let key = isSearching ? filteredDates[indexPath.section] : sortedDates[indexPath.section]
        guard let event = (isSearching ? filteredByDate[key] : eventsByDate[key])?[indexPath.row] else { return }
        let detail = EventDetailViewController(); detail.event = event
        navigationController?.pushViewController(detail, animated: true)
    }

    // Swipe actions: Reserve (schedules notification) and Save/Unsave
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let key = isSearching ? filteredDates[indexPath.section] : sortedDates[indexPath.section]
        guard let event = (isSearching ? filteredByDate[key] : eventsByDate[key])?[indexPath.row] else { return nil }

        let reserve = UIContextualAction(style: .normal, title: "Reserve") { [weak self] _, _, done in
            ReservationManager.shared.reserve(event)
            self?.scheduleLocalReminder(for: event)
            done(true)
        }
        reserve.backgroundColor = .systemBlue

        let isSaved = ReservationManager.shared.isSaved(event)
        let save = UIContextualAction(style: .normal, title: isSaved ? "Unsave" : "Save") { _, _, done in
            ReservationManager.shared.toggleSave(event)
            done(true)
        }
        save.backgroundColor = isSaved ? .systemGray : .systemOrange

        return UISwipeActionsConfiguration(actions: [reserve, save])
    }
}
