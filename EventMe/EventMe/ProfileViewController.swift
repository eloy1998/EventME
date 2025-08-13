import UIKit

class ProfileViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private enum Section: Int, CaseIterable { case reserved, saved, appearance }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground
        configureTableView()

        // Refresh when reservations/saved change
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadData),
                                               name: .eventsUpdated,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    @objc private func reloadData() {
        tableView.reloadData()
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .reserved:   return ReservationManager.shared.reserved.count
        case .saved:      return ReservationManager.shared.saved.count
        case .appearance: return 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .reserved:   return "Upcoming Reservations"
        case .saved:      return "Saved Events"
        case .appearance: return "Appearance"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch Section(rawValue: indexPath.section)! {
        case .reserved:
            cell.textLabel?.text = ReservationManager.shared.reserved[indexPath.row].title
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.accessibilityTraits = .header
        case .saved:
            cell.textLabel?.text = ReservationManager.shared.saved[indexPath.row].title
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.accessibilityTraits = .header
        case .appearance:
            cell.textLabel?.text = "Dark Mode"
            let sw = UISwitch()
            sw.isOn = ThemeManager.shared.isDarkMode
            sw.addTarget(self, action: #selector(toggleDarkMode(_:)), for: .valueChanged)
            cell.accessoryView = sw
            cell.selectionStyle = .none
            cell.textLabel?.accessibilityLabel = "Toggle Dark Mode"
            sw.accessibilityLabel = "Dark Mode Switch"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section)! {
        case .reserved:
            let event = ReservationManager.shared.reserved[indexPath.row]
            let vc = EventDetailViewController()
            vc.event = event
            navigationController?.pushViewController(vc, animated: true)
        case .saved:
            let event = ReservationManager.shared.saved[indexPath.row]
            let vc = EventDetailViewController()
            vc.event = event
            navigationController?.pushViewController(vc, animated: true)
        case .appearance:
            break
        }
    }

    @objc private func toggleDarkMode(_ sender: UISwitch) {
        ThemeManager.shared.isDarkMode = sender.isOn
    }
}
