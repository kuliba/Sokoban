//
//  GKHInputCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.08.2021.
//

import UIKit

@objc protocol TableViewDelegate: NSObjectProtocol{

    func afterClickingReturnInTextField(cell: GKHInputCell)
}

class GKHInputCell: UITableViewCell, UITextFieldDelegate {
    
    weak var tableViewDelegate: TableViewDelegate?

    static let reuseId = "GKHInputCell"
    @IBOutlet weak var operatorsIcon: UIImageView!
    @IBOutlet weak var showFioButton: UIButton!
    @IBOutlet weak var placeholderLable: UILabel!
    @IBOutlet weak var errorLable: UILabel!
    @IBOutlet weak var showFIOButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lineView: UIView!
    
    var placeholder = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showFIOButton.isHidden = true
        textField.delegate = self
    }
    
    // @IBAction Of UITextfiled
//        @IBAction func tapHerre(_ sender: UITextField) {
//
//            tableViewDelegate?.responds(to: #selector(TableViewDelegate.afterClickingReturnInTextField(cell:)))
//            tableViewDelegate?.afterClickingReturnInTextField(cell: self)
//        }
    
    // UITextField Defaults delegates
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {

            textField.resignFirstResponder()
            return true
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            self.placeholderLable.text = placeholder
            self.textField = textField
            if placeholder == "" {
                self.placeholderLable.text = ""
            }
        }

    func setupUI (_ dataModel: Parameters) {
        let q = GKHDataSorted.a(dataModel.title ?? "")
        print("GKHCell", q.1, q.0)
        operatorsIcon.image = UIImage(named: q.1)
        textField.text = q.0
        placeholder = q.0
        self.errorLable.text = dataModel.subTitle
        let type = dataModel.viewType
        if type != "INPUT" {
            self.textField.isEnabled = false
        }
        if q.0 == "ФИО" {
            showFioButton.isHidden = false
        } else {
            showFioButton.isHidden = true
        }
    }
    @IBAction func textField(_ sender: UITextField) {
//        tableViewDelegate?.responds(to: #selector(TableViewDelegate.afterClickingReturnInTextField(cell:)))
//        tableViewDelegate?.afterClickingReturnInTextField(cell: self)
    }
    
    
    
    @IBAction func showFIOButton(_ sender: UIButton) {
    }
    @IBAction func showInfo(_ sender: UIButton) {
    }
    
}

