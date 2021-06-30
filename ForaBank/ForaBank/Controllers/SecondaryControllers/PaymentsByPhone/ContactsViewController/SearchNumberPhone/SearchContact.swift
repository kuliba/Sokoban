//
//  SearchContact.swift
//  ForaBank
//
//  Created by Дмитрий on 23.06.2021.
//

import UIKit

protocol MyPickerDelegate: NSObjectProtocol {
    func didSelectSomething(some: String)
}
protocol PizzaDelegate {
    func onPizzaReady(type: String)
}

class SearchContact: UIView{
    func doSomethingWith(data: String) {
        numberTextField.text = data
    }
    
    func passUpdateData(data: String) {
        numberTextField.text = data
    }
    
    func onPizzaReady(type: String) {
         numberTextField.text = type
    }
    
    func didSelectSomething(some: String) {
        numberTextField.text = some
    }
    

   
    weak var myDelegate: MyPickerDelegate?
    var searchText: String?
 
    // this is going to be our container object
      
     //This Boolean, you can choose whatever you want.

    @IBOutlet weak var numberTextField: UITextField!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
//        self.delegate = self
        roundCorners(corners: .allCorners, radius: 10)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        
    }
    
    @IBAction func changeValue(_ sender: UITextField) {
//        myDelegate?.didSelectSomething(some: numberTextField.text ?? "")
        print(numberTextField.text)
        
    }
    
    override class func awakeFromNib() {
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
