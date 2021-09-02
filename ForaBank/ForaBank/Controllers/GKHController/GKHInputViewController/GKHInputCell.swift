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
    
    var fieldid = ""
    var fieldname = ""
    var fieldvalue = ""
    var body = [String: String]()
    
    
    @IBOutlet weak var operatorsIcon: UIImageView!
    @IBOutlet weak var showFioButton: UIButton!
    @IBOutlet weak var placeholderLable: UILabel!
    @IBOutlet weak var errorLable: UILabel!
    @IBOutlet weak var showFIOButton: UIButton!
    @IBOutlet weak var payTypeButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lineView: UIView!
    
    var placeholder = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showFIOButton.isHidden = true
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
    }
    
    // UITextField Defaults delegates
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {

            textField.resignFirstResponder()
            return true
        }
    
        func textFieldDidEndEditing(_ textField: UITextField) {
            
            fieldvalue = textField.text ?? ""
        }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }

    func setupUI (_ index: Int, _ dataModel: Parameters) {
        
        self.fieldid = String(index + 1)
        fieldname = dataModel.title ?? ""
        
        let q = GKHDataSorted.a(dataModel.title ?? "")
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
        fieldvalue = textField.text ?? ""
        body.updateValue(fieldid, forKey: "fieldid")
        body.updateValue(fieldname, forKey: "fieldname")
        body.updateValue(textField.text ?? "" , forKey: "fieldvalue")
        tableViewDelegate?.responds(to: #selector(TableViewDelegate.afterClickingReturnInTextField(cell:)))
        tableViewDelegate?.afterClickingReturnInTextField(cell: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
               
                if (string == " ") {
                    return false
                } else {
                    
                    return true
                }
            }
    
    
    @IBAction func payTapButton(_ sender: UIButton) {
    }
    
    @IBAction func showFIOButton(_ sender: UIButton) {
    }
    @IBAction func showInfo(_ sender: UIButton) {
    }
    
}

