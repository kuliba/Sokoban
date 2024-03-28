//
//  CardChooseView.swift
//  ForaBank
//
//  Created by Mikhail on 29.06.2021.
//

import UIKit

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
    @IBOutlet weak var leftTitleAncor: NSLayoutConstraint!
    @IBOutlet weak var choseButton: UIButton?
    
    var getUImage: ((Md5hash) -> UIImage?)?
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
        
        var balance = Double(model.balance)

        imageView.image = {
            if let getUImage {
                getUImage(model.smallDesignMd5Hash ?? "") ?? UIImage(named:"AccImage")
            } else {UIImage(named:"AccImage")}
        }()
        imageView.accessibilityIdentifier = "ChooseProductIcon"
        
        self.balanceLabel.text = balance.currencyFormatter(symbol: model.currency ?? "")
        self.balanceLabel.accessibilityIdentifier = "ChooseProductBalance"
        
        let text = NSAttributedString(
            string: model.mainField ?? "",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                         NSAttributedString.Key.foregroundColor : UIColor.black])
        self.numberCardLabel.attributedText = text
        self.numberCardLabel.accessibilityIdentifier = "ChooseProductName"
        
        switch model.productType {
        case ProductType.card.rawValue:
            
            self.maskNumberLabel.text = "• \(model.number?.suffix(4) ?? "")"
            self.nameLabel.text = model.customName ?? model.additionalField ?? ""
            self.maskNumberLabel.accessibilityIdentifier = "ChooseProductNumber"
            self.nameLabel.accessibilityIdentifier = "ChooseProductAdditionalField"

        case ProductType.account.rawValue:
            
            self.maskNumberLabel.text = "• \(model.number?.suffix(4) ?? "")"
            cardTypeImage.isHidden = true
            self.nameLabel.text = model.customName ?? model.additionalField ?? ""

        case ProductType.deposit.rawValue:
            
            self.numberCardLabel.text = model.mainField
            self.maskNumberLabel.text = "• \(model.accountNumber?.suffix(4) ?? "")"
            self.nameLabel.text = "• \("Cтавка \(model.interestRate ?? "")%")"
            let text = NSAttributedString(
                string: model.mainField ?? "",
                attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                             NSAttributedString.Key.foregroundColor : UIColor.black])
            self.numberCardLabel.attributedText = text
            cardTypeImage.isHidden = true

        case ProductType.loan.rawValue:
            
            balance = model.totalAmountDebt

            if let date = longIntToDateString(longInt: model.dateLong/1000) {
                
                self.maskNumberLabel.text = "· \(model.settlementAccount?.suffix(4) ?? "") · Ставка \(model.currentInterestRate)%  · \(date)"
            }
            
            self.nameLabel.text = model.customName ?? model.additionalField ?? ""
            cardTypeImage.isHidden = true

        default:
            break
        }
        self.nameLabel.text = model.customName ?? model.additionalField ?? ""
        self.cardTypeImage.image = {
            if let getUImage { getUImage(model.paymentSystemImageMd5Hash ?? "") ?? UIImage() }
            else { UIImage() }
        }()
        self.cardTypeImage.accessibilityIdentifier = "ChooseProductPaymentSystemIcon"
    }
    
    private func setupData(with model: GetProductListDatum) {
        hideAll(false)
        
        guard let modelBalance = model.balance else { return }
        
        var balance = Double(modelBalance)
        
        imageView.image = {
            if let getUImage { getUImage(model.smallDesignMd5Hash ?? "") ?? UIImage(named:"AccImage") }
            else { UIImage(named:"AccImage") }
        }()
        self.balanceLabel.text = balance.currencyFormatter(symbol: model.currency ?? "")
            
        let text = NSAttributedString(
            string: model.mainField ?? "",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                         NSAttributedString.Key.foregroundColor : UIColor.black])
        self.numberCardLabel.attributedText = text
        
        switch model.productType {
        case ProductType.card.rawValue:
            
            self.maskNumberLabel.text = "• \(model.number?.suffix(4) ?? "")"
            self.nameLabel.text = model.customName ?? model.additionalField ?? ""

        case ProductType.account.rawValue:
            
            self.maskNumberLabel.text = "• \(model.number?.suffix(4) ?? "")"
            cardTypeImage.isHidden = true
            self.nameLabel.text = model.customName ?? model.additionalField ?? ""

        case ProductType.deposit.rawValue:
            
            self.numberCardLabel.text = model.mainField
            self.maskNumberLabel.text = "• \(model.accountNumber?.suffix(4) ?? "")"
           
            if let interestRate = model.interestRate {
                
                self.nameLabel.text = "• \("Cтавка \(interestRate)%")"

            }
            let text = NSAttributedString(
                string: model.mainField ?? "",
                attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                             NSAttributedString.Key.foregroundColor : UIColor.black])
            self.numberCardLabel.attributedText = text
            cardTypeImage.isHidden = true

        case ProductType.loan.rawValue:
            
            if let totalAmountDebt = model.totalAmountDebt {

                balance = totalAmountDebt
            }

            if let dateLong = model.dateLong, let date = longIntToDateString(longInt: dateLong/1000) {
                
                self.maskNumberLabel.text = "· \(model.settlementAccount?.suffix(4) ?? "") · Ставка \(model.currentInterestRate)%  · \(date)"
            }
            
            self.nameLabel.text = model.customName ?? model.additionalField ?? ""
            cardTypeImage.isHidden = true

        default:
            break
        }
        self.nameLabel.text = model.customName ?? model.additionalField ?? ""
        self.cardTypeImage.image = {
            if let getUImage { getUImage(model.smallDesignMd5Hash ?? "") ?? UIImage() }
            else { UIImage() }
        }()
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
        imageView.image = model.smallDesign?.uiImage ?? #imageLiteral(resourceName: "credit-card")
        let text = NSAttributedString(
            string: model.customName ?? "",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                         NSAttributedString.Key.foregroundColor : UIColor.black])
        self.numberCardLabel.attributedText = text
        self.maskNumberLabel.text = "• \(model.numberMask?.suffix(4) ?? "")"
        
        if let image = model.paymentSystemImage?.uiImage {
            cardTypeImage.image = image
        } else {
            self.setupCardImage(with: model.numberMask ?? "")
        }
        
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
    
    func longIntToDateString(longInt: Int) -> String?{
        
        let date = Date.dateUTC(with: longInt)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none//Set time style
        dateFormatter.dateStyle = DateFormatter.Style.long //Set date style
        
        dateFormatter.dateFormat =  "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let localDate = dateFormatter.string(from: date)
        
        return localDate
    }
}
