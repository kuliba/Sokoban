//
//  InternetTVInputCell.swift
//  ForaBank
//
//  Created by Роман Воробьев on 04.12.2021.
//

import Foundation
import UIKit

class InternetTVInputCell: UITableViewCell, UITextFieldDelegate {
    static let reuseId = "InternetTVInputCell"
    var info = ""
    var showInfoView: ((String) -> ())? = nil
    var showGoButton: ((Bool) -> ())? = nil

    weak var tableViewDelegate: InternetTableViewDelegate?

    var fieldId = ""
    var fieldName = ""
    var fieldValue = ""
    var item: RequisiteDO?
    var body = [String: String]()
    var perAcc = ""
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
        fieldValue = textField.text ?? ""
    }

    func setupUI (_ index: Int, _ item: RequisiteDO, _ qrData: [String: String]) {
        infoButon.isHidden = true
        self.item = item
        fieldId = String(index + 1)
        fieldName = item.id ?? ""
        let q = GKHDataSorted.a(item.title ?? "")
        DispatchQueue.main.async {
            self.operatorsIcon.image = UIImage(named: q.1)
        }
        textField.placeholder = q.0
        placeholder = q.0
        textField.text = item.content
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
        if item.readOnly {
            textField.isEnabled = false
        } else {
            textField.isEnabled = true
        }
    }

    @IBAction func textField(_ sender: UITextField) {
        print("proc01 textField afterClickingReturnInTextField")
        fieldValue = textField.text ?? ""
        body.updateValue(fieldId, forKey: "fieldid")
        body.updateValue(fieldName, forKey: "fieldname")
        body.updateValue(textField.text ?? "" , forKey: "fieldvalue")
        perAcc = body["Лицевой счет"] ?? ""
        haveEmptyCell()
        tableViewDelegate?.responds(to: #selector(InternetTableViewDelegate.afterClickingReturnInTextField(cell:)))
        tableViewDelegate?.afterClickingReturnInTextField(cell: self)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)

        print("proc01 shouldChangeCharactersIn \(updatedText)")
        fieldValue = updatedText
        body.updateValue(fieldId, forKey: "fieldid")
        body.updateValue(fieldName, forKey: "fieldname")
        body.updateValue(fieldValue , forKey: "fieldvalue")
        perAcc = body["Лицевой счет"] ?? ""
        haveEmptyCell()
        tableViewDelegate?.responds(to: #selector(InternetTableViewDelegate.afterClickingReturnInTextField(cell:)))
        tableViewDelegate?.afterClickingReturnInTextField(cell: self)

        return true
    }

    @IBAction func payTapButton(_ sender: UIButton) {
    }

    @IBAction func showFIOButton(_ sender: UIButton) {
    }

    @IBAction func showInfo(_ sender: UIButton) {
        showInfoView?(info)
    }

    final func haveEmptyCell() {

        if ( fieldValue != "" && isSelect == true) {
            showGoButton?(true)
        } else if ( fieldValue == "" && isSelect == false) {
            showGoButton?(true)
        }
        if ( fieldValue == "" && isSelect == true) {
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
}
