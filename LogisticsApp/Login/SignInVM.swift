//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//import Combine
//
//class AccountViewModel {
//    let db = Firestore.firestore()
//
//    // Observable properties
//    @Published var name: String = "Not Logged In"
//    @Published var email: String = ""
//    @Published var profileImage: UIImage? = UIImage(systemName: "person.circle")
//    @Published var isSignedIn: Bool = false
//
//    func fetchProfileInfo() {
//        if let user = Auth.auth().currentUser {
//            // Firebase authenticated user
//            name = user.displayName ?? "Unknown Name"
//            email = user.email ?? "Unknown Email"
//            // Fetching profile image if saved in Firestore
//            if let imageURL = user.photoURL {
//                loadImage(from: imageURL)
//            }
//            isSignedIn = true
//        } else {
//            // Default case (not signed in)
//            name = "Not Logged In"
//            email = ""
//            profileImage = UIImage(systemName: "person.circle")
//            isSignedIn = false
//        }
//    }
//
//    func signOut(completion: @escaping (Error?) -> Void) {
//        do {
//            try Auth.auth().signOut()
//            isSignedIn = false
//            completion(nil)
//        } catch let error {
//            completion(error)
//        }
//    }
//
//    private func loadImage(from url: URL) {
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url) {
//                let image = UIImage(data: data)
//                DispatchQueue.main.async {
//                    self?.profileImage = image
//                }
//            }
//        }
//    }
//}
