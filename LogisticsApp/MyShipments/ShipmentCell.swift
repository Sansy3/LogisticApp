//
//  ShipmentCel.swift
//  LogisticsApp
//
//  Created by beqa on 01.02.25.
//
import UIKit
import FirebaseFirestore

// Custom UITableViewCell
class ShipmentTableViewCell: UITableViewCell {
    private let originDestinationLabel = UILabel()
    private let weightStatusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(originDestinationLabel)
        contentView.addSubview(weightStatusLabel)
        
        originDestinationLabel.translatesAutoresizingMaskIntoConstraints = false
        weightStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            originDestinationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            originDestinationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            originDestinationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            weightStatusLabel.topAnchor.constraint(equalTo: originDestinationLabel.bottomAnchor, constant: 4),
            weightStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weightStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            weightStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        originDestinationLabel.font = UIFont.boldSystemFont(ofSize: 17)
        weightStatusLabel.font = UIFont.systemFont(ofSize: 15)
    }
    
    func configure(with shipment: FirestoreLoadItem) {
        originDestinationLabel.text = "\(shipment.origin) -> \(shipment.destination)"
        weightStatusLabel.text = "Weight: \(shipment.weight) lbs, Status: \(shipment.status)"
    }
}
