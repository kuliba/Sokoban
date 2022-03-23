//
//  SearchContact.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit

protocol PassTextFieldText {
    func passTextFieldText(textField: UITextField)
    func showSelfPhoneView(_ value: Bool)
}

extension PassTextFieldText {
    func showSelfPhoneView(_ value: Bool) {}
}

class SearchContact: UIView, UITextFieldDelegate{
    
    
    @IBOutlet weak var numberTextField: MaskedTextField!
    
    @IBAction func didBegin(_ sender: UITextField) {
        print("begin")
    }
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var searchView: SearchContact!
    
    var maskPhone = true
    var delegateNumber: PassTextFieldText? = nil
    var searchText: String?
    
    private let maxNumberCount = 10
    private let regex = try! NSRegularExpression(pattern: "[\\+ \\s-\\(\\)]", options: .caseInsensitive)
//
    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = ""
        let b = phoneNumber.firstLetter()
        let a = b.isStringAnInt
        
        if (!a && b != "(" ) {
            number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: " ")
            if shouldRemoveLastDigit {
                let end = number.index(number.startIndex, offsetBy: number.count-1)
                number = String(number[number.startIndex..<end])
            }
        } else {
        number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
        
        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }

        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }

        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)

        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }
        }
        return number
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var fullString = textField.text ?? ""
        fullString.append(string)
        if range.length == 1 {
            textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
            delegateNumber?.passTextFieldText(textField: numberTextField)

        } else {
            textField.text = format(phoneNumber: fullString)
            delegateNumber?.passTextFieldText(textField: numberTextField)

        }
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        numberTextField.text = ""
        delegateNumber?.passTextFieldText(textField: numberTextField)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegateNumber?.showSelfPhoneView(false)
        return true
    }
    
    func textFieldDidEndEditing(_: UITextField) {
        delegateNumber?.showSelfPhoneView(true)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        numberTextField.delegate = self
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.918, green: 0.922, blue: 0.922, alpha: 1).cgColor
        self.clipsToBounds = true
        
        
    }

}
extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


extension CALayer {

  func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

    let border = CALayer()

    switch edge {
    case .top:
        border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
        break
    case .bottom:
        border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
        break
    case .left:
        border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
        break
    case .right:
        border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
        break
    default:
        break
    }

    border.backgroundColor = color.cgColor;

    addSublayer(border)
  }
}


extension String  {
    var isStringAnInt: Bool {
        return !isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    func firstLetter() -> String {
        guard let firstChar = self.first else {
            return ""
        }
        return String(firstChar)
}

}
