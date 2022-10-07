//
//  NewCardCell.swift
//  ForaBank
//
//  Created by Mikhail on 30.06.2021.
//

import UIKit

class NewCardCell: UICollectionViewCell {
    
    //MARK: - Properties
//    var card: GetProductListDatum? {
//        didSet { configure() }
//    }
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "addCard"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 24, width: 24)
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11 )
        label.text = "Новая"
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
        
    }
    
    //MARK: - Helpers
//    func configure() {
//        guard let card = card else { return }
//
//        let viewModel = CardViewModel(card: card)
//        balanceLabel.text = viewModel.balance
//        maskCardLabel.text = viewModel.maskedcardNumber
//        logoImageView.image = viewModel.logoImage
//    }
    
    func setupUI() {
        backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        layer.cornerRadius = 8
        clipsToBounds = true
        addSubview(logoImageView)
        addSubview(nameLabel)
        
        logoImageView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 16)
        
        nameLabel.centerX(inView: logoImageView, topAnchor: logoImageView.bottomAnchor, paddingTop: 2)
    }
    
}
