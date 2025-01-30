//
//  CustomCallout.swift
//  LogisticsApp
//
//  Created by beqa on 29.01.25.
//

import UIKit

class CustomCalloutView: UIView {
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    private let statusView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        statusView.backgroundColor = .systemGreen
        statusView.layer.cornerRadius = 4
        addSubview(statusView)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        addSubview(nameLabel)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            statusView.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusView.widthAnchor.constraint(equalToConstant: 8),
            statusView.heightAnchor.constraint(equalToConstant: 8),
            
            nameLabel.leadingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            timeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with name: String, time: String) {
        nameLabel.text = name
        timeLabel.text = time
    }
}
