import UIKit
import FirebaseFirestore

class MyShipmentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    private var shipments: [FirestoreLoadItem] = []
    private var loadListener: ListenerRegistration?
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.backgroundColor = .systemGroupedBackground
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        return table
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        imageView.image = UIImage(systemName: "shippingbox")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        )
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Shipments Yet"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .systemBlue
        return refresh
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTableView()
        fetchShipments()
        listenForLoadChanges()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImage)
        emptyStateView.addSubview(emptyStateLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            emptyStateImage.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImage.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImage.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImage.widthAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImage.bottomAnchor, constant: 16),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "My Shipments"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Shipments"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ShipmentTableViewCell.self, forCellReuseIdentifier: "ShipmentCell")
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc private func refreshData() {
        fetchShipments()
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !shipments.isEmpty
        tableView.isHidden = shipments.isEmpty
    }
    
    // MARK: - Data Fetching
    func fetchShipments() {
        activityIndicator.startAnimating()
        FirebaseManager.shared.fetchAllLoads { [weak self] result in
            self?.activityIndicator.stopAnimating()
            self?.refreshControl.endRefreshing()
            
            switch result {
            case .success(let loads):
                self?.shipments = loads
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.updateEmptyState()
                }
            case .failure(let error):
                print("Error fetching shipments: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showErrorAlert(message: "Unable to load shipments. Please try again.")
                }
            }
        }
    }
    
    func listenForLoadChanges() {
        loadListener = FirebaseManager.shared.listenToLoadChanges { [weak self] result in
            switch result {
            case .success(let loads):
                self?.shipments = loads
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.updateEmptyState()
                }
            case .failure(let error):
                print("Error listening to load changes: \(error.localizedDescription)")
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - TableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shipments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShipmentCell", for: indexPath) as! ShipmentTableViewCell
        let shipment = shipments[indexPath.row]
        cell.configure(with: shipment)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedShipment = shipments[indexPath.row]
        let detailVC = ShipmentDetailViewController()
        detailVC.shipment = selectedShipment
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
