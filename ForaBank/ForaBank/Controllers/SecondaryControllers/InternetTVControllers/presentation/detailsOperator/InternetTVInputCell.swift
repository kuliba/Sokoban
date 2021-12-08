//
//  InternetTVInputCell.swift
//  ForaBank
//
//  Created by Роман Воробьев on 04.12.2021.
//

import Foundation
import UIKit

class InternetTVInputCell: UITableViewCell, UITextFieldDelegate, IMsg {
    static let reuseId = "InternetTVInputCell"
    static var iMsg: IMsg? = nil
    static var spinnerValuesSelected = [String : [String : String]]()
    var info = ""
    var spinnerValues = [String : String]()
    var showInfoView: ((String) -> ())? = nil
    var showSelectView: (([String: String], String) -> ())? = nil
    var showGoButton: ((Bool) -> ())? = nil
    var currentElementUI: RequisiteDO? = nil

    var fieldId = ""
    var fieldName = ""
    var fieldValue = ""
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

    @IBOutlet weak var btnShowSelectView: UIButton!
    
    var placeholder = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        showFIOButton.isHidden = true
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        fieldValue = textField.text ?? ""
    }

    func setupUI (_ index: Int, _ item: RequisiteDO, _ qrData: [String: String], additionalList: [AdditionalListModel]) {
        currentElementUI = item
        infoButon.isHidden = true
        fieldId = String(item.order)
        fieldName = item.id ?? ""
        let q = GKHDataSorted.a(item.title ?? "")
        DispatchQueue.main.async {
            self.operatorsIcon.image = UIImage(named: q.1)
        }
        textField.placeholder = q.0
        placeholder = q.0

        if let svg = item.svgImage {
            operatorsIcon.image = svg.convertSVGStringToImage()
        }

        switch (item.viewType) {
        case "INPUT":
            switch (item.type) {
            case "MaskList" :
                setupSelectField(additionalList: additionalList, elementUI: item, q: q, qrData: qrData)
                break
            case "Select" :
                setupSelectField(additionalList: additionalList, elementUI: item, q: q, qrData: qrData)
                break
            case .none:
                setupInputField(additionalList: additionalList, item: item, q: q, qrData: qrData)
                break
            case .some(_):
                setupInputField(additionalList: additionalList, item: item, q: q, qrData: qrData)
                break
            }
        case "SELECT":
            //fillSelect(elementUI)
            break
        case .none: break
        case .some(_): break
        }
        
        if item.readOnly {
            textField.isEnabled = false
            btnShowSelectView.isEnabled = false
        } else {
            textField.isEnabled = true
            btnShowSelectView.isEnabled = true
        }
    }

    private func setupInputField(additionalList: [AdditionalListModel], item: RequisiteDO, q: (String, String), qrData: [String: String]) {
        btnShowSelectView.isHidden = true

        let field = additionalList.filter { it in
            it.fieldName == item.id
        }
        if field.count > 0 {
            textField.text = field.first?.fieldValue
            InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId,
                                                                       "fieldname" : fieldName,
                                                                       "fieldvalue" : field.first?.fieldValue ?? "-1"]
        } else {
            if let el = InternetTVDetailsFormViewModel.additionalDic[item.id ?? ""], !el.isEmpty {
                textField.text = el["fieldvalue"]
            } else {
                textField.text = item.content
                InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId,
                                                                           "fieldname" : fieldName,
                                                                           "fieldvalue" : item.content ?? ""]
            }
        }
        if q.0 == "Лицевой счет" {
            let qr = qrData.filter { $0.key == "Лицевой счет"}
            if let qrUnw = qr.first?.value, qrUnw != "" {
                textField.text = qrUnw
            }
        }
        if q.0 == "" {
            textField.placeholder = item.title
        }
        if q.0 == "ФИО" {
            showFioButton.isHidden = false
        } else {
            showFioButton.isHidden = true
        }
        if item.subTitle != nil {
            info = item.subTitle ?? ""
            infoButon.isHidden = false
        }
    }

    private func setupSelectField(additionalList: [AdditionalListModel], elementUI: RequisiteDO, q: (String, String), qrData: [String: String]) {
        btnShowSelectView.isHidden = false
        spinnerValues = [String : String]()
        let arr = elementUI.dataType?.split(separator: ",")
        arr?.forEach { it in
            if (!it.replacingOccurrences(of: "=", with: " ").isEmpty) {
                let arr2 = it.split(separator: "=")
                if (arr2.count > 1) {
                    let key = String(arr2[0])
                    let value = String(arr2[1])
                    spinnerValues[key] = value
                }
            }
        }

        if let fill = InternetTVDetailsFormViewModel.additionalDic[elementUI.id ?? "-1"] {
            textField.text = spinnerValues[fill["fieldvalue"] ?? "-1"]
        }

        InternetTVInputCell.spinnerValuesSelected.forEach { key,  value in
            if key == elementUI.id {
                textField.text = spinnerValues[value.first?.key ?? "-1"]
            }
        }

        if textField.text?.isEmpty ?? true {
            let field = additionalList.filter { it in
                it.fieldName == elementUI.id
            }
            if field.count > 0 {
                textField.text = spinnerValues[field.first?.fieldValue ?? "-1"]
                InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId,
                                                                           "fieldname" : fieldName,
                                                                           "fieldvalue" : field.first?.fieldValue ?? "-1"]
            } else {
                textField.text = spinnerValues[elementUI.content ?? "-1"]
                InternetTVDetailsFormViewModel.additionalDic[fieldName ?? "-1"] = ["fieldid" : fieldId,
                                                                                   "fieldname" : fieldName,
                                                                                   "fieldvalue" : elementUI.content ?? "-1"]
            }
        }

        if q.0 == "Лицевой счет" {
            let qr = qrData.filter { $0.key == "Лицевой счет"}
            if let qrUnw = qr.first?.value, qrUnw != "" {
                textField.text = qrUnw
            }
        }
        if q.0 == "" {
            textField.placeholder = elementUI.title
        }
        if q.0 == "ФИО" {
            showFioButton.isHidden = false
        } else {
            showFioButton.isHidden = true
        }
        if elementUI.subTitle != nil {
            info = elementUI.subTitle ?? ""
            infoButon.isHidden = false
        }
    }

    @IBAction func textField(_ sender: UITextField) {
        fieldValue = textField.text ?? ""
//        body.updateValue(fieldId, forKey: "fieldid")
//        body.updateValue(fieldName, forKey: "fieldname")
//        body.updateValue(textField.text ?? "" , forKey: "fieldvalue")
        //perAcc = body["Лицевой счет"] ?? ""
        haveEmptyCell()
        InternetTVDetailsFormViewModel.additionalDic[fieldName ?? "-1"] = ["fieldid" : fieldId, "fieldname" : fieldName, "fieldvalue" : textField.text ?? ""]
        //tableViewDelegate?.responds(to: #selector(InternetTableViewDelegate.afterClickingReturnInTextField(cell:)))
        //tableViewDelegate?.afterClickingReturnInTextField(cell: self)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
        fieldValue = updatedText
//        body.updateValue(fieldId, forKey: "fieldid")
//        body.updateValue(fieldName, forKey: "fieldname")
//        body.updateValue(fieldValue , forKey: "fieldvalue")
        //perAcc = body["Лицевой счет"] ?? ""
        haveEmptyCell()

        InternetTVDetailsFormViewModel.additionalDic[fieldName ?? "-1"] = ["fieldid" : fieldId, "fieldname" : fieldName, "fieldvalue" : fieldValue]
//        tableViewDelegate?.responds(to: #selector(InternetTableViewDelegate.afterClickingReturnInTextField(cell:)))
//        tableViewDelegate?.afterClickingReturnInTextField(cell: self)

        return true
    }

    @IBAction func payTapButton(_ sender: UIButton) {
    }

    @IBAction func showFIOButton(_ sender: UIButton) {
    }

    @IBAction func showInfo(_ sender: UIButton) {
        showInfoView?(info)
    }

    @IBAction func showSelectView(_ sender: Any) {
        InternetTVInputCell.iMsg = self
        showSelectView?(spinnerValues, currentElementUI?.id ?? "-1")
    }
    
    final func haveEmptyCell() {
        if (fieldValue != "" && isSelect == true) {
            showGoButton?(true)
        } else if (fieldValue == "" && isSelect == false) {
            showGoButton?(true)
        }
        if (fieldValue == "" && isSelect == true) {
            showGoButton?(false)
        }
    }

    final func emptyCell() -> Bool {
        var result = false
        if ( fieldId != "" || fieldName != "" || fieldValue != "" ) {
            result = true
        }
        return result
    }

    func handleMsg(what: Int) {
        InternetTVInputCell.spinnerValuesSelected.forEach { key,  value in
            if key == currentElementUI?.id {
                textField.text = spinnerValues[value.first?.key ?? "-1"]
                InternetTVDetailsFormViewModel.additionalDic[fieldName ?? "-1"] = ["fieldid" : fieldId,
                                                                                   "fieldname" : fieldName,
                                                                                   "fieldvalue" : value.first?.key ?? "-1"]
            }
        }
    }
}
