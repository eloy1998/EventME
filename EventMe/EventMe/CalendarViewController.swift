import UIKit

class CalendarViewController: UIViewController {
    let tableView = UITableView()
    var eventsByDate: [String: [Event]] = [:]
    var sortedDates: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTableView()
        groupEvents()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func groupEvents() {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none

        for event in EventService.shared.events {
            let dateKey = df.string(from: event.date)
            eventsByDate[dateKey, default: []].append(event)
        }
        sortedDates = eventsByDate.keys.sorted {
            guard let d1 = df.date(from: $0), let d2 = df.date(from: $1) else { return false }
            return d1 < d2
        }
        tableView.reloadData()
    }
}

extension CalendarViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDates.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedDates[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sortedDates[section]
        return eventsByDate[key]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let key = sortedDates[indexPath.section]
        if let event = eventsByDate[key]?[indexPath.row] {
            cell.textLabel?.text = event.title
        }
        return cell
    }
}
