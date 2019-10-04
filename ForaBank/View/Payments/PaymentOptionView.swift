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
    }
}
