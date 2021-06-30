//
//  CardChooseView.swift
//  ForaBank
//
//  Created by Mikhail on 29.06.2021.
//

import UIKit

class CardChooseView: UIView {
    
    //MARK: - Property
    let kContentXibName = "CardChooseView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cardTypeImage: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var maskNumberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberCardLabel: UILabel!
    
    var didChooseButtonTapped: (() -> Void)?
    
    var cardModel: GetProductListDatum? {
        didSet {
            guard let model = cardModel else { return }
            setupData(with: model)
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
        self.anchor(height: 44)
        hideAll(true)
        
    }
    @IBAction func chooseButtonTapped(_ sender: Any) {
        didChooseButtonTapped?()
    }
    
    private func setupData(with model: GetProductListDatum) {
        hideAll(false)
        let balance = Double(model.balance ?? 0)
        self.balanceLabel.text = balance.currencyFormatter()
        self.numberCardLabel.text = model.productName
        self.maskNumberLabel.text = "• \(model.number?.suffix(4) ?? "")"
        self.nameLabel.text = model.customName ?? model.name ?? ""
        self.setupCardImage(with: model.number ?? "")
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
