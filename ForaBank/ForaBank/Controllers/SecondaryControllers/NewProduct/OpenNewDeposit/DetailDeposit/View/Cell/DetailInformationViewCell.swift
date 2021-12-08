//
//  DetailInformationViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 30.11.2021.
//

import UIKit

class DetailInformationViewCell: UITableViewCell {

    var viewModel: DetailedСondition? {
        didSet {
            configure()
        }
    }
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailChekImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        detailLabel.text = viewModel.desc ?? ""
        detailLabel.textColor = (viewModel.enable ?? false)
        ? UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1)
        : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        detailChekImage.image = (viewModel.enable ?? false) ? UIImage(named: "detailCheck") : UIImage(named: "detailClose")
    }
    
    
}
