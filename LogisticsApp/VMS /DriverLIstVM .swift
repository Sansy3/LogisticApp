import Foundation

class DriverViewModel {
    private(set) var drivers: [Driver] = DriverData.dummyDrivers
    
    func getDrivers() -> [Driver] {
        return drivers
    }
    
    private var selectedDriver: Driver?
    
    func selectDriver(_ driver: Driver) {
        selectedDriver = driver
    }
    
    func getSelectedDriver() -> Driver? {
        return selectedDriver
    }
}
