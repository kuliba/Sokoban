//
//  TermsDepositTableViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 30.12.2021.
//

import UIKit

class TermsDepositTableViewCell: UITableViewCell {
    
    @IBOutlet weak var documentLabel: UILabel!
    
    var document: String? {
        didSet {
            guard let document = document else { return }
            configure(with: document)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    
    func configure(with document: String) {
        documentLabel.text = document
    }
    
}
