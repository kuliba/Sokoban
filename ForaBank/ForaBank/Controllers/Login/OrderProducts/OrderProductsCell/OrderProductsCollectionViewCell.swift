//
//  OrderProductsCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 25.05.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class OrderProductsCollectionViewCell: UICollectionViewCell, SelfConfiguringCell {


    func configure<U>(with value: U) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
//        titleLabel.text = payment.name
    }
    

    static var reuseId: String = "OrderProductsCollectionViewCell"

    var viewModel: OrderProductModel? {
        didSet { configure() }
    }
    
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        backgroundImageView.image = UIImage(named: viewModel.backgroundName)
        titleLabel.textColor = viewModel.textColor
        subtitleLabel.textColor = viewModel.textColor
    }

}
