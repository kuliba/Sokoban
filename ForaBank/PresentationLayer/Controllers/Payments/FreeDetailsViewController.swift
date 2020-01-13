//
//  FreeDetailsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 09.01.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import ReSwift

protocol FreeDetailsViewControllerDelegate {

    func didChangeSource(paymentOption: PaymentOptionType)
    func didChangeDestination(paymentOption: PaymentOptionType)

    func didChangeAmount(amount: Double?)

    func didPressPrepareButton()
    func didPressPaymentButton()
}


class FreeDetailsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sourcePagerView: PagerView!
    @IBOutlet weak var numberAcoount: CustomTextField!
    @IBOutlet weak var kppBank: CustomTextField!
    @IBOutlet weak var innBank: CustomTextField!
    @IBOutlet weak var bikBank: CustomTextField!
    @IBOutlet weak var textField: CustomTextField!
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var pagerView: PagerView!
    @IBOutlet weak var amountTextField: UITextField!
    
    
    @IBAction func amountTextFieldValueChanged(_ sender: Any) {
        delegate?.didChangeAmount(amount: Double(amountTextField.text!.replacingOccurrences(of: ",", with: ".")))
      
        let dotString = "."
        var maxLength = 9
        if (amountTextField.text?.contains(dotString))! {
                maxLength = 12
            }
        
        
       
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    var presenter: PaymentDetailsPresenter?
    var sourceConfigurations: [ICellConfigurator]?
    var destinationConfigurations: [ICellConfigurator]?
    var delegate: FreeDetailsViewControllerDelegate?
    var remittanceSourceView: RemittanceOptionView!
     var remittanceDestinationView: RemittanceOptionView!
     var selectedViewType: Bool = false //false - source; true - destination
     var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    

  private let destinationProviderCardNumber = CardNumberCellProvider()
  private let destinationProviderAccountNumber = AccountNumberCellProvider()
  private let destinationProviderPhoneNumber = PhoneNumberCellProvider()

  
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.delegate = self
    
        // Do any additional setup after loading the view.
  
        self.sourcePagerView.pageControl.backgroundColor = UIColor(red: 241/255, green: 63/255, blue: 56/255, alpha: 1)
    
    
           if let source = sourceConfigurations{
               sourcePagerView.setConfig(config: source)
             
           }
           
    }
    
    
    let taskTextFieldlimitLength = 11

     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         let dotString = ","
         let characters = ""
         var maxLength = 9
         if (textField.text?.contains(dotString))! {
             maxLength = 12
         }
         if string == ","{
             textField.text = textField.text! + ","
             maxLength = 12
         }
                 
         if let text = textField.text{
             textField.text = "\(text)"
             
             let isDeleteKey = string.isEmpty
             if !isDeleteKey {
                 if text.contains(dotString) {
                     if text.components(separatedBy: dotString)[1].count == 2 || string == ","  {
                      return false
                     }
                 }
             }
         }
     guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= maxLength // replace 30 for your max length value
     }
    
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITextField {

    @IBInspectable var paddingLeft: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }

    @IBInspectable var paddingRight: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
}
extension FreeDetailsViewController: OptionPickerDelegate {
    func setSelectedOption(option: String?) {
        // Set current option to selected one if not just dismissed
        if let option = option {
            pickerLabel.text = option
        }
        pickerButton.isEnabled = true
    }
}
extension FreeDetailsViewController: RemittancePickerDelegate {
    func didSelectOptionView(optionView: RemittanceOptionView?, paymentOption: PaymentOption?) {
        if selectedViewType {
            let frame = remittanceDestinationView.frame
            remittanceDestinationView.removeFromSuperview()
            remittanceDestinationView = optionView
            remittanceDestinationView.frame = frame
            remittanceDestinationView.translatesAutoresizingMaskIntoConstraints = true

        } else {
            let frame = remittanceSourceView.frame
            remittanceSourceView.removeFromSuperview()
            remittanceSourceView = optionView
            remittanceSourceView.frame = frame
            remittanceSourceView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
}
extension FreeDetailsViewController: ICellConfiguratorDelegate {
    func didReciveNewValue(value: Any, from configurator: ICellConfigurator) {
        if let sourceConfig = sourceConfigurations?.filter({ $0 == configurator }).first {
            switch (sourceConfig, value) {
            case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                delegate?.didChangeSource(paymentOption: .option(destinationOption))
                break
            default:
                break
            }
        } else if let destinationConfig = destinationConfigurations?.filter({ $0 == configurator }).first {
            switch (destinationConfig, value) {
            case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                delegate?.didChangeDestination(paymentOption: .option(destinationOption))
                break
            case (is CardNumberPagerItem, let destinationOption as String):
                delegate?.didChangeDestination(paymentOption: .cardNumber(destinationOption))
                break
            case (is PhoneNumberPagerItem, let destinationOption as String):
                delegate?.didChangeDestination(paymentOption: .phoneNumber(destinationOption))
                break
            case (is AccountNumberPagerItem, let destinationOption as String):
                delegate?.didChangeDestination(paymentOption: .accountNumber(destinationOption))
                break
            default:
                break
            }
        }
    }
}
