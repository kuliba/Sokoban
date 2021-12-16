//
//  CardChooseView.swift
//  ForaBank
//
//  Created by Mikhail on 29.06.2021.
//

import UIKit

@IBDesignable
final class CardChooseView: UIView {
    
    //MARK: - Property
    let kContentXibName = "CardChooseView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cardTypeImage: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var maskNumberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberCardLabel: UILabel!
    @IBInspectable
    @IBOutlet weak var leftTitleAncor: NSLayoutConstraint!
    @IBOutlet weak var choseButton: UIButton!
    
    
    var didChooseButtonTapped: (() -> Void)?
    
    var cardModel: GetProductListDatum? {
        didSet { guard let model = cardModel else { return }
            setupData(with: model)
        }
    }
    
    var model: UserAllCardsModel? {
        didSet { guard let model = model else { return }
            setupRealmData(with: model)
        }
    }
    
    var customCardModel: CastomCardViewModel? {
        didSet { guard let model = customCardModel else { return }
            setupCustomData(with: model)
        }
    }
    
    var tempCardModel: GetProductTemplateDatum? {
        didSet { guard let model = tempCardModel else { return }
            setupTempData(with: model)
        }
    }
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.anchor(height: 64)
        hideAll(true)
        
    }
    @IBAction func chooseButtonTapped(_ sender: Any) {
        didChooseButtonTapped?()
    }
    
    private func setupRealmData(with model: UserAllCardsModel) {
        hideAll(false)
        
        if model.productType == "ACCOUNT" || model.productType == "DEPOSIT" {
            imageView.image = model.smallDesign?.convertSVGStringToImage() ?? #imageLiteral(resourceName: "AccImage")
            cardTypeImage.isHidden = true
        }
        else if model.productType == "CARD" {
            self.imageView.image = model.smallDesign?.convertSVGStringToImage() ?? #imageLiteral(resourceName: "credit-card")
        }
        
        let balance = Double(model.balance)
        self.balanceLabel.text = balance.currencyFormatter(symbol: model.currency ?? "")
        let text = NSAttributedString(
            string: model.mainField ?? "",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                         NSAttributedString.Key.foregroundColor : UIColor.black])
        self.numberCardLabel.attributedText = text
        self.maskNumberLabel.text = "• \(model.number?.suffix(4) ?? "")"
        self.nameLabel.text = model.customName ?? model.additionalField ?? ""
        self.cardTypeImage.image = model.paymentSystemImage?.convertSVGStringToImage()
    }
    
    private func setupData(with model: GetProductListDatum) {
        hideAll(false)
        
        if model.productType == "ACCOUNT" || model.productType == "DEPOSIT" {
            imageView.image = model.smallDesign?.convertSVGStringToImage() ?? #imageLiteral(resourceName: "AccImage")
            cardTypeImage.isHidden = true
        }
        else if model.productType == "CARD" {
            self.imageView.image = model.smallDesign?.convertSVGStringToImage() ?? #imageLiteral(resourceName: "credit-card")
        }
        
        
        let balance = Double(model.balance ?? 0)
        self.balanceLabel.text = balance.currencyFormatter(symbol: model.currency ?? "")
        let text = NSAttributedString(
//            string: model.mainField ?? model.productName ?? "",
            string: model.mainField ?? "",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                         NSAttributedString.Key.foregroundColor : UIColor.black])
        self.numberCardLabel.attributedText = text
        self.maskNumberLabel.text = "• \(model.number?.suffix(4) ?? "")"
        self.nameLabel.text = model.customName ?? model.additionalField ?? ""
//        self.setupCardImage(with: model.number ?? "")
        self.cardTypeImage.image = model.paymentSystemImage?.convertSVGStringToImage()
    }
    
    private func setupCustomData(with model: CastomCardViewModel) {
        hideAll(false)
        imageView.image = #imageLiteral(resourceName: "credit-card")
        
        self.nameLabel.isHidden = true
        self.balanceLabel.isHidden = true
        let text = NSAttributedString(
            string: model.cardName ?? "",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                         NSAttributedString.Key.foregroundColor : UIColor.black])
        self.numberCardLabel.attributedText = text
        self.maskNumberLabel.text = "• \(model.cardNumber.suffix(4))"
        self.setupCardImage(with: model.cardNumber)

    }
    
    private func setupTempData(with model: GetProductTemplateDatum) {
        hideAll(false)
        imageView.image = #imageLiteral(resourceName: "credit-card")
        let text = NSAttributedString(
            string: model.customName ?? "",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                         NSAttributedString.Key.foregroundColor : UIColor.black])
        self.numberCardLabel.attributedText = text
        self.maskNumberLabel.text = "• \(model.numberMask?.suffix(4) ?? "")"
        self.setupCardImage(with: model.numberMask ?? "")
        self.choseButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        
        self.balanceLabel.isHidden = true
        self.nameLabel.isHidden = true
    }
    
    func hideAll(_ need: Bool) {
        imageView.isHidden = need
        cardTypeImage.isHidden = need
        balanceLabel.isHidden = need
        maskNumberLabel.isHidden = need
        nameLabel.isHidden = need
    }
    
    private func setupCardImage(with number: String) {
        let firstSimb = number.first
        switch firstSimb {
        case "1":
            cardTypeImage.image = #imageLiteral(resourceName: "mir-colored")
        case "4":
            cardTypeImage.image = #imageLiteral(resourceName: "card_visa_logo")
        case "5":
            cardTypeImage.image = #imageLiteral(resourceName: "card_mastercard_logo")
        default:
            cardTypeImage.image = UIImage()
        }
    }
    
}
