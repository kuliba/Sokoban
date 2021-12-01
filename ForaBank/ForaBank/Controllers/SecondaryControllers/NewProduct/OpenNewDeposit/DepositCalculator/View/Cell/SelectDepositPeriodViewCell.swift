//
//  SelectDepositPeriodViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 01.12.2021.
//

import UIKit

class SelectDepositPeriodViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var viewModel: TermRateSumTermRateList? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.termName
        subTitleLabel.text = "\(viewModel.term ?? 0) дней"
    }
    
}
