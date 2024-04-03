//
//  CardsScrollCell.swift
//  ForaBank
//
//  Created by Mikhail on 28.09.2021.
//

import UIKit

class CardsScrollCell: UICollectionViewCell, SelfConfiguringCell {
   
    var getUImage: (Md5hash) -> UIImage? = { _ in UIImage() }
    var isChecked: Bool = false
    
    func configure<U>(with value: U) where U : Hashable {
        guard let card = card else { return }
        
        let viewModel = CardsScrollModel(
            card: card,
            getUIImage: getUImage
        )
        balanceLabel.text = viewModel.balance
        maskCardLabel.text = viewModel.maskedcardNumber
    }
  
    static var reuseId: String = "CardCell"
    //MARK: - Properties
    var card: UserAllCardsModel? {
        didSet { configure(getUImage: getUImage, isChecked: isChecked) }
    }
    

    
    public let maskCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11 )
        label.text = ""
        return label
    }()

    public let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 11)
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
    
    public let cloverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public let isCheckedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.9
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
    func configure(
        getUImage: @escaping (Md5hash) -> UIImage?,
        isChecked: Bool
    ) {
        guard let card = card else { return }
        
        let viewModel = CardsScrollModel(card: card, getUIImage: getUImage)
        backgroundImageView.image = viewModel.backgroundImage
        cloverImageView.image = viewModel.card.cloverImage?.withRenderingMode(.alwaysOriginal)
        balanceLabel.text = viewModel.balance
        balanceLabel.textColor = viewModel.colorText
        cardNameLabel.text = viewModel.cardName
        cardNameLabel.textColor = viewModel.colorText
        cardNameLabel.alpha = 0.5
        maskCardLabel.text = viewModel.maskedcardNumber
        maskCardLabel.textColor = viewModel.colorText
        isCheckedImageView.image = isChecked ? UIImage(named: "ic18Check")!.withRenderingMode(.alwaysOriginal) : UIImage()
    }
    
    func setupUI() {
        backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        layer.cornerRadius = 8
        layer.shadowColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1).cgColor
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize()
        let shadowPath = UIBezierPath(
            rect: CGRect(x: 15, y: 20,
                         width: self.frame.width * 0.785,
                         height: self.frame.height * 0.785))
        layer.shadowPath = shadowPath.cgPath
        
        addSubview(backgroundImageView)
        addSubview(maskCardLabel)
        addSubview(cardNameLabel)
        addSubview(balanceLabel)
        addSubview(cloverImageView)
        addSubview(isCheckedImageView)

        backgroundImageView.fillSuperview()
        
        maskCardLabel.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 12, paddingLeft: 37, paddingRight: 12)
        
        
        cardNameLabel.anchor(left: self.leftAnchor, bottom: balanceLabel.topAnchor, right: self.rightAnchor, paddingTop: 25, paddingLeft: 8, paddingRight: 8)
        cardNameLabel.lineBreakMode = .byWordWrapping
        cardNameLabel.numberOfLines = 2
        
        balanceLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor,
                            paddingLeft: 8, paddingBottom: 8, paddingRight: 30)
        
        cloverImageView.anchor(top: self.topAnchor, right: self.rightAnchor, paddingTop: 8, paddingRight: 8)
        
        isCheckedImageView.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 9, paddingLeft: 9)
    }
}
