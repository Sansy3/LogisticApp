//
//  Loaditem.swift
//  LogisticsApp
//
//  Created by beqa on 21.01.25.
//

import SwiftUI
import UIKit
import CoreLocation

struct LoadItem {
    let company: String
    let origin: String
    let destination: String
    let distance: String
    let price: String
    let time: String
    
    let originCoordinate: CLLocationCoordinate2D
    let destinationCoordinate: CLLocationCoordinate2D
}
