import Foundation
import FirebaseFirestore

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

protocol DriversViewModelProtocol: AnyObject {
    var drivers: [Driver] { get }
    var state: LoadingState { get }
    var onStateChanged: ((LoadingState) -> Void)? { get set }
    
    func listenToDrivers()
    func stopListening()
    func refreshData()
    func filterDrivers(searchText: String)
}

class DriversViewModel: DriversViewModelProtocol {
    private let firebaseManager: FirebaseManagerProtocol
    private var listener: ListenerRegistration?
    private var allDrivers: [Driver] = []
    
    private(set) var drivers: [Driver] = [] {
        didSet {
            if state != .loading {
                state = .loaded
            }
        }
    }
    
    private(set) var state: LoadingState = .idle {
        didSet {
            onStateChanged?(state)
        }
    }
    
    var onStateChanged: ((LoadingState) -> Void)?
    
    init(firebaseManager: FirebaseManagerProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    deinit {
        stopListening()
    }
    
    func listenToDrivers() {
        state = .loading
        
        listener = firebaseManager.listenToDrivers { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let drivers):
                self.allDrivers = drivers.sorted { $0.lastName < $1.lastName }
                self.drivers = self.allDrivers
                self.state = .loaded
                
            case .failure(let error):
                self.state = .error(error.localizedDescription)
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func refreshData() {
        stopListening()
        listenToDrivers()
    }
    
    func filterDrivers(searchText: String) {
        guard !searchText.isEmpty else {
            drivers = allDrivers
            return
        }
        
        drivers = allDrivers.filter {
            $0.fullName.lowercased().contains(searchText.lowercased()) ||
            $0.truckType.lowercased().contains(searchText.lowercased())
        }
    }
}
