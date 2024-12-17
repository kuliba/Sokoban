//
//  MainDepositCollectionViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 01.12.2021.
//

import UIKit

class MainDepositCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var depositNameLabel: UILabel!
    @IBOutlet weak var minSummDepositLabel: UILabel!
    @IBOutlet weak var maxDateDepositLabel: UILabel!
    @IBOutlet weak var maxPercentDepositLabel: UILabel!
    
    var viewModel: OpenDepositDatum? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        depositNameLabel.text = viewModel.name
        maxPercentDepositLabel.text = "до \(viewModel.generalСondition?.maxRate ?? 0) %"
        minSummDepositLabel.text = "\(viewModel.generalСondition?.minSum ?? 0) ₽"
        maxDateDepositLabel.text = viewModel.generalСondition?.maxTermTxt
        
        /// design
        backgroundColor = UIColor(hexString: viewModel.generalСondition?.design?.background?.first ?? "")
        depositNameLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?.first ?? "")
        
        minSummDepositLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?.first ?? "")
        maxDateDepositLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?.first ?? "")
        maxPercentDepositLabel.textColor = UIColor(hexString: viewModel.generalСondition?.design?.textColor?.first ?? "")
    }
    
}
