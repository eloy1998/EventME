import UIKit
import UserNotifications

class EventListViewController: UIViewController {
    private let tableView = UITableView()
    private let service = EventService.shared
    private var displayedEvents: [Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Events"
        view.backgroundColor = .systemBackground

        displayedEvents = service.events
        configureTableView()
        configureSearchController()
        configureThemeToggle()

        NotificationCenter.default.addObserver(self, selector: #selector(eventsDidUpdate), name: Notification.Name("eventsUpdated"), object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EventCell.self, forCellReuseIdentifier: EventCell.reuseID)
    }

    private func configureSearchController() {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search Events"
        navigationItem.searchController = sc
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func configureThemeToggle() {
        let button = UIBarButtonItem(image: UIImage(systemName: isDarkModeEnabled ? "sun.max" : "moon"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(toggleDarkMode))
        navigationItem.rightBarButtonItem = button
    }

    private var isDarkModeEnabled: Bool {
        UserDefaults.standard.bool(forKey: "EventME.isDarkMode")
    }

    private func updateThemeIcon() {
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: isDarkModeEnabled ? "sun.max" : "moon")
    }

    @objc private func toggleDarkMode() {
        let newValue = !isDarkModeEnabled
        UserDefaults.standard.set(newValue, forKey: "EventME.isDarkMode")
        NotificationCenter.default.post(name: Notification.Name("themeChanged"), object: nil)
        updateThemeIcon()
    }

    @objc private func eventsDidUpdate() {
        if navigationItem.searchController?.isActive == true {
            updateSearchResults(for: navigationItem.searchController!)
        } else {
            displayedEvents = service.events
            tableView.reloadData()
        }
    }

    /// Schedules a local notification 30 minutes before the event start.
    private func scheduleLocalReminder(for event: Event) {
        let fireDate = event.date.addingTimeInterval(-30 * 60)
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Event"
        let df = DateFormatter(); df.timeStyle = .short; df.dateStyle = .none
        content.body = "\(event.title) starts at \(df.string(from: event.date))."
        content.sound = .default

        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        comps.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let identifier = "event-\(event.title)-\(Int(event.date.timeIntervalSince1970))"
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req) { if let error = $0 { print("[Notifications] schedule error:", error) } }
    }
}

extension EventListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            displayedEvents = service.events
        } else {
            displayedEvents = service.events.filter { $0.title.lowercased().contains(text.lowercased()) }
        }
        tableView.reloadData()
    }
}

extension EventListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.reuseID, for: indexPath) as! EventCell
        cell.set(event: displayedEvents[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = displayedEvents[indexPath.row]
        let detailVC = EventDetailViewController()
        detailVC.event = event
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Swipe actions: Save/Unsave and Reserve
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let event = displayedEvents[indexPath.row]

        // Reserve action schedules notification 30 minutes before start
        let reserve = UIContextualAction(style: .normal, title: "Reserve") { [weak self] _, _, done in
            ReservationManager.shared.reserve(event)
            self?.scheduleLocalReminder(for: event)
            done(true)
        }
        reserve.backgroundColor = .systemBlue

        // Save / Unsave (favorite)
        let isSaved = ReservationManager.shared.isSaved(event)
        let save = UIContextualAction(style: .normal, title: isSaved ? "Unsave" : "Save") { _, _, done in
            ReservationManager.shared.toggleSave(event)
            done(true)
        }
        save.backgroundColor = isSaved ? .systemGray : .systemOrange

        return UISwipeActionsConfiguration(actions: [reserve, save])
    }
}
