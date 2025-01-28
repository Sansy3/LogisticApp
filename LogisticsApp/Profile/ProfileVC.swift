import GoogleSignIn
import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountViewController: UIViewController {
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let signOutButton = UIButton(type: .system)
    private let db = Firestore.firestore() // Firestore reference

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        title = "Account"

        setupUI()
        populateProfileInfo()
    }

    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
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

            signOutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.widthAnchor.constraint(equalToConstant: 140),
            signOutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func populateProfileInfo() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            // Google Sign-In user
            nameLabel.text = user.profile?.name
            emailLabel.text = user.profile?.email
            if let imageURL = user.profile?.imageURL(withDimension: 100) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: imageURL) {
                        DispatchQueue.main.async {
                            self.profileImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        } else if let userId = Auth.auth().currentUser?.uid {
            // Firebase authenticated user
            db.collection("users").document(userId).getDocument { [weak self] document, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    self?.nameLabel.text = data?["name"] as? String ?? "Unknown Name"
                    self?.emailLabel.text = data?["email"] as? String ?? "Unknown Email"
                    if let imageURL = data?["profileImageURL"] as? String, let url = URL(string: imageURL) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                    self?.profileImageView.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                } else {
                    print("No user data found")
                }
            }
        } else {
            // Default case (not signed in)
            nameLabel.text = "Not Logged In"
            emailLabel.text = ""
            profileImageView.image = UIImage(named: "gogona")
            profileImageView.tintColor = .white
        }
    }

    @objc private func signOutTapped() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = SignInViewController()
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
