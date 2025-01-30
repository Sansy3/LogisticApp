import FirebaseFirestore

protocol FirebaseManagerProtocol {
    func listenToDrivers(completion: @escaping (Result<[Driver], Error>) -> Void) -> ListenerRegistration
    func addLoadToFirestore(loadItem: LoadItem, completion: @escaping (Bool) -> Void)
    func assignDriverToLoad(loadId: String, driverId: String)
    func fetchAllLoads(completion: @escaping (Result<[FirestoreLoadItem], Error>) -> Void) // Fetch all loads
    func listenToLoadChanges(completion: @escaping (Result<[FirestoreLoadItem], Error>) -> Void) -> ListenerRegistration // Listen to load changes
}

class FirebaseManager: FirebaseManagerProtocol {
    
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {}

    // MARK: - Add Load to Firestore with completion handler
    func addLoadToFirestore(loadItem: LoadItem, completion: @escaping (Bool) -> Void) {
        let loadRef = db.collection("loads").document(loadItem.id)
        
        let loadData: [String: Any] = [
            "origin": loadItem.origin,
            "destination": loadItem.destination,
            "weight": loadItem.weight,
            "status": loadItem.status,
            "truckType": loadItem.truckType,
            "pickupDate": loadItem.pickupDate,
            "deliveryDate": loadItem.deliveryDate
        ]
        
        loadRef.setData(loadData) { error in
            if let error = error {
                print("Error adding load to Firestore: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Load successfully added to Firestore!")
                completion(true)
            }
        }
    }
    
    // MARK: - Fetch All Loads from Firestore
    func fetchAllLoads(completion: @escaping (Result<[FirestoreLoadItem], Error>) -> Void) {
        db.collection("loads")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching loads: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No loads found")
                    completion(.failure(AppError.networkError))
                    return
                }
                
                // Decode documents as FirestoreLoadItem
                let firestoreLoads = documents.compactMap { doc -> FirestoreLoadItem? in
                    do {
                        let load = try doc.data(as: FirestoreLoadItem.self)
                        return load
                    } catch {
                        print("Error decoding load document: \(doc.documentID), \(error)")
                        return nil
                    }
                }
                
                completion(.success(firestoreLoads))
            }
    }

    // MARK: - Assign Driver to Load
    func assignDriverToLoad(loadId: String, driverId: String) {
        let loadRef = db.collection("loads").document(loadId)
        
        // Check if the document exists first
        loadRef.getDocument { document, error in
            if let error = error {
                print("Error fetching load document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                // Document exists, update the data
                loadRef.updateData(["assignedDriverId": driverId]) { error in
                    if let error = error {
                        print("Error assigning driver: \(error.localizedDescription)")
                    } else {
                        print("Driver successfully assigned to load!")
                    }
                }
            } else {
                print("No document found with the specified load ID: \(loadId)")
            }
        }
    }

    // MARK: - Listen to Drivers in Firestore
    func listenToDrivers(completion: @escaping (Result<[Driver], Error>) -> Void) -> ListenerRegistration {
        return db.collection("users")  // Assuming drivers are stored as "users" with role = "Driver"
            .whereField("role", isEqualTo: "Driver")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Firebase Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("Firebase: No documents found")
                    completion(.failure(AppError.networkError))
                    return
                }
                
                let drivers = documents.compactMap { doc -> Driver? in
                    let data = doc.data()
                    
                    guard let email = data["email"] as? String,
                          let name = data["name"] as? String,
                          let role = data["role"] as? String,
                          role == "Driver",
                          let truckDetails = data["truckDetails"] as? [String: Any],
                          let dimensions = truckDetails["dimensions"] as? [String: Any],
                          let payload = truckDetails["payload"] as? Int,
                          let type = truckDetails["type"] as? String else {
                        print("Failed to parse driver document: \(doc.documentID)")
                        return nil
                    }
                    
                    // Split the full name into first and last name
                    let nameParts = name.components(separatedBy: " ")
                    let firstName = nameParts.first ?? ""
                    let lastName = nameParts.dropFirst().joined(separator: " ")
                    
                    let truckDimensions = TruckDimensions(
                        doorHeight: dimensions["doorHeight"] as? Int ?? 0,
                        doorWidth: dimensions["doorWidth"] as? Int ?? 0,
                        height: dimensions["height"] as? Int ?? 0,
                        length: dimensions["length"] as? Int ?? 0,
                        width: dimensions["width"] as? Int ?? 0
                    )
                    
                    return Driver(
                        id: doc.documentID,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        truckType: type,
                        truckDimensions: truckDimensions,
                        payload: payload
                    )
                }
                
                print("Parsed \(drivers.count) drivers successfully")
                completion(.success(drivers))
            }
    }

    // MARK: - Listen to Load Changes in Firestore (Real-time updates)
    func listenToLoadChanges(completion: @escaping (Result<[FirestoreLoadItem], Error>) -> Void) -> ListenerRegistration {
        return db.collection("loads")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to load changes: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    completion(.failure(AppError.networkError))
                    return
                }
                
                // Decode documents as FirestoreLoadItem
                let firestoreLoads = documents.compactMap { doc -> FirestoreLoadItem? in
                    do {
                        let load = try doc.data(as: FirestoreLoadItem.self)
                        return load
                    } catch {
                        print("Error decoding load document: \(doc.documentID), \(error)")
                        return nil
                    }
                }
                
                completion(.success(firestoreLoads))
            }
    }
}
