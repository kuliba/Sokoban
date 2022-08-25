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
    func setupUI (_ index: Int, _ dataModel: [[String: String]]) {
        // Разблокировка ячеек
        self.textField.isEnabled = true
        
        infoButon.isHidden = true
        self.fieldid = String(index + 1)
        fieldname = dataModel[index]["id"] ?? ""
        let q = GKHDataSorted.a(dataModel[index]["title"] ?? "")
        
        DispatchQueue.main.async {
            self.operatorsIcon.image = UIImage(named: q.1)
        }
        
        textField.placeholder = q.0
        placeholder = q.0
        
        if q.0 == "Лицевой счет" {
            let h = dataModel[index]["Лицевой счет"]
            if h != "" {
                textField.text = h
            }
        }
        
        if q.0 == "" {
            textField.placeholder = dataModel[index]["title"] ?? ""
        }
        if q.0 == "ФИО" {
            showFioButton.isHidden = false
        } else {
            showFioButton.isHidden = true
        }
        
        if dataModel[index]["subTitle"] != nil {
            info = dataModel[index]["subTitle"] ?? ""
            infoButon.isHidden = false
        }
        if dataModel[index]["value"] != nil {
            textField.text = dataModel[index]["value"] ?? ""
            fieldvalue = textField.text ?? ""
            body.updateValue(fieldid, forKey: "fieldid")
            body.updateValue(fieldname, forKey: "fieldname")
            body.updateValue(textField.text ?? "" , forKey: "fieldvalue")
            var a = UserDefaults.standard.array(forKey: "body") as? [[String: String]] ?? [[:]]
            a.removeAll()
            a.append(body)
            UserDefaults.standard.set(a, forKey: "body")
        }
        // Блокировка ячеек
        if dataModel[index]["readOnly"] == "true" {
            self.textField.isEnabled = false
            isSelect = true
        }
        
    }
    
    @IBAction func textField(_ sender: UITextField) {
        fieldvalue = textField.text ?? ""
        body.updateValue(fieldid, forKey: "fieldid")
        body.updateValue(fieldname, forKey: "fieldname")
        body.updateValue(textField.text ?? "" , forKey: "fieldvalue")
        personalAccaunt()
        haveEmptyCell()
        tableViewDelegate?.responds(to: #selector(TableViewDelegate.afterClickingReturnInTextField(cell:)))
        tableViewDelegate?.afterClickingReturnInTextField(cell: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        haveEmptyCell()
        //        let previousText:NSString = textField.text! as NSString
        //        let updatedText = previousText.replacingCharacters(in: range, with: string)
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
            } else {
                showGoButton?(false)
            }
        }
        
    }
    
    /// Получаем значение Лицевого счета и отправляем в замыкании
    final func personalAccaunt() {
        if fieldname == "P1" {
            pesrAccaunt?(fieldvalue)
        }
    }
    
}


