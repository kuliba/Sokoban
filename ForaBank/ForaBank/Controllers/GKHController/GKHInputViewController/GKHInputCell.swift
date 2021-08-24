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
    
    @IBOutlet weak var lineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        showFIOButton.isHidden = true
    }

    func setupUI (_ dataModel: Parameters) {
        let q = GKHDataSorted.a(dataModel.title ?? "")
        operatorsIcon.image = UIImage(named: q.1)
        placeholderLable.text = q.0
    }
    
    
    
    @IBAction func showFIOButton(_ sender: UIButton) {
    }
    @IBAction func showInfo(_ sender: UIButton) {
    }
    
}
