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
    
    var info = ""
    
    var showInfoView: ((String) -> ())? = nil
    var showGoButton: ((Bool) -> ())? = nil
    var pesrAccaunt: ((String) -> ())? = nil
    weak var tableViewDelegate: TableViewDelegate?
    
    static let reuseId = "GKHInputCell"
    
    var fieldid = ""
    var fieldname = ""
    var fieldvalue = ""
    var body = [String: String]()
    var isSelect = true
    @IBOutlet weak var infoButon: UIButton!
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
    // DataSetup
    func setupUI (_ index: Int, _ dataModel: [String: String]) {
        
        if emptyCell() == false {
            infoButon.isHidden = true
            self.fieldid = String(index + 1)
            fieldname = dataModel["id"] ?? ""
            let q = GKHDataSorted.a(dataModel["title"] ?? "")
            
            DispatchQueue.main.async {
                self.operatorsIcon.image = UIImage(named: q.1)
            }
            
            textField.placeholder = q.0
            placeholder = q.0
            
            if q.0 == "Лицевой счет" {
                let h = dataModel["Лицевой счет"]
                if h != "" {
                    textField.text = h
                }
            }
            
            if q.0 == "" {
                textField.placeholder = dataModel["title"] ?? ""
            }
            if q.0 == "ФИО" {
                showFioButton.isHidden = false
            } else {
                showFioButton.isHidden = true
            }
            
            if dataModel["subTitle"] != nil {
                info = dataModel["subTitle"] ?? ""
                infoButon.isHidden = false
            }
            if dataModel["viewType"] != "INPUT" {
                self.textField.isEnabled = false
                isSelect = false
            }
        }
    }
    
    @IBAction func textField(_ sender: UITextField) {
        fieldvalue = textField.text ?? ""
        body.updateValue(fieldid, forKey: "fieldid")
        body.updateValue(fieldname, forKey: "fieldname")
        body.updateValue(textField.text ?? "" , forKey: "fieldvalue")
        haveEmptyCell()
        personalAccaunt()
        tableViewDelegate?.responds(to: #selector(TableViewDelegate.afterClickingReturnInTextField(cell:)))
        tableViewDelegate?.afterClickingReturnInTextField(cell: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //        let previousText:NSString = textField.text! as NSString
        //        let updatedText = previousText.replacingCharacters(in: range, with: string)
        //        print("updatedText > ", updatedText)
        return true
    }
    
    @IBAction func payTapButton(_ sender: UIButton) {
    }
    
    @IBAction func showFIOButton(_ sender: UIButton) {
    }
    
    @IBAction func showInfo(_ sender: UIButton) {
        showInfoView?(info)
    }
    
    /// Проверяем, если поле заполнено, то отправляем в замыкании  true, для отображения кнопки "Продолжить"
    final func haveEmptyCell() {
        if fieldvalue != "" {
            if ( fieldvalue != "" && isSelect == true) {
                showGoButton?(true)
            } else if ( fieldvalue == "" && isSelect == false) {
                showGoButton?(true)
            }
            if ( fieldvalue == "" && isSelect == true) {
                showGoButton?(false)
            }
        }
    }
    /// Проверяем, есть ли заполненные поля. Если да, то не обновляем ячейки
    final func emptyCell() -> Bool {
        
        var result = false
        if ( fieldid != "" || fieldname != "" || fieldvalue != "" ) {
            result = true
        }
        return result
    }
    /// Получаем значение Лицевого счета и отправляем в замыкании
    final func personalAccaunt() {
        if fieldname == "P1" {
            pesrAccaunt?(fieldvalue)
        }
    }
    
}

