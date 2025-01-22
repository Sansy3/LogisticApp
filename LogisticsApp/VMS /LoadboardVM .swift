import Foundation

class LoadboardViewModel {
    var loadItems: [LoadItem] = [] {
        didSet {
            reloadData?()
        }
    }
    var reloadData: (() -> Void)?
    private let networkManager = NetworkManager()
    
    func fetchLoadData() {
        networkManager.fetchLoadData { [weak self] items in
            self?.loadItems = items
        }
    }
    
}
