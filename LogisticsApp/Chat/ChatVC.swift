import UIKit
import FirebaseFirestore
import FirebaseAuth

// Custom UITableViewCell for chat messages
class ChatMessageCell: UITableViewCell {
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(roleLabel)
        contentView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            roleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            messageLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with message: Message, userName: String, userRole: String, isCurrentUser: Bool) {
        nameLabel.text = userName
        roleLabel.text = userRole
        messageLabel.text = message.text
        
        if isCurrentUser {
            nameLabel.textAlignment = .right
            roleLabel.textAlignment = .right
            messageLabel.textAlignment = .right
        } else {
            nameLabel.textAlignment = .left
            roleLabel.textAlignment = .left
            messageLabel.textAlignment = .left
        }
    }
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var messages: [Message] = []
    var conversationId: String
    let db = Firestore.firestore()
    var usersInfo: [String: (name: String, role: String)] = [:] // Dictionary to store user info
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        return tv
    }()
    
    let messageInputBar: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type a message..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 25
        textField.contentVerticalAlignment = .center
        textField.contentHorizontalAlignment = .left
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        return button
    }()
    
    init(conversationId: String) {
        self.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchMessages()
        fetchUserInfo()
    }
    
    func setupUI() {
        view.addSubview(tableView)
        view.addSubview(messageInputBar)
        view.addSubview(sendButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor),
            
            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            messageInputBar.heightAnchor.constraint(equalToConstant: 50),
            
            sendButton.leadingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    func fetchMessages() {
        db.collection("conversations").document(conversationId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { Message(dictionary: $0.data()) }
                
                // Fetch user info for each message if not already fetched
                for message in self.messages {
                    if self.usersInfo[message.senderId] == nil {
                        self.fetchUserInfo(for: message.senderId)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if !self.messages.isEmpty {
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
    }
    
    func fetchUserInfo() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user info: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                let data = document.data()
                if let name = data["name"] as? String,
                   let role = data["role"] as? String {
                    self.usersInfo[document.documentID] = (name: name, role: role)
                }
            }
            
            // Reload table view to reflect new user info
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchUserInfo(for userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user info for user ID \(userId): \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else { return }
            if let name = data["name"] as? String,
               let role = data["role"] as? String {
                self.usersInfo[userId] = (name: name, role: role)
            }
            
            // Reload table view to reflect new user info
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func sendMessage() {
        guard let text = messageInputBar.text, !text.isEmpty,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        let messageData: [String: Any] = [
            "senderId": userId,
            "text": text,
            "timestamp": Timestamp()
        ]
        
        db.collection("conversations").document(conversationId).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                self.messageInputBar.text = ""
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        
        if let userInfo = usersInfo[message.senderId] {
            cell.configure(with: message, userName: userInfo.name, userRole: userInfo.role, isCurrentUser: message.senderId == Auth.auth().currentUser?.uid)
        } else {
            cell.configure(with: message, userName: "Unknown", userRole: "Unknown", isCurrentUser: message.senderId == Auth.auth().currentUser?.uid)
        }
        
        return cell
    }
}
