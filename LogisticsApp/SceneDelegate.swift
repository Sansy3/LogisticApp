import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            
            // Listen for authentication state changes using Firebase
            Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    // User is signed in, show the main app screen
                    self.window?.rootViewController = CustomTabBarController()  // Your main screen
                } else {
                    // User is not signed in, show the sign-in screen
                    self.window?.rootViewController = SignInViewController()  // Your sign-in screen
                }
            }
            
            window?.makeKeyAndVisible()
        }
    }
}
