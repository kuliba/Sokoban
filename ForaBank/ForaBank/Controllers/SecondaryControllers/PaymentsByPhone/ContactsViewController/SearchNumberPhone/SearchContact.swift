//
//  SearchContact.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit

protocol SelectImageDelegate {
    func didSelectImage(image: String)
}

class SearchContact: UIView, UITextFieldDelegate{
    

    @IBOutlet weak var numberTextField: UITextField!
    
    @IBOutlet weak var searchView: SearchContact!
    
    @IBAction func valueChanged(_ sender: UITextField) {
        print("123")
    }
    
    //    @IBOutlet weak var numberTextField2: UITextField!
    var delegate: SelectImageDelegate? = nil
    var searchText: String?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == numberTextField) {
                let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
                let components = newString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)

                let decimalString = components.joined(separator: "") as NSString
                let length = decimalString.length
                let hasLeadingOne = length > 0 && decimalString.hasPrefix("7")

                if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int

                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
                    let formattedString = NSMutableString()

                    if hasLeadingOne {
                        formattedString.append("+7 ")
                        index += 1
                    }

                    if (length - index) > 3 {
                        let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                        formattedString.appendFormat("(%@)", areaCode)
                        index += 3
                    }

                    if length - index > 3 {
                        let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                        formattedString.appendFormat("%@-", prefix)
                        index += 3
                    }

                        let remainder = decimalString.substring(from: index)
                        formattedString.append(remainder)
                        textField.text = formattedString as String
                    return false
                    }
                    else {
                    return true
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
//        self.delegate = self
        roundCorners(corners: .allCorners, radius: 10)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.918, green: 0.922, blue: 0.922, alpha: 1).cgColor
        
        
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
