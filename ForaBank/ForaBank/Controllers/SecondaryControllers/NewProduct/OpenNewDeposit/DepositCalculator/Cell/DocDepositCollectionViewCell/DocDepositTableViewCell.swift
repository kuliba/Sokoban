//
//  DocDepositTableViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 10.12.2021.
//

import UIKit

class DocDepositTableViewCell: UITableViewCell {
    
    @IBOutlet weak var documentLabel: UILabel!
    
    var document: DocumentsList? {
        didSet {
            guard let document = document else { return }
            configure(with: document)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    
    func configure(with document: DocumentsList) {
        documentLabel.text = document.name
    }
}
