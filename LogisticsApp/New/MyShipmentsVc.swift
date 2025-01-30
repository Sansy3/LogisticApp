import UIKit
import FirebaseFirestore

class MyShipmentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var shipments: [FirestoreLoadItem] = []
    private let tableView = UITableView()
    private var loadListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the UI
        title = "My Shipments"
        view.backgroundColor = .systemBackground
        
        // Table view setup
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ShipmentCell")
        view.addSubview(tableView)
        
        // Fetch loads from Firebase and listen for real-time updates
        fetchShipments()
        listenForLoadChanges()
    }
    
    func fetchShipments() {
        FirebaseManager.shared.fetchAllLoads { [weak self] result in
            switch result {
            case .success(let loads):
                self?.shipments = loads
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching shipments: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Listen for Load Changes (real-time)
    func listenForLoadChanges() {
        loadListener = FirebaseManager.shared.listenToLoadChanges { [weak self] result in
            switch result {
            case .success(let loads):
                self?.shipments = loads
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error listening to load changes: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shipments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShipmentCell", for: indexPath)
        let shipment = shipments[indexPath.row]
        cell.textLabel?.text = "\(shipment.origin) -> \(shipment.destination)"
        return cell
    }
}
