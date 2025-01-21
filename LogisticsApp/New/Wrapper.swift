//
//  Wrapper.swift
//  LogisticsApp
//
//  Created by beqa on 21.01.25.
//

import SwiftUI

struct MapVCWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MapVC {
        return MapVC()
    }
    
    func updateUIViewController(_ uiViewController: MapVC, context: Context) {}
}
