import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let nameTextField = UITextField()
    let roleSegmentedControl = UISegmentedControl(items: ["Driver", "Dispatcher"])
    let actionButton = UIButton(type: .system)
    let toggleButton = UIButton(type: .system)
    
    var isSignUpMode = false
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        // Setup name text field (only visible during sign-up)
        nameTextField.frame = CGRect(x: 50, y: 140, width: 300, height: 40)
        nameTextField.placeholder = "Enter name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.isHidden = true
        view.addSubview(nameTextField)
        
        // Setup email text field
        emailTextField.frame = CGRect(x: 50, y: 200, width: 300, height: 40)
        emailTextField.placeholder = "Enter email"
        emailTextField.borderStyle = .roundedRect
        view.addSubview(emailTextField)
        
        // Setup password text field
        passwordTextField.frame = CGRect(x: 50, y: 260, width: 300, height: 40)
        passwordTextField.placeholder = "Enter password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        view.addSubview(passwordTextField)
        
        // Setup role selection (only visible during sign-up)
        roleSegmentedControl.frame = CGRect(x: 50, y: 320, width: 300, height: 40)
        roleSegmentedControl.selectedSegmentIndex = 0 // Default to "Driver"
        roleSegmentedControl.isHidden = true
        view.addSubview(roleSegmentedControl)
        
        // Setup action button
        actionButton.frame = CGRect(x: 50, y: 380, width: 300, height: 40)
        actionButton.setTitle(isSignUpMode ? "Sign Up" : "Sign In", for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        view.addSubview(actionButton)
        
        // Setup toggle button
        toggleButton.frame = CGRect(x: 50, y: 440, width: 300, height: 40)
        toggleButton.setTitle(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up", for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
        view.addSubview(toggleButton)
    }
    
    @objc func actionButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            print("Please enter email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            print("Please enter password")
            return
        }
        
        if isSignUpMode {
            guard let name = nameTextField.text, !name.isEmpty else {
                print("Please enter your name")
                return
            }
            
            let selectedRole = roleSegmentedControl.selectedSegmentIndex == 0 ? "Driver" : "Dispatcher"
            
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                if let error = error {
                    print("Error signing up: \(error.localizedDescription)")
                    return
                }
                
                guard let userId = result?.user.uid else { return }
                
                // Save user profile to Firestore with the selected role
                self?.db.collection("users").document(userId).setData([
                    "name": name,
                    "email": email,
                    "role": selectedRole, // Assigned role based on user's choice
                    "createdAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("Error saving user to Firestore: \(error.localizedDescription)")
                    } else {
                        print("User profile saved successfully. Please sign in.")
                        
                        // Sign out the user after sign-up
                        do {
                            try Auth.auth().signOut()
                            print("Signed out after sign-up. Please log in.")
                        } catch let signOutError as NSError {
                            print("Error signing out: \(signOutError.localizedDescription)")
                        }
                    }
                }
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }
                
                // Firebase will listen to the sign-in state, and in `SceneDelegate`, we will handle the root view controller change based on the user's role.
                print("Successfully signed in. The root view controller will be handled by SceneDelegate.")
            }
        }
    }
    
    @objc func toggleButtonTapped() {
        isSignUpMode.toggle()
        actionButton.setTitle(isSignUpMode ? "Sign Up" : "Sign In", for: .normal)
        toggleButton.setTitle(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up", for: .normal)
        nameTextField.isHidden = !isSignUpMode
        roleSegmentedControl.isHidden = !isSignUpMode
    }
}
