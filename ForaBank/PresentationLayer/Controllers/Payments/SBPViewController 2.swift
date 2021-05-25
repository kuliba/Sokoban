//
//  FreeDetailsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 09.01.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import ReSwift
import Alamofire




protocol SPBViewControllerDelegate {

    func didChangeSource(paymentOption: PaymentOptionType)
    func didChangeDestination(paymentOption: PaymentOptionType)

    func didChangeAmount(amount: Double?)

    func didPressPrepareButton()
    func didPressPaymentButton()
}


class SBPViewController: UIViewController, UITextFieldDelegate, ICellConfiguratorDelegate, FirstViewControllerDelegate, ModalViewControllerDelegate, StoreSubscriber, PaymentDetailsPresenterDelegate, UITextViewDelegate {
    
 
    
    func didFinishPreparation(success: Bool) {
        if success {
            performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)
            
            
            
        } else {
            AlertService.shared.show(title: "Ошибка", message: "При выполнении платежа произошла ошибка, попробуйте ещё раз позже", cancelButtonTitle: "Продолжить", okButtonTitle: nil, cancelCompletion: nil, okCompletion: nil)
        }
    }

    
 

    
    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool) {
        print(isLoading, canAskFee, canMakePayment)
        paymentCompany.changeEnabled(isEnabled: canAskFee)
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func sendValue(value: String) {
        self.dismiss(animated: true) {
            self.nameOfBank.text = value
            print(value)
        }
    }
    
    
    
    func update(text: Double) {
        comissions = 30.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchBank"{
            let searchBankVC = segue.destination as! SearchBanksViewController
            searchBankVC.delegate = self
        } else {
            if amountTextField.text == "" || nameOfBank.text == "Выберите банк получателя"{
                let alert = UIAlertController(title: "Заполните все поля", message: "", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                           
                           self.present(alert, animated: true, completion: nil)
            } else {
                let confirmInfo = segue.destination as! SBPSuccessViewController
                confirmInfo.summ = ("\(amountTextField.text!) ₽")
                confirmInfo.bankOfPayeer = nameOfBank.text!
                confirmInfo.numberOfPayeer = destinationValue as! String
            }
        }
    }
    
    
    @IBOutlet weak var accountNumberNon: UILabel!
    
    @IBOutlet weak var containterView: RoundedEdgeView!

    
    var sourceValue: Any?

    
    
     func didReciveNewValue(value: Any, from configurator: ICellConfigurator) {
           if let sourceConfig = sourceConfigurations?.filter({ $0 == configurator }).first {
               switch (sourceConfig, value) {
               case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                   delegate?.didChangeSource(paymentOption: .option(destinationOption))
                   break
               default:
                   break
               }
               self.sourceConfig = sourceConfig
            self.sourceValue = value
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
               self.destinationConfig = destinationConfig
               self.destinationValue = value
           }
       }
    

    @IBOutlet weak var sourcePagerView: PagerView!
    @IBOutlet weak var destinationPagerView: PagerView!

    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var paymentCompany: ButtonRounded!
    
    @IBOutlet weak var comment: CustomTextField!
    @IBOutlet weak var roundedEdgeText: RoundedEdgeView!

    // outlets select bank
    
    @IBOutlet weak var messageRecipientView: UIView!
    @IBOutlet weak var messageRecipient: UITextView!
    @IBAction func segueButton(_ sender: Any) {
        let controller = SearchBanksViewController()
        controller.delegate = self
        performSegue(withIdentifier: "searchBank", sender: Any?.self)
        self.present(controller, animated: true, completion: nil)

    }

    @IBOutlet weak var selectBank: UILabel!
    @IBOutlet weak var dropDownImage: UIImageView!

    var bankName = String()
    @IBOutlet weak var nameOfBank: UILabel!
    //end outlets
    
    
    @IBAction func amountTextFieldValueChanged(_ sender: Any) {
        delegate?.didChangeAmount(amount: Double(amountTextField.text!.replacingOccurrences(of: ",", with: ".")))
      
//        let dotString = "."
//        var maxLength = 9
//        if (amountTextField.text?.contains(dotString))! {
//                maxLength = 12
//        }
        
        
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradientView() // TODO: Replace with GradientView view
    }
    
    
    @IBAction func didChangeNumberAccount(_ sender: Any) {
//        if numberAcoount.text = "444"{
//
//        }
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
    var delegate: PaymentsDetailsViewControllerDelegate?
    var remittanceSourceView: RemittanceOptionView!
     var remittanceDestinationView: RemittanceOptionView!
     var selectedViewType: Bool = false //false - source; true - destination
     var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    var sourceConfig: Any?
    var destinationConfig: Any?
    var destinationValue: Any?
    var cards = [BankSuggest]()
    var scrollView: UIScrollView!
    var newName: String? = nil
    var id: String? = nil

    
  
    
    var comissions: Double = 10.0
    var numberPayeer: String = ""
    


    
     internal func newState(state: ProductState) {
            //optionsTable.reloadData()
    //        setUpRemittanceViews()
        }
    

    
    

    

    
    private let destinationProviderCardNumber = CardNumberCellProvider()
  private let destinationProviderAccountNumber = AccountNumberCellProvider()
  private let destinationProviderPhoneNumber = PhoneNumberCellProvider()

  
    let placeHolderMessageRecipient = "Сообщение получателю"
     let colorBorderMessageRecipient = UIColor.systemGray.withAlphaComponent(0.5).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectBank.isHidden = true
        amountTextField.delegate = self
        messageRecipient.textColor = UIColor.lightGray
//        nameOfBank.text = bankName
        // Do any additional setup after loading the view.
        self.messageRecipient.delegate = self
        self.messageRecipient.layer.cornerRadius = 5.0
        self.messageRecipient.layer.borderColor = colorBorderMessageRecipient
        self.messageRecipient.text = self.placeHolderMessageRecipient
        self.messageRecipient.layer.borderColor = UIColor.red.cgColor
        self.messageRecipient.textColor = UIColor.systemGray
        
        
        amountTextField.delegate = self
        
        
             if let source = sourceConfigurations, let dest = destinationConfigurations {
                   sourcePagerView.setConfig(config: source)
                   destinationPagerView.setConfig(config: dest)
               }


        
    
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
         self.messageRecipient.layer.borderWidth = 1
         //place Holder Message Recipient off
         if self.messageRecipient.text == self.placeHolderMessageRecipient{
             self.messageRecipient.text = ""
             self.messageRecipient.textColor = .black
         }
     }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.messageRecipient.layer.borderWidth = 0
        //place Holder Message Recipient on
        if self.messageRecipient.text == ""{
            self.messageRecipient.text = self.placeHolderMessageRecipient
            self.messageRecipient.textColor = .systemGray
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 210    // 210 Limit Value
    }
    
    // изменяем textView под размер тексте
    func textViewDidChange(_ textView: UITextView) {
        if textView.numberOfLines() == 1{ //если первая строка
            if self.messageRecipient.heightConstaint?.constant == 70{ //если перешли с 2 на 1 строку
                self.messageRecipient.heightConstaint?.constant = 40 //ставим обычный рамер
            }
        }else if textView.numberOfLines() == 2{ // если вторая строка
            self.messageRecipient.heightConstaint?.constant = 70 // увеличиваем размер textView
        }
    }


   
    
    let taskTextFieldlimitLength = 11

     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         let dotString = ","
         //let characters = ""
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


private extension SBPViewController {
    private func setUpPicker() {
//        picker.layer.cornerRadius = 3
//        pickerImageView.image = pickerImageView.image?.withRenderingMode(.alwaysTemplate)
//        pickerImageView.tintColor = .white
    }

    private func addGradientView() {
        let containerGradientView = GradientView()
        containerGradientView.frame = containterView.frame
        containerGradientView.color1 = UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1)
        containerGradientView.color2 = UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1)
        containterView.insertSubview(containerGradientView, at: 0)
    }

    private func setUpLayout() {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        setUpPicker()
    }
}









private var kAssociationKeyMaxLength: Int = 0



