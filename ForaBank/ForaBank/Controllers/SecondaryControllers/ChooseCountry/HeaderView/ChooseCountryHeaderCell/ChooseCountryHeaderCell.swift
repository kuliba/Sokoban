//
//  ChooseCountryHeaderCell.swift
//  ForaBank
//
//  Created by Mikhail on 19.07.2021.
//

import UIKit

class ChooseCountryHeaderCell: UICollectionViewCell {
    
    //MARK: - Properties
    var viewModel: ChooseCountryHeaderViewModel? {
        didSet { configure() }
    }
    
    private let countryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 56, width: 56)
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 11 )
        label.textAlignment = .center
        label.text = ""
        label.textColor = .black
        return label
    }()

    private let countryNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 11 )
        label.textAlignment = .center
        label.text = ""
        label.textColor = .gray
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
    
    //MARK: - Selectors
    
    @objc func hendleShareTapped() {
        print(#function)
    }
    
    //MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        
        userNameLabel.text = viewModel.shortName
        countryImageView.image = viewModel.countryImage
        countryNameLabel.text = viewModel.countryName
    }
    
    func setupUI() {
        addSubview(countryImageView)
        addSubview(userNameLabel)
        addSubview(countryNameLabel)
        
        countryImageView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 8)
        countryImageView.layer.cornerRadius = 56 / 2
        countryImageView.clipsToBounds = true
        
        userNameLabel.centerX(inView: self, topAnchor: countryImageView.bottomAnchor, paddingTop: 4)
        userNameLabel.anchor(width: 80)
        
        countryNameLabel.centerX(inView: self, topAnchor: userNameLabel.bottomAnchor, paddingTop: 4)
        countryNameLabel.anchor(width: 80)
    }
    
}
