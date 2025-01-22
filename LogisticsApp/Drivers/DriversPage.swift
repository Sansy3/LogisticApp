import UIKit
import FirebaseFirestore
import FirebaseAuth

class DriversPageViewController: UIViewController {
    
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let createdAtLabel = UILabel()
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchDriverInfo()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Driver Info"
        
        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emailLabel.font = .systemFont(ofSize: 18)
        emailLabel.textAlignment = .center
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        createdAtLabel.font = .systemFont(ofSize: 16)
        createdAtLabel.textAlignment = .center
        createdAtLabel.textColor = .gray
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(createdAtLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            createdAtLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            createdAtLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createdAtLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func fetchDriverInfo() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }
        
        db.collection("drivers").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching driver info: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found for this driver")
                return
            }
            
            let name = data["name"] as? String ?? "Unknown Name"
            let email = data["email"] as? String ?? "Unknown Email"
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            DispatchQueue.main.async {
                self?.nameLabel.text = "Name: \(name)"
                self?.emailLabel.text = "Email: \(email)"
                self?.createdAtLabel.text = "Joined: \(dateFormatter.string(from: createdAt))"
            }
        }
    }
}
