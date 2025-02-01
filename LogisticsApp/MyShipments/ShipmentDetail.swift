import UIKit
import FirebaseFirestore

class ShipmentDetailViewController: UIViewController {
    // MARK: - Properties
    var shipment: FirestoreLoadItem?
    let db = Firestore.firestore()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    // Location Section
    private let locationSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private func createInfoView(title: String, icon: UIImage? = nil) -> (container: UIView, valueLabel: UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        
        if let icon = icon {
            let iconView = UIImageView(image: icon)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = .systemBlue
            NSLayoutConstraint.activate([
                iconView.widthAnchor.constraint(equalToConstant: 24),
                iconView.heightAnchor.constraint(equalToConstant: 24)
            ])
            stackView.addArrangedSubview(iconView)
        }
        
        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(valueLabel)
        
        stackView.addArrangedSubview(textStack)
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        return (container, valueLabel)
    }
    
    // MARK: - Info Views
    private lazy var originView = createInfoView(title: "Origin", icon: UIImage(systemName: "location.circle.fill"))
    private lazy var destinationView = createInfoView(title: "Destination", icon: UIImage(systemName: "location.circle"))
    private lazy var weightView = createInfoView(title: "Weight", icon: UIImage(systemName: "scalemass.fill"))
    private lazy var statusView = createInfoView(title: "Status", icon: UIImage(systemName: "info.circle.fill"))
    private lazy var pickupDateView = createInfoView(title: "Pickup Date", icon: UIImage(systemName: "calendar"))
    private lazy var deliveryDateView = createInfoView(title: "Delivery Date", icon: UIImage(systemName: "calendar.badge.clock"))
    private lazy var driverView = createInfoView(title: "Driver", icon: UIImage(systemName: "person.fill"))
    private lazy var truckView = createInfoView(title: "Truck Type", icon: UIImage(systemName: "truck.box.fill"))
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureViews()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Shipment Details"
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(cardView)
        
        // Add all info views to card
        let stackView = UIStackView(arrangedSubviews: [
            originView.container,
            destinationView.container,
            createSeparator(),
            weightView.container,
            statusView.container,
            createSeparator(),
            pickupDateView.container,
            deliveryDateView.container,
            createSeparator(),
            driverView.container,
            truckView.container
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        cardView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            cardView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private func configureViews() {
        guard let shipment = shipment else { return }
        
        originView.valueLabel.text = shipment.origin
        destinationView.valueLabel.text = shipment.destination
        weightView.valueLabel.text = "\(shipment.weight) lbs"
        statusView.valueLabel.text = shipment.status
        pickupDateView.valueLabel.text = shipment.pickupDate
        deliveryDateView.valueLabel.text = shipment.deliveryDate
        
        if let assignedDriverId = shipment.assignedDriverId {
            fetchDriverDetails(for: assignedDriverId)
        } else {
            driverView.valueLabel.text = "Not Assigned"
            truckView.valueLabel.text = "N/A"
        }
    }
    
    private func fetchDriverDetails(for driverId: String) {
        db.collection("users").document(driverId).getDocument { [weak self] (snapshot: DocumentSnapshot?, error: Error?) in
            if let error = error {
                print("Error fetching driver details: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                DispatchQueue.main.async {
                    self?.driverView.valueLabel.text = "Unknown"
                    self?.truckView.valueLabel.text = "N/A"
                }
                return
            }
            
            let driverName = data["name"] as? String ?? "Unknown"
            let truckType = (data["truckDetails"] as? [String: Any])?["type"] as? String ?? "N/A"
            
            DispatchQueue.main.async {
                self?.driverView.valueLabel.text = driverName
                self?.truckView.valueLabel.text = truckType
            }
        }
    }}
