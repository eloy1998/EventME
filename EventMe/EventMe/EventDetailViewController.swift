import UIKit
import UserNotifications

final class EventDetailViewController: UIViewController {
    var event: Event!

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let hostLabel = UILabel()
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let reserveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reserve Spot", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Nav Items (Favorite + Theme)
    private lazy var favoriteButton: UIBarButtonItem = {
        let imgName = ReservationManager.shared.isSaved(event) ? "heart.fill" : "heart"
        return UIBarButtonItem(image: UIImage(systemName: imgName), style: .plain, target: self, action: #selector(toggleFavorite))
    }()

    private lazy var themeToggleButton: UIBarButtonItem = {
        let img = UIImage(systemName: isDarkModeEnabled ? "sun.max" : "moon")
        return UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(toggleDarkMode))
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItems = [favoriteButton, themeToggleButton]
        configureUI()
        setData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteIcon()
        updateThemeIcon()
    }

    // MARK: - UI Setup
    private func configureUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        hostLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(hostLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(reserveButton)

        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // ContentView constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // ImageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])

        // TitleLabel
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // HostLabel
        hostLabel.font = .systemFont(ofSize: 16)
        NSLayoutConstraint.activate([
            hostLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            hostLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            hostLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])

        // DateLabel
        dateLabel.font = .systemFont(ofSize: 16)
        dateLabel.textColor = .secondaryLabel
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: hostLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])

        // DescriptionLabel
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])

        // ReserveButton
        NSLayoutConstraint.activate([
            reserveButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            reserveButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            reserveButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            reserveButton.heightAnchor.constraint(equalToConstant: 50),
            reserveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        reserveButton.addTarget(self, action: #selector(reserveTapped), for: .touchUpInside)
    }

    private func setData() {
        imageView.image = UIImage(named: event.imageName)
        titleLabel.text = event.title
        hostLabel.text = "Host: \(event.host)"
        let df = DateFormatter(); df.dateStyle = .medium; df.timeStyle = .short
        dateLabel.text = df.string(from: event.date)
        descriptionLabel.text = event.description
    }

    // MARK: - Reserve & Notifications
    @objc private func reserveTapped() {
        ReservationManager.shared.reserve(event)
        NotificationManager.shared.scheduleReminder(for: event, minutesBefore: 30)
        let alert = UIAlertController(
            title: "Reserved!",
            message: "Your spot for \(event.title) is confirmed. We'll remind you 30 minutes before it starts.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Favorites (UserDefaults-based)
    @objc private func toggleFavorite() {
        ReservationManager.shared.toggleSave(event)
        updateFavoriteIcon()
    }

    private func updateFavoriteIcon() {
        favoriteButton.image = UIImage(systemName: ReservationManager.shared.isSaved(event) ? "heart.fill" : "heart")
    }

    // MARK: - Theme toggle (Dark/Light)
    private var isDarkModeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "EventME.isDarkMode") }
        set { UserDefaults.standard.set(newValue, forKey: "EventME.isDarkMode") }
    }

    @objc private func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        NotificationCenter.default.post(name: Notification.Name("themeChanged"), object: nil)
        updateThemeIcon()
    }

    private func updateThemeIcon() {
        themeToggleButton.image = UIImage(systemName: isDarkModeEnabled ? "sun.max" : "moon")
    }
}
