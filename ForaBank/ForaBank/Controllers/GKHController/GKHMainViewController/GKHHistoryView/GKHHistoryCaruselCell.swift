//
//  GKHHistoryCaruselCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.08.2021.
//

import UIKit

class GKHCaruselCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "GalleryCollectionViewCell"
    
    let mainImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = #colorLiteral(red: 0.007841579616, green: 0.007844132371, blue: 0.007841020823, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let smallDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainImageView)
        addSubview(nameLabel)
        addSubview(smallDescriptionLabel)
        
        backgroundColor = .white
        
        // mainImageView constraints
        mainImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
//        mainImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 2/3).isActive = true
        mainImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        mainImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        // nameLabel constraints
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant:0).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 8).isActive = true
        
        // smallDescriptionLabel constraints
        smallDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        smallDescriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        smallDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
//        smallDescriptionLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: 10).isActive = true
        
        self.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        self.layer.cornerRadius = 5
//        self.layer.shadowRadius = 9
//        layer.shadowOpacity = 0.3
//        layer.shadowOffset = CGSize(width: 5, height: 8)
//
//        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

