//
//  PaymentOptionView.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PaymentOptionView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var optionNameLabel: UILabel!
    @IBOutlet weak var optionValueLabel: UILabel!
    @IBOutlet weak var optionNumberLabel: UILabel!
    @IBOutlet weak var companyImageView: UIImageView!
    @IBOutlet weak var providerImageView: UIImageView!
    @IBOutlet weak var arrowsImageView: UIImageView!

    @IBOutlet weak var leadingToArrowConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingToSuperviewConstraint: NSLayoutConstraint!
    
    var currency = String()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: PaymentOptionView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        arrowsImageView.isHidden = true
      
        
    }

    internal func setupLayout(withPickerItem pickerItem: IPickerItem, isDroppable: Bool) {
//        leadingToArrowConstraint.isActive = isDroppable
        leadingToSuperviewConstraint.isActive = !isDroppable
        arrowsImageView.isHidden = !isDroppable

        optionNameLabel.text = pickerItem.title
        optionNumberLabel.text = pickerItem.subTitle
        guard let currentLabel = getSymbol(forCurrencyCode: pickerItem.currencyCode ?? "") else {
            return
        }
        optionValueLabel.text = "\(maskSum(sum:pickerItem.value) + currentLabel)"

        updateConstraints()
    }
}
