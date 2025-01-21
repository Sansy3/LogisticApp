//
//  Extensions.swift
//  LogisticsApp
//
//  Created by beqa on 15.01.25.
//




import SwiftUI

extension Color {
    static let primaryGradientStart = Color.blue
    static let primaryGradientEnd = Color.purple
    static let cardBackground = Color(UIColor.systemBackground)
    static let cardShadow = Color.gray.opacity(0.3)
}

extension LinearGradient {
    static let primary = LinearGradient(
        gradient: Gradient(colors: [Color.primaryGradientStart, Color.primaryGradientEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
