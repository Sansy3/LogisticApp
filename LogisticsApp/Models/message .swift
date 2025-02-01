import FirebaseFirestore

struct Message {
    let senderId: String
    let text: String
    let timestamp: Timestamp
    
    init(senderId: String, text: String, timestamp: Timestamp) {
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String: Any]) {
        guard let senderId = dictionary["senderId"] as? String,
              let text = dictionary["text"] as? String,
              let timestamp = dictionary["timestamp"] as? Timestamp else { return nil }
        
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
    }
}
