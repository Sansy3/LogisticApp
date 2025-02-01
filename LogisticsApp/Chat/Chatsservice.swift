////
////  Untitled.swift
////  LogisticsApp
////
////  Created by beqa on 01.02.25.
////
//
//import FirebaseFirestore
//import FirebaseAuth
//
//class ChatService {
//    static let shared = ChatService()
//    private let db = Firestore.firestore()
//    
//    // MARK: - Send Message
//    func sendMessage(conversationId: String, message: Message, completion: @escaping (Error?) -> Void) {
//        let messageData: [String: Any] = [
//            "senderId": message.senderId,
//            "text": message.text,
//            "timestamp": message.timestamp
//        ]
//        
//        db.collection("conversations")
//            .document(conversationId)
//            .collection("messages")
//            .addDocument(data: messageData, completion: completion)
//    }
//    
//    // MARK: - Fetch Messages
//    func fetchMessages(conversationId: String, completion: @escaping ([Message]?, Error?) -> Void) {
//        db.collection("conversations")
//            .document(conversationId)
//            .collection("messages")
//            .order(by: "timestamp", descending: false)
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    completion(nil, error)
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    completion([], nil)
//                    return
//                }
//                
//                let messages = documents.compactMap { doc -> Message? in
//                    return try? doc.data(as: Message.self)
//                }
//                
//                completion(messages, nil)
//            }
//    }
//}
