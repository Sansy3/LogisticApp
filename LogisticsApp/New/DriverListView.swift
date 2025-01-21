import UIKit

class DriverListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var driverViewModel = DriverViewModel()
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Drivers"
        
        tableView = UITableView(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DriverCell")
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return driverViewModel.getDrivers().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell", for: indexPath)
        let driver = driverViewModel.getDrivers()[indexPath.row]
        cell.textLabel?.text = "\(driver.firstName) \(driver.lastName) - \(driver.truckType)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDriver = driverViewModel.getDrivers()[indexPath.row]
        driverViewModel.selectDriver(selectedDriver)
        
        // Navigate to the MapVC
        let mapVC = MapVC()
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
}
