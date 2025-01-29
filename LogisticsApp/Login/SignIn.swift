import UIKit
import FirebaseAuth
import FirebaseFirestore

enum TruckType: String, CaseIterable {
    case largeStraight = "Large Straight"
    case smallStraight = "Small Straight"
    case dryVan = "Dry Van"
    case sprinterVan = "Sprinter Van"
    case tractor = "Tractor"
}

class SignInViewController: UIViewController {
    // MARK: - UI Components
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "truck.box")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var nameField: StylizedTextField = {
        let field = StylizedTextField()
        field.setup(imageName: "person.fill", placeholder: "Full Name")
        return field
    }()
    
    private lazy var emailField: StylizedTextField = {
        let field = StylizedTextField()
        field.setup(imageName: "envelope.fill", placeholder: "Email Address")
        field.keyboardType = .emailAddress
        return field
    }()
    
    private lazy var passwordField: StylizedTextField = {
        let field = StylizedTextField()
        field.setup(imageName: "lock.fill", placeholder: "Password")
        field.isSecureTextEntry = true
        return field
    }()
    
    private lazy var roleControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Driver", "Dispatcher"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .tertiarySystemBackground
        control.selectedSegmentTintColor = .systemBlue
        control.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return control
    }()
    
    private lazy var truckDetailsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var truckDetailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let truckTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "SELECT TRUCK TYPE"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var truckTypePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private lazy var dimensionFields: [StylizedTextField] = {
        return [
            createDimensionField(placeholder: "Length (ft)", imageName: "arrow.left.and.right"),
            createDimensionField(placeholder: "Width (ft)", imageName: "arrow.up.and.down"),
            createDimensionField(placeholder: "Height (ft)", imageName: "arrow.up.and.down"),
            createDimensionField(placeholder: "Door Width (ft)", imageName: "arrow.left.and.right"),
            createDimensionField(placeholder: "Door Height (ft)", imageName: "arrow.up.and.down"),
            createDimensionField(placeholder: "Payload Capacity (lbs)", imageName: "weight")
        ]
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 25
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    private var isSignUpMode = false {
        didSet { updateUIForMode() }
    }
     let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupActions()
        updateUIForMode()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(containerView)
        
        [headerImageView, titleLabel, formStack, actionButton, toggleButton].forEach {
            containerView.addSubview($0)
        }
        
        [nameField, emailField, passwordField, roleControl, truckDetailsCard].forEach {
            formStack.addArrangedSubview($0)
        }
        
        truckDetailsCard.addSubview(truckDetailsStack)
        
        [truckTypeLabel, truckTypePicker].forEach {
            truckDetailsStack.addArrangedSubview($0)
        }
        
        dimensionFields.forEach { truckDetailsStack.addArrangedSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
            
            headerImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            headerImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 80),
            headerImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            formStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            formStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            formStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            truckDetailsStack.topAnchor.constraint(equalTo: truckDetailsCard.topAnchor),
            truckDetailsStack.leadingAnchor.constraint(equalTo: truckDetailsCard.leadingAnchor),
            truckDetailsStack.trailingAnchor.constraint(equalTo: truckDetailsCard.trailingAnchor),
            truckDetailsStack.bottomAnchor.constraint(equalTo: truckDetailsCard.bottomAnchor),
            
            actionButton.topAnchor.constraint(equalTo: formStack.bottomAnchor, constant: 30),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            toggleButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 16),
            toggleButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            toggleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            toggleButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])
        
        truckTypePicker.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    private func setupActions() {
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
        roleControl.addTarget(self, action: #selector(roleChanged), for: .valueChanged)
    }
    
    private func updateUIForMode() {
        titleLabel.text = isSignUpMode ? "Create Account" : "Welcome Back"
        actionButton.setTitle(isSignUpMode ? "Sign Up" : "Sign In", for: .normal)
        toggleButton.setTitle(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up", for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.nameField.isHidden = !self.isSignUpMode
            self.roleControl.isHidden = !self.isSignUpMode
            self.truckDetailsCard.isHidden = !(self.isSignUpMode && self.roleControl.selectedSegmentIndex == 0)
            self.view.layoutIfNeeded()
        }
    }
    
    private func createDimensionField(placeholder: String, imageName: String) -> StylizedTextField {
            let field = StylizedTextField()
            field.setup(imageName: imageName, placeholder: placeholder)
            field.keyboardType = .decimalPad
            return field
        }
        
        // MARK: - Action Methods
        @objc func roleChanged() {
            let isDriver = roleControl.selectedSegmentIndex == 0
            UIView.animate(withDuration: 0.3) {
                self.truckDetailsCard.isHidden = !isDriver
                self.view.layoutIfNeeded()
            }
        }
        
        @objc func actionButtonTapped() {
            guard let email = emailField.text, !email.isEmpty else {
                showAlert(message: "Please enter email")
                return
            }
            
            guard let password = passwordField.text, !password.isEmpty else {
                showAlert(message: "Please enter password")
                return
            }
            
            if isSignUpMode {
                guard let name = nameField.text, !name.isEmpty else {
                    showAlert(message: "Please enter your name")
                    return
                }
                
                let selectedRole = roleControl.selectedSegmentIndex == 0 ? "Driver" : "Dispatcher"
                
                // Validate truck details for drivers
                if selectedRole == "Driver" {
                    guard let length = Double(dimensionFields[0].text ?? ""),
                          let width = Double(dimensionFields[1].text ?? ""),
                          let height = Double(dimensionFields[2].text ?? ""),
                          let doorWidth = Double(dimensionFields[3].text ?? ""),
                          let doorHeight = Double(dimensionFields[4].text ?? ""),
                          let payload = Double(dimensionFields[5].text ?? "") else {
                        showAlert(message: "Please fill in all truck details with valid numbers")
                        return
                    }
                    
                    let selectedTruckType = TruckType.allCases[truckTypePicker.selectedRow(inComponent: 0)]
                    
                    Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                        if let error = error {
                            self?.showAlert(message: "Error signing up: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let userId = result?.user.uid else { return }
                        
                        // Save user profile with truck details
                        self?.db.collection("users").document(userId).setData([
                            "name": name,
                            "email": email,
                            "role": selectedRole,
                            "truckDetails": [
                                "type": selectedTruckType.rawValue,
                                "dimensions": [
                                    "length": length,
                                    "width": width,
                                    "height": height,
                                    "doorWidth": doorWidth,
                                    "doorHeight": doorHeight
                                ],
                                "payload": payload
                            ],
                            "createdAt": FieldValue.serverTimestamp()
                        ]) { [weak self] error in
                            if let error = error {
                                self?.showAlert(message: "Error saving user to Firestore: \(error.localizedDescription)")
                            } else {
                                self?.showAlert(message: "User profile saved successfully. Please sign in.") {
                                    // Sign out the user after sign-up
                                    try? Auth.auth().signOut()
                                    self?.toggleButtonTapped() // Switch back to sign in mode
                                }
                            }
                        }
                    }
                } else {
                    // For dispatcher role, create user without truck details
                    Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                        if let error = error {
                            self?.showAlert(message: "Error signing up: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let userId = result?.user.uid else { return }
                        
                        self?.db.collection("users").document(userId).setData([
                            "name": name,
                            "email": email,
                            "role": selectedRole,
                            "createdAt": FieldValue.serverTimestamp()
                        ]) { [weak self] error in
                            if let error = error {
                                self?.showAlert(message: "Error saving user to Firestore: \(error.localizedDescription)")
                            } else {
                                self?.showAlert(message: "User profile saved successfully. Please sign in.") {
                                    try? Auth.auth().signOut()
                                    self?.toggleButtonTapped()
                                }
                            }
                        }
                    }
                }
            } else {
                // Sign In mode
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                    if let error = error {
                        self?.showAlert(message: "Error signing in: \(error.localizedDescription)")
                        return
                    }
                    self?.showAlert(message: "Successfully signed in")
                }
            }
        }
        
        @objc func toggleButtonTapped() {
            isSignUpMode.toggle()
        }
        
        private func showAlert(message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            present(alert, animated: true)
        }
    }



// MARK: - StylizedTextField
class StylizedTextField: UITextField {
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .tertiarySystemBackground
        layer.cornerRadius = 12
        heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        // Text padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        leftView = paddingView
        leftViewMode = .always
        
        // Font styling
        font = .systemFont(ofSize: 16)
    }
    
    func setup(imageName: String, placeholder: String) {
        // Icon setup
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        iconImageView.image = UIImage(systemName: imageName)
        iconImageView.tintColor = .systemGray
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.frame = CGRect(x: 15, y: 15, width: 20, height: 20)
        iconContainer.addSubview(iconImageView)
        
        leftView = iconContainer
        self.placeholder = placeholder
    }
}

// MARK: - UIPickerView Customization
extension SignInViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TruckType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = TruckType.allCases[row].rawValue
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}
