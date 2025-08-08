import UIKit

class EventDetailViewController: UIViewController {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        setData()
    }

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
        dateLabel.textColor = .gray
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
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        dateLabel.text = df.string(from: event.date)
        descriptionLabel.text = event.description
    }

    @objc private func reserveTapped() {
        ReservationManager.shared.reserve(event)
        let alert = UIAlertController(
            title: "Reserved!",
            message: "Your spot for \(event.title) is confirmed.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
