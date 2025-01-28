import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let db = Firestore.firestore()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            
            // Listen for authentication state changes using Firebase
            Auth.auth().addStateDidChangeListener { [weak self] auth, user in
                if let user = user {
                    // User is signed in, fetch their role and navigate accordingly
                    self?.db.collection("users").document(user.uid).getDocument { document, error in
                        if let error = error {
                            print("Error fetching user role: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let data = document?.data(),
                              let role = data["role"] as? String else {
                            print("Error: Role not found for user")
                            return
                        }
                        
                        // Navigate based on the user's role
                        self?.navigateToDashboard(role: role)
                    }
                } else {
                    // User is not signed in, show the sign-in screen
                    self?.window?.rootViewController = SignInViewController()
                }
            }
            
            window?.makeKeyAndVisible()
        }
    }
    
    func navigateToDashboard(role: String) {
        let viewController: UIViewController
        
        if role.lowercased() == "dispatcher" {
            viewController = CustomTabBarController() // Dispatcher dashboard
        } else if role.lowercased() == "driver" {
            viewController = DriverTabBarController() // Driver dashboard
        } else {
            print("Unknown role: \(role), navigating to a default dashboard.")
            viewController = UIViewController() // Fallback for unknown roles
            viewController.view.backgroundColor = .white
            let label = UILabel()
            label.text = "Unknown role. Please contact support."
            label.textAlignment = .center
            label.frame = viewController.view.frame
            viewController.view.addSubview(label)
        }

        // Set the root view controller based on the role
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
    }
}
