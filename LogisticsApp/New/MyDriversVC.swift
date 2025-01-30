import UIKit

class DriversViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: DriversViewModelProtocol
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGroupedBackground
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(DriverCell.self, forCellReuseIdentifier: DriverCell.identifier)
        table.refreshControl = UIRefreshControl()
        table.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No drivers found"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    init(viewModel: DriversViewModelProtocol = DriversViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        bindViewModel()
        viewModel.listenToDrivers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopListening()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "My Drivers"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        view.addSubview(loadingSpinner)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search drivers or truck types"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleState(state)
            }
        }
    }
    
    // MARK: - State Handling
    private func handleState(_ state: LoadingState) {
        switch state {
        case .idle:
            loadingSpinner.stopAnimating()
            
        case .loading:
            loadingSpinner.startAnimating()
            emptyStateLabel.isHidden = true
            tableView.refreshControl?.endRefreshing()
            
        case .loaded:
            loadingSpinner.stopAnimating()
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
            emptyStateLabel.isHidden = !viewModel.drivers.isEmpty
            
        case .error(let message):
            loadingSpinner.stopAnimating()
            tableView.refreshControl?.endRefreshing()
            showError(message)
        }
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        viewModel.refreshData()
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.refreshData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension DriversViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.drivers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DriverCell.identifier,
            for: indexPath
        ) as? DriverCell else {
            return UITableViewCell()
        }
        
        let driver = viewModel.drivers[indexPath.row]
        cell.configure(with: driver)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle driver selection - you can add navigation to driver details here
        let driver = viewModel.drivers[indexPath.row]
        // Example: navigationController?.pushViewController(DriverDetailsVC(driver: driver), animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension DriversViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.filterDrivers(searchText: searchText)
    }
}


