////
////  GmailService .swift
////  LogisticsApp
////
////  Created by beqa on 18.01.25.
////
//
//import GoogleAPIClientForRESTCore
//import GoogleAPIClientForREST_ACMEDNS
//import GoogleAPIClientForREST_APIGateway
//import GoogleAPIClientForREST_APIManagement
//import GoogleAPIClientForREST_AIPlatformNotebooks
//import GoogleSignIn
//
//class GmailService {
//
//    // Create an instance of the Gmail API service
//    private let service = GTLRGmailService()
//
//    // Fetch emails from Gmail
//    func fetchEmails(completion: @escaping ([Cargo]?, Error?) -> Void) {
//        // Ensure the user is authenticated
//        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
//            completion(nil, NSError(domain: "GmailService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not signed in"]))
//            return
//        }
//
//        // Set the auth credentials for the Gmail API
//        service.authorizer = currentUser.authentication.fetcherAuthorizer()
//
//        // Create a query to fetch messages from Gmail
//        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: "me")
//        query.q = "subject:Bid on Order"  // Filter emails with a specific subject (e.g., "Bid on Order")
//
//        // Execute the query
//        service.executeQuery(query) { (ticket, result, error) in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//
//            guard let messages = (result as? GTLRGmail_ListMessagesResponse)?.messages else {
//                completion([], nil)
//                return
//            }
//
//            var cargos: [Cargo] = []
//            let dispatchGroup = DispatchGroup()
//
//            for message in messages {
//                dispatchGroup.enter()
//
//                // Fetch each message's details
//                self.fetchEmailDetails(messageId: message.identifier) { emailDetails in
//                    if let cargo = self.parseEmailToCargo(emailDetails) {
//                        cargos.append(cargo)
//                    }
//                    dispatchGroup.leave()
//                }
//            }
//
//            // Once all emails are processed, return the list of cargos
//            dispatchGroup.notify(queue: .main) {
//                completion(cargos, nil)
//            }
//        }
//    }
//
//    // Fetch details for a single email message
//    private func fetchEmailDetails(messageId: String, completion: @escaping (String) -> Void) {
//        let query = GTLRGmailQuery_UsersMessagesGet.query(withUserId: "me", identifier: messageId)
//        service.executeQuery(query) { (ticket, result, error) in
//            if let error = error {
//                print("Error fetching message details: \(error.localizedDescription)")
//                completion("")
//                return
//            }
//            if let message = result as? GTLRGmail_Message {
//                let body = message.snippet ?? ""
//                completion(body)
//            }
//        }
//    }
//
//    // Parse email content into Cargo object
//    private func parseEmailToCargo(_ emailContent: String) -> Cargo? {
//        let pickupRegex = try! NSRegularExpression(pattern: "Pick-Up\n(.+?)\n", options: [])
//        let deliveryRegex = try! NSRegularExpression(pattern: "Delivery\n(.+?)\n", options: [])
//        let brokerNameRegex = try! NSRegularExpression(pattern: "Broker Name: (.+?)\n", options: [])
//
//        let pickupRange = pickupRegex.range(of: emailContent)
//        let deliveryRange = deliveryRegex.range(of: emailContent)
//        let brokerNameRange = brokerNameRegex.range(of: emailContent)
//
//        guard let pickup = extractField(from: emailContent, range: pickupRange),
//              let delivery = extractField(from: emailContent, range: deliveryRange),
//              let brokerName = extractField(from: emailContent, range: brokerNameRange) else {
//                  return nil
//              }
//
//        return Cargo(id: "Generated ID", description: "Bid on Order", status: "In Transit", location: delivery, assignedDriver: nil, pickup: pickup, delivery: delivery, brokerName: brokerName, brokerCompany: "Area Wide Logistics LLC", brokerPhone: "630.539.8400", posted: "01/18/25 09:47 EST", expires: "01/18/25 09:16 EST", dockLevel: false, hazmat: false, postedAmount: 0.00, loadType: "Expedited Load", vehicleRequired: "CARGO VAN", pieces: 1, weight: 700, dimensions: "0L x 0W x 0H", stackable: false, csaFastLoad: false, notes: "")
//    }
//
//    // Helper to extract a field from email content using regular expressions
//    private func extractField(from text: String, range: NSRange) -> String? {
//        if range.location != NSNotFound {
//            return (text as NSString).substring(with: range)
//        }
//        return nil
//    }
//}
