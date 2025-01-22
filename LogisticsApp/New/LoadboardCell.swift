import UIKit

class LoadboardCell: UITableViewCell {
    static let identifier = "LoadboardCell"

    private let containerView = UIView()
    private let companyLabel = UILabel()
    private let routeLabel = UILabel()
    private let statusLabel = UILabel()
    private let truckTypeLabel = UILabel()
    private let truckImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 5
        containerView.translatesAutoresizingMaskIntoConstraints = false

        companyLabel.font = .boldSystemFont(ofSize: 16)
        companyLabel.textColor = .label

        routeLabel.font = .systemFont(ofSize: 14)
        routeLabel.textColor = .secondaryLabel

        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .systemBlue

        truckTypeLabel.font = .systemFont(ofSize: 14)
        truckTypeLabel.textColor = .secondaryLabel

        truckImageView.contentMode = .scaleAspectFit
        truckImageView.translatesAutoresizingMaskIntoConstraints = false
        truckImageView.layer.cornerRadius = 10

        let stackView = UIStackView(arrangedSubviews: [companyLabel, routeLabel, statusLabel, truckTypeLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(truckImageView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            truckImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            truckImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            truckImageView.widthAnchor.constraint(equalToConstant: 60),
            truckImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func configure(with item: LoadItem) {
        companyLabel.text = "Load ID: \(item.id)"
        routeLabel.text = "\(item.origin) → \(item.destination)"
        statusLabel.text = item.status.uppercased()
        truckTypeLabel.text = "Truck Type: \(item.truckType)"
        
        // Assign appropriate image based on TruckType
        let truckType = item.truckType.lowercased()
        let imageName: String

        switch truckType {
        case "small straight":
            imageName = "small_straight_icon"
        case "large straight":
            imageName = "large_straight_icon"
        case "van":
            imageName = "van_icon"
        case "cargo van":
            imageName = "cargo_van_icon"
        case "tractor":
            imageName = "tractor_icon"
        default:
            imageName = "default_icon"
        }

        truckImageView.image = UIImage(named: imageName)
    }
}


