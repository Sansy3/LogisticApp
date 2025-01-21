import UIKit

class MyDriversVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var viewModel: MyDriversViewModel!
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Drivers"
        viewModel = MyDriversViewModel()
        setupTableView()
        bindViewModel()
        viewModel.loadDrivers()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDriver))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DriverCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    func bindViewModel() {
        viewModel.reloadData = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.drivers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell", for: indexPath)
        let driver = viewModel.drivers[indexPath.row]
        cell.textLabel?.text = "\(driver.firstName) \(driver.lastName) - \(driver.truckType)"
        return cell
    }
    
    
    @objc func addDriver() {
        
        let alert = UIAlertController(title: "Add Driver", message: "Enter driver details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "First Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Last Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Truck Type"
        }
        alert.addTextField { textField in
            textField.placeholder = "Latitude"
        }
        alert.addTextField { textField in
            textField.placeholder = "Longitude"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            if let firstName = alert.textFields?[0].text,
               let lastName = alert.textFields?[1].text,
               let truckType = alert.textFields?[2].text,
               let latitudeString = alert.textFields?[3].text,
               let longitudeString = alert.textFields?[4].text,
               let latitude = Double(latitudeString),
               let longitude = Double(longitudeString) {
                
                self.viewModel.addDriver(firstName: firstName, lastName: lastName, truckType: truckType, latitude: latitude, longitude: longitude)
            }
        }))
        
        present(alert, animated: true)
    }
}
