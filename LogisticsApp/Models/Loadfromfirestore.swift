//
//  Loadfromfirestore.swift
//  LogisticsApp
//
//  Created by beqa on 30.01.25.
//

import FirebaseFirestore


struct FirestoreLoadItem: Identifiable, Decodable {
    @DocumentID var id: String?  // Firestore document ID
    var assignedDriverId: String
    var deliveryDate: String
    var destination: String
    var origin: String
    var pickupDate: String
    var status: String
    var truckType: String
    var weight: Double
}

