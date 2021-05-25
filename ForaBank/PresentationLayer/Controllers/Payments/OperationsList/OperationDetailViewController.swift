//
//  OperationDetailViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.06.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import ReSwift
import Alamofire

// MARK: - InputsValue
struct InputsValue: Codable {
    var additional: [Additionals]
}

// MARK: - Additional
struct Additionals: Codable {
    let fieldid: Int
    let fieldname, fieldvalue: String
}


protocol OperationDetailViewControllerDelegate {

    func didChangeSource(paymentOption: PaymentOptionType)
    func didChangeDestination(paymentOption: PaymentOptionType)

    func didChangeAmount(amount: Double?)

    func didPressPrepareButton()
    func didPressPaymentButton()
}

protocol ScanDelegate{
    func passString(scandata: String)
}
protocol updateDelegate {
    func numberPhone(numberPhone: String)
    func requestDict(fieldid: Int, fieldname: String, fieldvalue: String)
}

class OperationDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DataEnteredDelegate, updateDelegate{
  
    func userDidEnterInformation(array: [String]) {
        arrayData = array
    }
    @IBOutlet weak var currentCode: UILabel!
    var image: UIImage?
    var numberCard = String()
    var numberPhone = String()
    @IBOutlet weak var amountTextFiel: CustomTextField!
    var delegateCV: updateDelegate?
    var presenter: PaymentDetailsPresenter?
     var sourceConfigurations: [ICellConfigurator]?
     var destinationConfigurations: [ICellConfigurator]?
     var delegate: OperationDetailViewControllerDelegate?
     var remittanceSourceView: RemittanceOptionView!
      var remittanceDestinationView: RemittanceOptionView!
    var sourceValue: PaymentOption? {
        didSet {
            currentCode.text = getSymbol(forCurrencyCode: sourceValue?.currencyCode ?? "RUB")
        }
    }
    var sourceConfig: Any?
    var destinationConfig: Any?
    var destinationValue: Any?
    var scanDelegate: ScanDelegate?
    var profile: Profile?
    var cardNumber = String()
    var dataComission: DataClass?
    var requestJson : [InputsValue?] = [] {
        didSet{
//                loaderView.isHidden = false
//                activityIndicator.isHidden = false
//                activityIndicator.startAnimation()
//
//
//                NetworkManager.shared().getAnywayPaymentBegin(numberCard: "\(self.numberCard)", puref: self.operationList.code) { (success, anywayPaymentbegin, errorMessage)
//                    if anywayPaymentbegin.result != "ERROR"{
//
//                        NetworkManager.shared().getAnywayPayment { (success, anywayPayment, errorMessage) in
//                            if success ?? false {
//                                print(anywayPayment)
//                                NetworkManager.shared().getAnywayPaymentFinal(memberId: "mobilePhone", amount: self.amountTextFiel.text, numberPhone: self.numberPhone) { (success, anywayPayments, errorMessage) in
//                                    if success ?? false{
//
//                                        if anywayPayments[0]?.data?.finalStep == 1 {
//                                            anywayPayments[0]?.data?.commission
//                                            self.performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)
//
//                                            self.loaderView.isHidden = true
//                                            self.activityIndicator.stopAnimating()
//
//                                        }
//                                    } else{
//                                        AlertService.shared.show(title: "Ошибка", message: "\(errorMessage ?? "")", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
//                                        self.loaderView.isHidden = true
//                                        self.activityIndicator.stopAnimating()
//                                    }
//                                }
//
//                            } else {
//                                print(anywayPayment)
//                                AlertService.shared.show(title: "Ошибка", message: "\(errorMessage ?? "")", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
//                                self.loaderView.isHidden = true
//                                self.activityIndicator.stopAnimating()
//                            }
//                        }
//                    } else {
//                        AlertService.shared.show(title: "Ошибка", message: "\(errorMessage )", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
//                        self.loaderView.isHidden = true
//                        self.activityIndicator.stopAnimating()
//                    }
//                }
//
//
            }
        }
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!
    func requestDict(fieldid: Int, fieldname: String, fieldvalue: String) {
        self.requestJson.append((InputsValue(additional: [Additionals(fieldid: fieldid, fieldname:fieldname, fieldvalue: fieldvalue)])))
        if requestJson.count == operationList.parameterList?.count ?? 0 + 1{
            
        }
    }
//    @IBOutlet weak var sumLabel: UILabel!
    
    
    @IBAction func scanButton(_ sender: Any) {
       
    performSegue(withIdentifier: "scan", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan", let secondViewController = segue.destination as? ScannerViewController  {
               secondViewController.delegate = self
           } else if segue.identifier == "fromPaymentToPaymentVerification" {
            if let destinationVC = segue.destination as? RegistrationCodeVerificationViewController {
                destinationVC.segueId = "serviceOperation"
                    destinationVC.sourceConfig = destinationConfig
                    destinationVC.sourceValue = sourceValue
                destinationVC.destinationConfig = sourceConfigurations
                destinationVC.destinationValue = self.numberPhone
                destinationVC.operationSum = String(dataComission?.amount ?? 0.0)
                destinationVC.commission = String(dataComission?.commission ?? 0.0)
                destinationVC.currencyLable = String(getSymbol(forCurrencyCode: sourceValue?.currencyCode ?? "RUB") ?? "RUB")
                
//                    PaymentOption(id: 0.0, name: "\(String(describing: titleLabel.text!))", type: .paymentOption, sum: Double(amountTextFiel.text!)!, number: self.numberPhone, maskedNumber: "", provider: "", productType: .allProduct, maskSum: "")
//                destinationVC.operationSum = amountTextFiel.text
            }
        }
       }
    @IBOutlet var ViewForCollectionView: UIView!
    func newState(state: VerificationCodeState) {
        guard state.isShown == true else {
            return
        }
    }
    func numberPhone(numberPhone: String) {
        self.numberPhone = numberPhone
    }
    
