//
//  AtmCollectionViewCell.swift
//  ForaBank
//
//  Created by Max Gribov on 04.04.2022.
//

import UIKit

class AtmCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String = "AtmCollectionViewCell"
    
    let imageView: UIImageView
    let label: UILabel
    
    override init(frame: CGRect) {
        
        self.imageView = UIImageView(frame: .zero)
        self.label = UILabel(frame: .zero)
        super.init(frame: frame)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -180),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: PaymentsModel) {
        
        let iconName = viewModel.iconName ?? "Atm Banner"
        imageView.image = UIImage(named: iconName)
        label.text = viewModel.name
    }
}
