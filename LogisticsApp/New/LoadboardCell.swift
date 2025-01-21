import UIKit

class LoadboardCell: UITableViewCell {
    static let identifier = "LoadboardCell"

    private let containerView = UIView()
    private let companyLabel = UILabel()
    private let routeLabel = UILabel()
    private let priceLabel = UILabel()
    private let timeLabel = UILabel()
    private let distanceLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Card-style container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 5
        containerView.translatesAutoresizingMaskIntoConstraints = false

        companyLabel.font = .boldSystemFont(ofSize: 16)
        routeLabel.font = .systemFont(ofSize: 14)
        routeLabel.textColor = .secondaryLabel
        priceLabel.font = .boldSystemFont(ofSize: 18)
        priceLabel.textColor = .systemBlue
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
        distanceLabel.font = .systemFont(ofSize: 14)
        distanceLabel.textColor = .secondaryLabel

        let stackView = UIStackView(arrangedSubviews: [companyLabel, routeLabel, priceLabel, timeLabel, distanceLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(containerView)
        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with item: LoadItem) {
        companyLabel.text = item.company
        routeLabel.text = "\(item.origin) → \(item.destination)"
        priceLabel.text = item.price
        timeLabel.text = item.time
        distanceLabel.text = item.distance
    }
}