    @IBOutlet weak var sourcePagerView: PagerView!

  
    @IBOutlet weak var titleLabel: UILabel!
    var operationList = OperationsDetails()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
              if navigationController == nil {
                  dismiss(animated: true, completion: nil)
              }
    }
    
    var arrayData = [String()]{
        didSet{
            if arrayData.count > 2{
                viewWillLayoutSubviews()
          
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(arrayData)")
        self.collectionView!.reloadData()
        self.collectionView!.setNeedsDisplay()
    }
    
    private let destinationProviderCardNumber = CardNumberCellProvider()
    private let destinationProviderAccountNumber = AccountNumberCellProvider()
    private let destinationProviderPhoneNumber = PhoneNumberCellProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let codeOperation = self.operationList.code else { return }
        let sourceProvider = PaymentOptionCellProvider()
        sendButton.changeEnabled(isEnabled: false)
//        sourceProvider.isLoading = false
        sourceConfigurations = [
            PaymentOptionsPagerItem(provider: sourceProvider, delegate: self)
                     ]
        
        loaderView.isHidden = true
        activityIndicator.stopAnimating()
        amountTextFiel.placeholder = "\(operationList.minSumList?[0] ?? 0)Р - \(operationList.maxSumList?[0] ?? 0)Р"
        
        if let source = sourceConfigurations{
              sourcePagerView.setConfig(config: source)
//            sourceProvider.getData { (paymentsOptions) in
//                self.didReciveNewValue(value: paymentsOptions, from: source[0] as NSObject as! ICellConfigurator)
////                sourceProvider.isLoading = false
//    //            self.sourcePagerView.reloadInputViews()
////                delegate?.didChangeSource(paymentOption: .option(sourceValue as! PaymentOption))
////                presenter?.didChangeSource(paymentOption: )
//            }
          }
        
 
        sourceConfigurations = [
        PaymentOptionsPagerItem(provider: sourceProvider, delegate: self)
        ]
       
        
        collectionView.register(UINib(nibName: "InputCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InputCollectionViewCell")
        titleLabel.text = operationList.nameList?[0].value
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if operationList.parameterList?.count ?? 0 >= 3 {
            collectionView.heightConstaint?.constant = 200
            collectionView.reloadInputViews()
        } else if operationList.parameterList?.count ?? 0 == 1{
            collectionView.heightConstaint?.constant = 60
            collectionView.reloadInputViews()
        }
        return operationList.parameterList?.count ?? 0
    }
    
    func base64Convert(base64String: String?) -> UIImage{
        if (base64String?.isEmpty)! {
            return #imageLiteral(resourceName: "no_image_found")
        }else {
            // !!! Separation part is optional, depends on your Base64String !!!
            let temp = base64String?.components(separatedBy: ",")
            let dataDecoded : Data = Data(base64Encoded: temp![0], options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage!
        }
      }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputCollectionViewCell", for: indexPath) as! InputCollectionViewCell
        cell.label.text = operationList.parameterList?[indexPath.row].title
        if image != nil, indexPath.row == 0 {
            cell.image.image = image
//            cell.textField.leadingAnchor.
//            cell.textField.translatesAutoresizingMaskIntoConstraints = false
//            cell.image.translatesAutoresizingMaskIntoConstraints = false
//            cell.textField.constraints

        } else {
            cell.textField.translatesAutoresizingMaskIntoConstraints = false
            cell.image.isHidden = true
            cell.addConstraint(NSLayoutConstraint(item: cell.textField!, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1, constant: 8))
            cell.addConstraint(NSLayoutConstraint(item: cell.textField!, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: -8))
//            cell.textField.frame.size.width = collectionView.frame.width
//            cell.textField.leftAnchor.constraint(equalTo: image, constant: 35).isActive = true

        }
        
        cell.textField.placeholder = operationList.parameterList?[0].mask
        cell.configurateCell = operationList.parameterList?[0] ?? ParameterList()
        if arrayData.count > 2{
            cell.textField.text = arrayData[indexPath.row]
        }
        cell.delegate = self
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "myNotification"), object: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if operationList.parameterList?.count ?? 0 >= 3 {
//            collectionView.reloadInputViews()
            return CGSize(width: UIScreen.main.bounds.width, height: self.collectionView.bounds.height/4)
        } else {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
        }
    }
    
    @IBOutlet weak var sendButton: ButtonRounded!
    
    @IBAction func amountTextFieldChanged(_ sender: Any) {
        if amountTextFiel.text == ""{
            sendButton.changeEnabled(isEnabled: false)
        }
        if let amountDoubleType = Double(amountTextFiel.text! + ".00") {
            if amountDoubleType >  (sourceValue as? PaymentOption)?.value ?? 0.0{
                sendButton.changeEnabled(isEnabled: false)
            } else {
                sendButton.changeEnabled(isEnabled: true)
            }
        }
    }
    
    @IBAction func paymentButton(_ sender: UIButton) {
        loaderView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimation()
        var variableTransferValue = String()
        if self.numberCard.count > 17{
            guard let sourceVariable = sourceValue?.id else {
                return
            }
            variableTransferValue = "\(String(sourceVariable).dropLast(2))"
            self.numberCard = "\(String(sourceVariable).dropLast(2))"
        } else {
            variableTransferValue = "\(self.numberCard)"
            self.numberCard = "\(self.numberCard)"

        }
        
        NetworkManager.shared().getAnywayPaymentBegin(numberCard: "\(variableTransferValue)", puref: self.operationList.code) { (success, anywayPaymentbegin, errorMessage) in
            if errorMessage == nil, anywayPaymentbegin?.result != "ERROR"{

                NetworkManager.shared().getAnywayPayment { (success, anywayPayment, errorMessage) in
                    
                    if anywayPayment.count != 0, anywayPayment[0]?.result != "ERROR" {
//                        anywayPayment[0]?.data?.listInputs?[0].name
            
//                        ["additional" : [["fieldid": 1, "fieldname": "NUMBER", "fieldvalue": "\(numberPhone?.dropFirst(1) ?? "")"], ["fieldid": 2, "fieldname": "SumSTrs", "fieldvalue": "\(amount!)"]]]
//
//                        for i in  anywayPayment[0]?.data{
//                            <#code#>
//                        }
                        print(anywayPayment)
                        NetworkManager.shared().getAnywayPaymentFinal(memberId: "mobilePhone", amount: self.amountTextFiel.text, numberPhone: cleanNumber(number: self.numberPhone), parameters: nil) { [self] (success, anywayPayments, errorMessage) in
                            if anywayPayments[0]?.result != "ERROR", errorMessage == nil{
                                
                                if anywayPayments[0]?.data?.finalStep == 1 {
                                    guard let commission = anywayPayments[0]?.data else {
                                        return
                                    }
                                    self.dataComission = commission
                                    
//                                    self.performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)
                                    let vc =  self.storyboard?.instantiateViewController(withIdentifier: "CodeVerificationStroyboard") as? RegistrationCodeVerificationViewController
                                    vc?.segueId = "serviceOperation"
                                    vc?.sourceConfig = self.destinationConfig
                                    vc?.sourceValue = self.sourceValue
                                    vc?.destinationConfig = sourceConfigurations
                                    vc?.destinationValue = self.numberPhone
                                    vc?.operationSum = String(dataComission?.amount ?? 0.0)
                                    vc?.commission = String(dataComission?.commission ?? 0.0)
                                    vc?.currencyLable = getSymbol(forCurrencyCode: sourceValue?.currencyCode ?? "RUB") 
                                    present(vc ?? UIViewController(), animated: true, completion: nil)
                                    self.loaderView.isHidden = true
                                    self.activityIndicator.stopAnimating()
                                    
                                }
                            } else{
                                AlertService.shared.show(title: "Ошибка", message: "\(errorMessage ?? "")", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                                self.loaderView.isHidden = true
                                self.activityIndicator.stopAnimating()
                            }
                        }
                       
                    } else {
                        print(anywayPayment)
                        AlertService.shared.show(title: "Ошибка", message: "\(errorMessage ?? "")", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                        self.loaderView.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                }
            } else {
                guard let error = errorMessage else {
                    return
                }
                AlertService.shared.show(title: "Ошибка", message: error, cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: nil, okCompletion: nil)
                self.loaderView.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
        
            
    }

    
}



extension OperationDetailViewController: ICellConfiguratorDelegate, PaymentsDetailsViewControllerDelegate {

        func didChangeSource(paymentOption: PaymentOptionType) {
            print(paymentOption)
//            sourcePaymentOption = paymentOption
        }

        func didChangeDestination(paymentOption: PaymentOptionType) {
            print(paymentOption)
//            destinaionPaymentOption = paymentOption
        }

        func didChangeAmount(amount: Double?) {
//            self.amount = amount
        }

        func didPressPrepareButton() {
//            preparePayment()
        }

        func didPressPaymentButton() {

        }
    func didReciveNewValue(value: Any, from configurator: ICellConfigurator) {
//        self.sourceValue = value
//        presenter?.didChangeSource(paymentOption: self.sourceValue as! PaymentOptionType)
//        self.sourceValue = presenter?.didChangeSource(paymentOption: value as! PaymentOptionType)
        self.sourceValue = value as? PaymentOption
        self.numberCard = (value as? PaymentOption)?.number ?? "error"
//        self.numberCard = (value as? PaymentOption)?.number
            if let sourceConfig = sourceConfigurations?.filter({ $0 == configurator }).first {
                switch (sourceConfig, value) {
                case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                    delegate?.didChangeSource(paymentOption: .option(destinationOption))
                    break
                default:
                    break
                }
                self.sourceConfig = sourceConfig
                self.sourceValue = value as? PaymentOption
    //            (value as? PaymentOption)?.name as? String = "Счет " + "\(String(describing: (value as! PaymentOption).name))"
//                guard let numberCard = (sourceValue as AnyObject).number else {
//                    return
//                }
//                self.numberCard = numberCard
//                self.sourcePagerView.reloadInputViews()
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
    
}
