import Foundation
import UIKit

class InternetTVInputCell: UITableViewCell, UITextViewDelegate, IMsg {
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
    
    @IBOutlet weak var textView: UITextView!
    
    
    var placeholder = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        showFIOButton.isHidden = true
        textView.delegate = self
        //textField.clearButtonMode = .whileEditing
    }

    func textViewShouldBeginEditing(_ textView: UITextView)-> Bool {
        textView.resignFirstResponder()
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        fieldValue = textView.text ?? ""
    }

    func setupUI (_ index: Int, _ item: RequisiteDO, _ qrData: [String: String], additionalList: [AdditionalListModel]) {
        currentElementUI = item
        infoButon.isHidden = true
        fieldId = String(item.order)
        fieldName = item.id ?? ""
        //textField.placeholder = item.title
        placeholderLable.text = item.title
        //textView.text = item.title

        if item.subTitle != nil {
            info = item.subTitle ?? ""
            infoButon.isHidden = false
        } else {
            infoButon.isHidden = true
        }
//        let q = GKHDataSorted.a(item.title ?? "")
//        textField.placeholder = q.0
//        placeholder = q.0


        DispatchQueue.main.async {
            if let svg = item.svgImage {
                self.operatorsIcon.image = svg.convertSVGStringToImage()
            } else {
                self.operatorsIcon.image = nil
            }
        }

        switch (item.viewType) {
        case "INPUT":
            switch (item.type) {
            case "MaskList" :
                setupSelectField(additionalList: additionalList, elementUI: item, qrData: qrData)
                break
            case "Select" :
                setupSelectField(additionalList: additionalList, elementUI: item, qrData: qrData)
                break
            case .none:
                setupInputField(additionalList: additionalList, item: item, qrData: qrData)
                break
            case .some(_):
                setupInputField(additionalList: additionalList, item: item, qrData: qrData)
                break
            }
        case "SELECT":
            //fillSelect(elementUI)
            break
        case .none:
            setupInputField(additionalList: additionalList, item: item, qrData: qrData)
            break
        case .some(_):
            setupInputField(additionalList: additionalList, item: item, qrData: qrData)
            break
        }
        
        if item.readOnly {
            textView.isEditable = false
            btnShowSelectView.isEnabled = false
        } else {
            textView.isEditable = true
            btnShowSelectView.isEnabled = true
        }
    }

    private func setupInputField(additionalList: [AdditionalListModel], item: RequisiteDO, qrData: [String: String]) {
        btnShowSelectView.isHidden = true

        let field = additionalList.filter { it in
            it.fieldName == item.id
        }
        if field.count > 0 {
            textView.text = field.first?.fieldValue
            InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId,
                                                                       "fieldname" : fieldName,
                                                                       "fieldvalue" : field.first?.fieldValue ?? "-1"]
        } else {
            if let el = InternetTVDetailsFormViewModel.additionalDic[item.id ?? ""], !el.isEmpty {
                textView.text = el["fieldvalue"]
            } else {
                textView.text = item.content
                InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId,
                                                                           "fieldname" : fieldName,
                                                                           "fieldvalue" : item.content ?? ""]
            }
        }

        if isPersonalAcc(strCheck: item.title ?? ""), let textValue = qrData["Лицевой счет"]  {
            textView.text = textValue
            InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId,
                                                                       "fieldname" : fieldName,
                                                                       "fieldvalue" : textValue]
        }
    }

    private func setupSelectField(additionalList: [AdditionalListModel], elementUI: RequisiteDO, qrData: [String: String]) {
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
            textView.text = spinnerValues[fill["fieldvalue"] ?? "-1"]
        }

        InternetTVInputCell.spinnerValuesSelected.forEach { key,  value in
            if key == elementUI.id {
                textView.text = spinnerValues[value.first?.key ?? "-1"]
            }
        }

        if textView.text?.isEmpty ?? true {
            let field = additionalList.filter { it in
                it.fieldName == elementUI.id
            }
            if field.count > 0 {
                textView.text = spinnerValues[field.first?.fieldValue ?? "-1"]
                InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId,
                                                                           "fieldname" : fieldName,
                                                                           "fieldvalue" : field.first?.fieldValue ?? "-1"]
            } else {
                textView.text = spinnerValues[elementUI.content ?? "-1"]
                InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId,
                                                                           "fieldname" : fieldName,
                                                                           "fieldvalue" : elementUI.content ?? "-1"]
            }
        }
    }

    @IBAction func textField(_ sender: UITextField) {
        fieldValue = textField.text ?? ""
        checkForEmpty()
        InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId, "fieldname" : fieldName, "fieldvalue" : textField.text ?? ""]
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let previousText:NSString = textView.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: text)
        fieldValue = updatedText
        checkForEmpty()
        InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId, "fieldname" : fieldName, "fieldvalue" : fieldValue]
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
    
    final func checkForEmpty() {
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
                //textField
                textView.text = spinnerValues[value.first?.key ?? "-1"]
                InternetTVDetailsFormViewModel.additionalDic[fieldName] = ["fieldid" : fieldId,
                                                                           "fieldname" : fieldName,
                                                                           "fieldvalue" : value.first?.key ?? "-1"]
            }
        }
    }

    func isPersonalAcc(strCheck: String) -> Bool {
        if strCheck.isEmpty {return false}
        let str = strCheck.lowercased()
        if str.contains("счетч") {return false}
        return str.contains("счет")
                || str.contains("лицев")
                || str.contains("номер")
                || str.contains("абонент")
    }
}
