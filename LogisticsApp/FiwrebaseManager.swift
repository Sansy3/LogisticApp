import FirebaseFirestore

protocol FirebaseManagerProtocol {
    func listenToDrivers(completion: @escaping (Result<[Driver], Error>) -> Void) -> ListenerRegistration
}
class FirebaseManager: FirebaseManagerProtocol {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func listenToDrivers(completion: @escaping (Result<[Driver], Error>) -> Void) -> ListenerRegistration {
        return db.collection("users")  // Changed from "drivers" to "users"
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
}
