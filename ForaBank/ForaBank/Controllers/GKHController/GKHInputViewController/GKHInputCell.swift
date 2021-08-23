//
//  GKHInputCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.08.2021.
//

import UIKit

class GKHInputCell: UITableViewCell {

    static let reuseId = "GKHInputCell"
    @IBOutlet weak var operatorsIcon: UIImageView!
    @IBOutlet weak var placeholderLable: UILabel!
    @IBOutlet weak var errorLable: UILabel!
    @IBOutlet weak var showFIOButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupUI (_ dataModel: Parameters) {
         
    }
    
    
    
    @IBAction func showFIOButton(_ sender: UIButton) {
    }
    @IBAction func showInfo(_ sender: UIButton) {
    }
    
}
