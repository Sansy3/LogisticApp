import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let roleLabel = UILabel()
    private let signOutButton = UIButton(type: .system)
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        populateProfileInfo()
    }

    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUI() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        emailLabel.font = .systemFont(ofSize: 16)
        emailLabel.textAlignment = .center
        emailLabel.textColor = .white.withAlphaComponent(0.8)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false

        roleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        roleLabel.textAlignment = .center
        roleLabel.textColor = .white.withAlphaComponent(0.8)
        roleLabel.translatesAutoresizingMaskIntoConstraints = false

        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.layer.cornerRadius = 20
        signOutButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        signOutButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(roleLabel)
        view.addSubview(signOutButton)

        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            roleLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            roleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            roleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            signOutButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 20),
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.widthAnchor.constraint(equalToConstant: 140),
            signOutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func populateProfileInfo() {
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("users").document(userId).getDocument { [weak self] document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    self?.nameLabel.text = data?["name"] as? String ?? "Unknown Name"
                    self?.emailLabel.text = data?["email"] as? String ?? "Unknown Email"
                    self?.roleLabel.text = "Role: \(data?["role"] as? String ?? "Unknown")"
                }
            }
        }
    }

    @objc private func signOutTapped() {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
