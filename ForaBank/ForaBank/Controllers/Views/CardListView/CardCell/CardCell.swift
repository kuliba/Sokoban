//
//  CardCell.swift
//  ForaBank
//
//  Created by Mikhail on 22.06.2021.
//

import UIKit


class CardCell: UICollectionViewCell, SelfConfiguringCell {
   
    func configure<U>(with value: U) where U : Hashable {
        guard let card = card else { return }
        
        let viewModel = CardViewModel(card: card)
        balanceLabel.text = viewModel.balance
        maskCardLabel.text = viewModel.maskedcardNumber
        logoImageView.image = viewModel.logoImage
        
//        balanceLabel.text = contactInitials(model: payment.lastCountryPayment)
    }
    

  
    static var reuseId: String = "CardCell"
    //MARK: - Properties
    var card: GetProductListDatum? {
        didSet { configure() }
    }
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
//        imageView.setDimensions(height: 20, width: 20)
        return imageView
    }()
    
    public let maskCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11 )
        label.text = ""
        return label
    }()

    public let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 11)
//        label.font = UIFont.boldSystemFont(ofSize: 11 )
        label.textAlignment = .left
        label.text = ""
        return label
    }()

    public let cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 11)
        label.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.textAlignment = .left
        label.text = "Зарплатная"
        return label
    }()
    
    public let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
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
    func configure() {
        guard let card = card else { return }
        
        let viewModel = CardViewModel(card: card)
        backgroundImageView.image = viewModel.backgroundImage
        balanceLabel.text = viewModel.balance
        balanceLabel.textColor = viewModel.colorText
        cardNameLabel.text = viewModel.cardName
        cardNameLabel.textColor = viewModel.colorText
        cardNameLabel.alpha = 0.5
        maskCardLabel.text = viewModel.maskedcardNumber
        maskCardLabel.textColor = viewModel.colorText
        logoImageView.image = viewModel.logoImage
    }
    
    func setupUI() {
        backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        layer.cornerRadius = 8
        layer.shadowColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1).cgColor
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize()
//        0.785
        let shadowPath = UIBezierPath(
            rect: CGRect(x: 15, y: 20,
                         width: self.frame.width * 0.785,
                         height: self.frame.height * 0.785))
        layer.shadowPath = shadowPath.cgPath
        
        
        addSubview(backgroundImageView)
        addSubview(logoImageView)
        addSubview(maskCardLabel)
        addSubview(cardNameLabel)
        addSubview(balanceLabel)
        
        backgroundImageView.fillSuperview()
        
        maskCardLabel.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 12, paddingLeft: 37, paddingRight: 12)
        
        logoImageView.centerY(inView: maskCardLabel)
        logoImageView.anchor(left: self.leftAnchor,
                             paddingLeft: 8, width: 18, height: 18)
        
        
        cardNameLabel.anchor(top: maskCardLabel.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor,
                             paddingTop: 12, paddingLeft: 8, paddingRight: 8)
        
        balanceLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor,
                            paddingLeft: 8, paddingBottom: 8, paddingRight: 30)
    }
    
}
