import UIKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Handle the redirect URL for Google Sign-In
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // Called when the app finishes launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Google Sign-In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "YOUR_OAUTH_CLIENT_ID") // Use the correct OAuth client ID

        // Restore the previous sign-in session if any
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                // Handle error if the user is not signed in
                print("Error restoring previous sign-in: \(error.localizedDescription)")
            } else {
                // User is signed in
                print("User is signed in: \(user?.profile?.name ?? "Unknown")")
            }
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    // Called when a new scene session is being created
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Use this method to select a configuration to create the new scene with
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // Called when the user discards a scene session
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Release any resources specific to the discarded scenes
    }
}
