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
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        showFIOButton.isHidden = true
//        textField.delegate = self
    }

    func setupUI (_ dataModel: Parameters) {
        let q = GKHDataSorted.a(dataModel.title ?? "")
        operatorsIcon.image = UIImage(named: q.1)
        textField.text = q.0
        let type = dataModel.viewType
//        if type != "INPUT" {
//            self.textField.isSelected = false
//        }
    }
    @IBAction func textField(_ sender: UITextField) {
    }
    
    
    
    @IBAction func showFIOButton(_ sender: UIButton) {
    }
    @IBAction func showInfo(_ sender: UIButton) {
    }
    
}


extension GKHInputCell: UITextFieldDelegate {
    
}
