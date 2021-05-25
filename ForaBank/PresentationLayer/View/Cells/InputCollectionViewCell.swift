//
//  InputCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 21.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit


class InputCollectionViewCell: UICollectionViewCell, UITextFieldDelegate, EPPickerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var rightButton: UIButton!
    var delegate: updateDelegate?
    var configurateCell = ParameterList()
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.placeholder = configurateCell.mask
        if label.text == configurateCell.title{
            textField.keyboardType = .numberPad
            textField.text = "+7"
    
            if #available(iOS 12.0, *) {
                textField.textContentType = .oneTimeCode
            } else {
                // Fallback on earlier versions
            }
        }
        
        
//        textField.didChangeValue(for: KeyPath<UITextField, Value>)
        
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        if configurateCell?.mask ==  "+7(___)-___-__-__" {
//            textField.text = "+7"
//        }
    }
    func formattedMaskInputs(number: String, maskJson: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//        let maskDirty = configurateCell?[0].mask?.replace(string: "X", replacement: "_")
        guard let mask = configurateCell.mask?.replace(string: "X", replacement: "_") else {
            return ""
        }
//        let mask = configurateCell?[0].mask?.replace(string: "X", replacement: "_")

        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {

            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else if ch == "+" || ch == "(" || ch == ")" || ch == "-" || ch == " " || ch == "/" {
                result.append(ch)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    
    @IBAction func changeValue(_ sender: UITextField) {
        if  ((textField.text?.range(of: "\(configurateCell.regularExpression ?? "")", options:.regularExpression)) != nil) {
            print(true)
        }
//        textField.mask = formattedMaskInputs(number: textField.text ?? "", maskJson: configurateCell?[0].mask?.replace(string: "X", replacement: "_") ?? "" )
//            let textUpdate = formattedMaskInputs(number: textField.text ?? "", maskJson: configurateCell?.mask?.replace(string: "X", replacement: "_") ?? "" )
//            print(textUpdate)
//        if endsWithEdu(str: configurateCell?[0].regularExpression ?? ""){
//            print("USPEX")
//        }
//        if textField.text?.count ?? 0 > configurateCell?.minLength ?? 0{
//            textField.textColor = .red
//        }
        
        
        if textField.text?.count == configurateCell.minLength ?? 0{
            delegate?.requestDict(fieldid: configurateCell.npp ?? 0, fieldname: configurateCell.name ?? "", fieldvalue: textField.text ?? "")
        }
        print(textField.text ?? "")
        delegate?.numberPhone(numberPhone: textField.text ?? "")
        
        let updatedText = sender.text ?? ""
        let cleanPhoneNumber = updatedText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = configurateCell.mask?.replace(string: "_", replacement: "X") ?? ""
        let maskClean = mask.replace(string: "7", replacement: "X") 
//        if string.count + range.location > mask.count {
//            return false
//        }
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        
//        for ch in mask {
//            if index == cleanPhoneNumber.endIndex {
//                break
//            }
//            if ch == "X" {
//                result.append(cleanPhoneNumber[index])
//                index = cleanPhoneNumber.index(after: index)
//            } else if ch == "+" || ch == "(" || ch == ")" || ch == "-" || ch == " " || ch == "/"{
//                result.append(ch)
//            } else {
//                //                    return false
//            }
//        }
        for ch in maskClean where index < cleanPhoneNumber.endIndex {

            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }

//        textField.mask
        textField.text = result
        
    }
    
//    func endsWithEdu(str : String) -> Bool {
//        let regex = try! NSRegularExpression(pattern: "\(configurateCell?[0].regularExpression ?? "")", options: .allowCommentsAndWhitespace)
//        return regex.numberOfMatches(in: str, options: [], range: NSMakeRange(0, str.count)) > 0
//    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact: EPContact) {
          
        let strSearch = "\(String(cleanNumber(number: contact.phoneNumbers[0].phoneNumber) ?? "nil"))"
        guard  let cleanNumeber = cleanNumber(number: strSearch) else {return}
        let numberFormatted = formattedNumberInPhoneContacts(number: String(cleanNumeber.dropFirst()))
              textField.text = "\(numberFormatted)"
                delegate?.numberPhone(numberPhone: textField.text ?? "")
//              delegate?.didInputPaymentValue(value: cleanNumberString(string: numberFormatted))
          }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection: false, subtitleCellType: .phoneNumber)
        contactPickerScene.navigationController?.navigationBar.backgroundColor = UIColor(hexFromString: "EA4644")!

        
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        navigationController.navigationBar.backgroundColor = UIColor(hexFromString: "EA4644")!
        
        navigationController.topViewController?.title = "Контакты"
        navigationController.title = "Контакты"
        navigationController.navigationBar.tintColor = .white
        topMostVC()?.present(navigationController, animated: true, completion: nil)
    }
}

