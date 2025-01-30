////
////  AppError.swift
////  LogisticsApp
////
////  Created by beqa on 29.01.25.
////
//
//import Foundation
//
//enum AppError: LocalizedError {
//    case locationServiceDisabled
//    case locationPermissionDenied
//    case networkError
//    case databaseError(String)
//    
//    var errorDescription: String? {
//        switch self {
//        case .locationServiceDisabled:
//            return "Location services are disabled. Please enable them in Settings."
//        case .locationPermissionDenied:
//            return "Location permission denied. Please enable location access in Settings."
//        case .networkError:
//            return "Network connection error. Please check your internet connection."
//        case .databaseError(let message):
//            return "Database error: \(message)"
//        }
//    }
//}
//
//extension Notification.Name {
//    static let locationDidUpdate = Notification.Name("locationDidUpdate")
//    static let locationUpdateError = Notification.Name("locationUpdateError")
//}
