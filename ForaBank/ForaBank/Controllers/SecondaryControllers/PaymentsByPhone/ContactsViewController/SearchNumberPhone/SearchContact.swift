//
//  SearchContact.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit

protocol passTextFieldText {
    func passTextFieldText(textField: UITextField)
}

class SearchContact: UIView, UITextFieldDelegate{
    
    
    @IBOutlet weak var numberTextField: MaskedTextField!
    
    @IBAction func didBegin(_ sender: UITextField) {
        print("begin")
    }
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var searchView: SearchContact!
    
    var maskPhone = true
    var delegateNumber: passTextFieldText? = nil
    var searchText: String?
    
    private let maxNumberCount = 10
    private let regex = try! NSRegularExpression(pattern: "[\\+ \\s-\\(\\)]", options: .caseInsensitive)
//
    private func format(phoneNumber: String, shouldRemoveLastDigit: Bool) -> String {
           guard !(shouldRemoveLastDigit && phoneNumber.count <= 2) else { return "" }

           let range = NSString(string: phoneNumber).range(of: phoneNumber)
           var number = regex.stringByReplacingMatches(in: phoneNumber, options: [], range: range, withTemplate: "")

           if number.count > maxNumberCount {
               let maxIndex = number.index(number.startIndex, offsetBy: maxNumberCount)
               number = String(number[number.startIndex..<maxIndex])
           }

           if shouldRemoveLastDigit {
               let maxIndex = number.index(number.startIndex, offsetBy: number.count - 1)
               number = String(number[number.startIndex..<maxIndex])
           }

           let maxIndex = number.index(number.startIndex, offsetBy: number.count)
           let regRange = number.startIndex..<maxIndex

           if number.count < 10 {
               let pattern = "(\\d{3})(\\d{3})(\\d{2})(\\d+)"
               number = number.replacingOccurrences(of: pattern, with: "($1) $2-$3-$4", options: .regularExpression, range: regRange)
           } else {
               let pattern = "(\\d{3})(\\d{3})(\\d{2})(\\d+)"
               number = number.replacingOccurrences(of: pattern, with: "($1) $2-$3-$4", options: .regularExpression, range: regRange)
           }

           return number
       }
   
    
    @IBAction func valueChanged(_ sender: UITextField) {
//        delegate2?.add_Contact(name: numberTextField.text ?? "")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegateNumber?.passTextFieldText(textField: numberTextField)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           var fullString = (textField.text ?? "") + string
                if string == "" {
                    fullString = ""
                }
        if maskPhone {
            textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: range.length == 1)
        } else {
            textField.text = fullString
        }
//        delegateNumber?.passTextFieldText(text: fullString )
           return false
       }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        numberTextField.addTarget(self, action:Selector("yourWeightValueChanged:"), for:.valueChanged)
        numberTextField.delegate = self
//        roundCorners(corners: .allCorners, radius: 10)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.918, green: 0.922, blue: 0.922, alpha: 1).cgColor
        self.clipsToBounds = true
        
    }

    // other usual outlets

//       func initialize() {
//
//          // first: load the view hierarchy to get proper outlets
//          let name = String(describing: type(of: self))
//          let nib = UINib(nibName: name, bundle: .main)
//          nib.instantiate(withOwner: self, options: nil)
//
//          // next: append the container to our view
//          self.addSubview(self.containerView)
//          self.containerView.translatesAutoresizingMaskIntoConstraints = false
//          NSLayoutConstraint.activate([
//              self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
//              self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//              self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//              self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//          ])
//      }

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
