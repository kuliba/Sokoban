//
//  CountryListCell.swift
//  ForaBank
//
//  Created by Mikhail on 20.07.2021.
//

import UIKit

class CountryListCell: UICollectionViewCell {
    
    //MARK: - Properties
    var country: CountriesList? {
        didSet { configure() }
    }
    
    let countryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.setDimensions(height: 40, width: 40)
        return imageView
    }()
    
    let countryNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 11 )
        label.textAlignment = .center
        label.text = ""
        return label
    }()

    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    func configure() {
        guard let country = country else { return }
        countryNameLabel.text = country.name?.capitalizingFirstLetter()
        countryImageView.image = country.svgImage?.convertSVGStringToImage()
    }
    
    func setupUI() {
        addSubview(countryImageView)
        addSubview(countryNameLabel)
        
        countryImageView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 16)
        countryNameLabel.centerX(inView: self, topAnchor: countryImageView.bottomAnchor, paddingTop: 8)
        countryNameLabel.anchor(width: 76)
        
    }
    
}
