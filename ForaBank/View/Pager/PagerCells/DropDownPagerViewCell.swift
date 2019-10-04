//
//  DropDownPagerViewCell.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import FSPagerView
import DropDown

class DropDownPagerViewCell: FSPagerViewCell, IConfigurableCell {

    @IBOutlet weak var paymentOptionView: PaymentOptionView! {
        didSet {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(paymentOptionViewTapped))
            paymentOptionView.addGestureRecognizer(gestureRecognizer)
            dropDown.width = paymentOptionView.bounds.width
        }
    }

    let dropDown = DropDown()
    var paymentOptions = [PaymentOption]() {
        didSet {
            dropDown.dataSource = Array(repeating: "", count: paymentOptions.count)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        dropDown.customCellConfiguration = { [weak self] (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? PaymentOptionDropDownCell, let paymentOption = self?.paymentOptions[index] else { return }
            cell.paymentOptionView.setupLayout(withPickerItem: paymentOption, isDroppable: false)
        }
        dropDown.cellNib = UINib(nibName: String(describing: PaymentOptionDropDownCell.self), bundle: nil)
        dropDown.cellConfiguration = nil

        dropDown.dismissMode = .onTap
        dropDown.direction = .bottom
        dropDown.anchorView = paymentOptionView

        let appearance = DropDown.appearance()

        appearance.cellHeight = 60
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(provider: ICellProvider) {
        guard let paymentOptionProvider = provider as? PaymentOptionCellProvider else {
            return
        }

        paymentOptionProvider.getData { [weak self] (data) in
            guard let paymentOptions = data as? [PaymentOption] else {
                return
            }
            self?.paymentOptions = paymentOptions
        }
    }


    @objc
    fileprivate func paymentOptionViewTapped() {
        dropDown.show()
    }
}
