/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import ReSwift

class TemplateOperation: Codable{
    var templateName: String?
    var destinationValue: String?
    var amount: String?
    
}

class PaymentsDetailsSuccessViewController: UIViewController, StoreSubscriber {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var createTemplate: ButtonRounded!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var returnButton: ButtonRounded!

    @IBOutlet weak var sumLabel: UILabel!

    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardSumLabel: UILabel!

    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var destinationNumber: UILabel!
    @IBOutlet weak var destinationSum: UILabel!
    var currentLabel: String?
    // MARK: - Actions

    @IBAction func returnButtonClicked(_ sender: Any) {
        dismissToRootViewController()
    }

    // MARK: - Properties

    var sourceConfig: Any?
    var sourceValue: Any?
    var destinationConfig: Any?
    var destinationValue: Any?
    var operationSum: String?

    // MARK: - Lifecycle

    func setSource(config: Any?, value: Any?) {
        switch value {
        case let sourceOption as PaymentOption:
            guard var currentUnwrapped = getSymbol(forCurrencyCode: currentLabel ?? "RUR") else {
                break
            }
            if currentUnwrapped == "р."{
                currentUnwrapped = "₽"
            }
            cardNameLabel.text = sourceOption.name
            cardSumLabel.text = "\(maskSum(sum: sourceOption.value)) \(String(describing: currentUnwrapped ))"
            cardNumberLabel.text = sourceOption.maskedNumber
        default:
            break
        }
    }

    func setDestination(config: Any?, value: Any?) {
        destinationSum.text = ""
        destinationNumber.text = ""
        switch (config, value) {
        case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
            destinationName.text = (destinationOption.name)
            destinationSum.text = "\(String(destinationOption.value)) ₽"
            destinationNumber.text = destinationOption.maskedNumber
        case (is CardNumberPagerItem, let destinationOption as String):
            destinationName.text = destinationOption
        case (is PhoneNumberPagerItem, let destinationOption as String):
            destinationName.text = destinationOption
        case (is AccountNumberPagerItem, let destinationOption as String):
            destinationName.text = destinationOption
        case (nil, let destinationOption as PaymentOption):
            guard var currentUnwrapped = getSymbol(forCurrencyCode: destinationOption.currencyCode ?? "RUR") else {
                return 
            }
            if currentUnwrapped == "р."{
                currentUnwrapped = "₽"
            }
            destinationName.text = (destinationOption.name)
            destinationSum.text = "\(String(destinationOption.sum)) \(currentUnwrapped)"
            destinationNumber.text = destinationOption.number
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        arrowImageView.image = arrowImageView.image?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .white

        returnButton.backgroundColor = .clear
        returnButton.layer.borderWidth = 1
        returnButton.layer.borderColor = UIColor.white.cgColor

        setSource(config: sourceConfig, value: sourceValue)
        print(sourceConfig)
        
        print(sourceValue)
        
        setDestination(config: destinationConfig, value: destinationValue)
        
        sumLabel.text = "\(String(describing: operationSum ?? "Нет соеденения")) ₽"
        
        
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        store.subscribe(self) { state in
            state.select { $0.productsState }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }

    internal func newState(state: ProductState) {
        //      defaultSourcePaymentOption = state.sourceOption
        //       defaultDestinationPaymentOption = state.destinationOption
        //
        //        if (defaultSourcePaymentOption != nil) {
        //            selectedSourcePaymentOption = defaultSourcePaymentOption
        //        }
        //
        //        if (defaultDestinationPaymentOption != nil) {
        //            selectedDestinationPaymentOption = defaultDestinationPaymentOption
        //        }

        //optionsTable.reloadData()
        //        setUpRemittanceViews()

        guard let sourceOption = state.sourceOption, let destinationOption = state.destinationOption, let _ = state.paymentSum else {
            return
        }

        cardNameLabel.text = sourceOption.name
        cardSumLabel.text = String(describing: sourceOption.value)
        cardNumberLabel.text = sourceOption.maskedNumber

        destinationName.text = destinationOption.name
        destinationSum.text = String(describing: destinationOption.value)
        destinationNumber.text = destinationOption.maskedNumber

//        sumLabel.text = "\(sum) ₽"
    }
// MARK: - Methods

    func dismissToRootViewController() {
        if let first = presentingViewController,
            let second = first.presentingViewController,
            let third = second.presentingViewController {

            first.view.isHidden = true
            second.view.isHidden = true
            third.dismiss(animated: true)
        }
    }
    
    var textField = ""
    
    @IBAction func createTemplateButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Создание шаблона", message: nil, preferredStyle: .alert)
       alertController.addTextField { (textField : UITextField!) -> Void in
                      textField.placeholder = "Введите название шаблона"
                    textField.borderWidth = 0
        textField.borderColor = .blue
        textField.borderStyle = .none
                  }
        let saveAction = UIAlertAction(title: "Сохранить", style: .default, handler: { alert -> Void in
            guard let operationSumUnwrapped = self.operationSum else {return}
            guard let destinationValueUnwrapped = self.destinationValue else {return}

            let parameters: [String: Any] = [
                       "settingName": "\(alertController.textFields![0].text!)" as String,
                       "settingSysName": "\(destinationValueUnwrapped)" as String,
                       "settingValue": "\(operationSumUnwrapped)" as String
                   ]
            
            NetworkManager.shared().addSetting(parameters: parameters) { (success) in
                          if success{
                            NetworkManager.shared().setSetting(parameters: parameters) { (success) in
                                if success{
                                    print(success)
                            } else {
                                print(Error.self)
                                }
                            }

                            
                      } else {
                          print(Error.self)
                          }
                      }
            
           })
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: {
               (action : UIAlertAction!) -> Void in })
       

           alertController.addAction(saveAction)
           alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
}
