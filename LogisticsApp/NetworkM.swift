//
//  NetowrkManager.swift
//  LogisticsApp
//
//  Created by beqa on 22.01.25.
//

import Foundation

class NetworkManager {
    func fetchLoadData(completion: @escaping ([LoadItem]) -> Void) {
        guard let url = URL(string: "https://my.api.mockaroo.com/load_api_j_son.json?key=6a8758b0") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let loadItems = try decoder.decode([LoadItem].self, from: data)
                DispatchQueue.main.async {
                    completion(loadItems)
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
