//
//  extension2.swift
//  LogisticsApp
//
//  Created by beqa on 21.01.25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

// MARK: Fetch User Data Example
extension SignInViewController {
    func fetchUserData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                if let data = document.data() {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "User Data", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found"])))
                }
            }
        }
    }
}
