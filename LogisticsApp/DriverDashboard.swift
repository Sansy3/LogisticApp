//
//  DriverDashboard.swift
//  LogisticsApp
//
//  Created by beqa on 15.01.25.
//

import SwiftUI

struct DriverDashboardView: View {
    @State private var cargoStatus: String = "In Transit"
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Driver Dashboard")
                    .font(.title)
                    .padding()
                
                Text("Cargo Status: \(cargoStatus)")
                    .font(.body)
                    .padding()
                
                Button(action: {
                    cargoStatus = "Delivered"
                }) {
                    Text("Update Cargo Status")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .navigationBarTitle("Dashboard", displayMode: .inline)
        }
    }
}

struct DriverDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DriverDashboardView()
    }
}
