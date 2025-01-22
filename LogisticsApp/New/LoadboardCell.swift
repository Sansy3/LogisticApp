import UIKit

class LoadboardCell: UITableViewCell {
    static let identifier = "LoadboardCell"

    private let containerView = UIView()
    private let companyLabel = UILabel()
    private let routeLabel = UILabel()
    private let statusLabel = UILabel()
    private let truckTypeLabel = UILabel()
    private let truckTypeImageView = UIImageView()  // New Image View

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        containerView.backgroundColor = UIColor(named: "deepBlue")  // Using asset color
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 5
        containerView.translatesAutoresizingMaskIntoConstraints = false

        companyLabel.font = .boldSystemFont(ofSize: 16)
        companyLabel.textColor = UIColor(named: "SofGreen")  // Using asset color

        routeLabel.font = .systemFont(ofSize: 14)
        routeLabel.textColor = UIColor(named: "SofGreen")  // Using asset color

        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = UIColor(named: "SofGreen")  // Using asset color

        truckTypeLabel.font = .systemFont(ofSize: 14)
        truckTypeLabel.textColor = UIColor(named: "SofGreen")  // Using asset color

        // Configuring truckTypeImageView
        truckTypeImageView.contentMode = .scaleAspectFit
        truckTypeImageView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [companyLabel, routeLabel, statusLabel, truckTypeLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(stackView)
        containerView.addSubview(truckTypeImageView)  // Adding Image View

        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: truckTypeImageView.leadingAnchor, constant: -8),

            truckTypeImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            truckTypeImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            truckTypeImageView.widthAnchor.constraint(equalToConstant: 40),
            truckTypeImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func configure(with item: LoadItem) {
        companyLabel.text = "Load ID: \(item.id)"
        routeLabel.text = "\(item.origin) → \(item.destination)"
        statusLabel.text = item.status.uppercased()
        truckTypeLabel.text = "Truck Type: \(item.truckType)"

        // Set image based on truckType
        let imageName: String
        switch item.truckType {
        case "Small Straight":
            imageName = "small_straight"
        case "Large Straight":
            imageName = "large_straight"
        case "Van":
            imageName = "van"
        case "Cargo VAN":
            imageName = "cargo_van"
        case "Trackor":
            imageName = "tractor"
        default:
            imageName = "default_image"  // Provide a default image
        }
        truckTypeImageView.image = UIImage(named: imageName)
    }
}
