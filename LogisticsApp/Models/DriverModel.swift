import Foundation

struct Driver: Equatable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let truckType: String
    let truckDimensions: TruckDimensions
    let payload: Int
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct TruckDimensions: Equatable {
    let doorHeight: Int
    let doorWidth: Int
    let height: Int
    let length: Int
    let width: Int
    
    var volumeInCubicMeters: Double {
        Double(length * width * height) / 1_000_000 // Convert from cubic cm to cubic meters
    }
}

enum AppError: LocalizedError {
    case networkError
    case parsingError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection error. Please check your internet connection."
        case .parsingError:
            return "Error processing data. Please try again."
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
}
