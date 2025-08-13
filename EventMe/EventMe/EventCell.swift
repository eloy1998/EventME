
import UIKit

final class EventCell: UITableViewCell {
    static let reuseID = "EventCell"

    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.layer.cornerCurve = .continuous
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.accessibilityIgnoresInvertColors = true
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        // Dynamic color so it looks good in Light/Dark Mode
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Heart button to Save/Unsave (favorite)
    private let favoriteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "heart"), for: .normal)
        b.tintColor = .systemPink
        b.translatesAutoresizingMaskIntoConstraints = false
        b.accessibilityLabel = "Save event"
        return b
    }()

    private var currentEvent: Event?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        currentEvent = nil
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.accessibilityValue = "Not saved"
    }

    func set(event: Event) {
        currentEvent = event
        thumbnailImageView.image = UIImage(named: event.imageName)
        titleLabel.text = event.title
        let df = DateFormatter(); df.dateStyle = .short; df.timeStyle = .short
        dateLabel.text = df.string(from: event.date)

        // Accessibility
        accessibilityLabel = "Event: \(event.title). Starts \(dateLabel.text ?? "soon")."
        accessibilityTraits.insert(.button)

        updateFavoriteIcon()
    }

    private func configure() {
        // Selected background for better tap feedback (dynamic color)
        let sbg = UIView()
        sbg.backgroundColor = .tertiarySystemFill
        selectedBackgroundView = sbg

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 60),

            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -12),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -12),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }

    private func updateFavoriteIcon() {
        guard let event = currentEvent else { return }
        let saved = ReservationManager.shared.isSaved(event)
        let imageName = saved ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.accessibilityValue = saved ? "Saved" : "Not saved"
        favoriteButton.accessibilityHint = saved ? "Double tap to unsave" : "Double tap to save"
    }

    @objc private func favoriteTapped() {
        guard let event = currentEvent else { return }
        ReservationManager.shared.toggleSave(event)
        updateFavoriteIcon()
        // Let lists observing `eventsUpdated` refresh if needed
        NotificationCenter.default.post(name: Notification.Name("eventsUpdated"), object: nil)
    }
}
