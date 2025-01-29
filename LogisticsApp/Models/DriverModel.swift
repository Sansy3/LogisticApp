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

import Foundation

enum AppError: LocalizedError {
    case locationServiceDisabled
    case locationPermissionDenied
    case networkError
    case parsingError
    case unknownError
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .locationServiceDisabled:
            return "Location services are disabled. Please enable them in Settings."
        case .locationPermissionDenied:
            return "Location permission denied. Please enable location access in Settings."
        case .networkError:
            return "Network connection error. Please check your internet connection."
        case .parsingError:
            return "Error processing data. Please try again."
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        case .databaseError(let message):
            return "Database error: \(message)"
        }
    }
}

extension Notification.Name {
    static let locationDidUpdate = Notification.Name("locationDidUpdate")
    static let locationUpdateError = Notification.Name("locationUpdateError")
}

