import UIKit

class LoadDetailViewController: UIViewController {
    
    var loadItem: LoadItem
    
    init(loadItem: LoadItem) {
        self.loadItem = loadItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Load Details"
        
        setupUI()
    }
    
    private func setupUI() {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = """
        Origin: \(loadItem.origin)
        Destination: \(loadItem.destination)
        Status: \(loadItem.status)
        Weight: \(loadItem.weight) lbs
        Pickup Date: \(loadItem.pickupDate)
        Delivery Date: \(loadItem.deliveryDate)
        Truck Type: \(loadItem.truckType)
        """
        label.frame = CGRect(x: 20, y: 80, width: view.frame.width - 40, height: 200)
        view.addSubview(label)
    }
}
