//
//  SaveDefaultSBPBankVC.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 17.04.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class SaveDefaultSPBBankVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!
    @IBOutlet weak var activitiIndicatorView: UIView!
    // MARK: - Properties
    @IBOutlet weak var sourcePagerView: PagerView!
    @IBOutlet weak var destinationPagerView: PagerView!
    //@IBOutlet weak var picker: UIView!
    //@IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var containterView: RoundedEdgeView!
    //@IBOutlet weak var pickerLabel: UILabel!
    //@IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var sendButton: ButtonRounded!
//    //@IBOutlet weak var messageRecipient: UITextField!
//    @IBOutlet weak var messageRecipientView: UIView!
//    @IBOutlet weak var messageRecipient: UITextView!
    var setAgree = false
    @IBOutlet weak var agreementSBP: UIView!
//    @IBOutlet weak var backgroundViewSbpModal: UIView!

    
    @IBOutlet weak var sendAgreeButton: ButtonRounded!


    @IBAction func sendAgreeButton(_ sender: ButtonRounded) {
        setAgree = true
        UserDefaults.standard.set(setAgree, forKey: "sbpAgree")
                agreementSBP.isHidden = true
//                backgroundViewSbpModal.isHidden = true
                print("tap Button")
    }
    

    // MARK: - Actions
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        //delegate?.didPressPrepareButton()
        activityIndicator.startAnimation()
        activitiIndicatorView.isHidden = false
        guard let mobilePhoneUnwrapped = phoneNumber?.dropFirst() else {
            return
        }
        NetworkManager.shared().getAnywayPaymentFinal(memberId: "setDefaultBank", amount: "", numberPhone: "\(mobilePhoneUnwrapped)", parameters: nil) { (success, anywayInputs, errorMessage) in
            if anywayInputs[0]?.result != "ERROR"{
              
                    self.performSegue(withIdentifier: "verCodeSBPBank", sender: nil)
                    self.activityIndicator.stopAnimating()
                    self.activitiIndicatorView.isHidden = true
                    
                } else {
                    AlertService.shared.show(title: "Ошибка", message: anywayInputs[0]?.errorMessage, cancelButtonTitle: "Отмена", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil)

            }
        }
//        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "ErrorSBPViewController") as! CompleteSBPBankVC
//        let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
//        self.present(navController, animated:true, completion: nil)
        
        
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

//    @IBAction func pickerButtonClicked(_ sender: UIButton) {
//        if let vc = UIStoryboard(name: "Payment", bundle: nil)
//            .instantiateViewController(withIdentifier: "ppvc") as? OptionPickerViewController {
//            sender.isEnabled = false
//            // Pass picker frame to determine picker popup coordinates
//            vc.pickerFrame = picker.convert(pickerLabel.frame, to: view)
//
//            vc.pickerOptions = ["За завтраки", "За тренировку", "За обеды"]
//            vc.delegate = self
//            present(vc, animated: true, completion: nil)
//        }
//    }
    let placeHolderMessageRecipient = "Сообщение получателю"
    let colorBorderMessageRecipient = UIColor.systemGray.withAlphaComponent(0.5).cgColor
    var messageRecipientIsHidden = false // флаг отображения поля коментария
    var presenter: PaymentDetailsPresenter?
    var sourceConfigurations: [ICellConfigurator]?
    var destinationConfigurations: [ICellConfigurator]?
    var delegate: PaymentsDetailsViewControllerDelegate?
    var sourceConfig: Any?
    var sourceValue: Any?
    var destinationConfig: Any?
    var destinationValue: Any?

    var remittanceSourceView: RemittanceOptionView!
    var remittanceDestinationView: RemittanceOptionView!
    var selectedViewType: Bool = false //false - source; true - destination
//    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    var phoneNumber: String?
 
       private let destinationProviderCardNumber = CardNumberCellProvider()
       private let destinationProviderAccountNumber = AccountNumberCellProvider()
       private let destinationProviderPhoneNumber = PhoneNumberCellProvider()
    
// MARK: - Lifecycle

//    private let sourceProvider = PaymentOptionCellProvider()
//     private let destinationProvider = PaymentOptionCellProvider()
//    var sourceConfigurations: [ICellConfigurator]?
//    var destinationConfigurations: [ICellConfigurator]?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = false
        activitiIndicatorView.isHidden = false
        activityIndicator.startAnimation()
//        backgroundViewSbpModal.backgroundColor = .red
//        self.backgroundViewSbpModal.isHidden = true
        NetworkManager.shared().getPerson { (succcess, person, errorMessage) in
            if succcess ?? false, person.data?.users?.isEmpty == false{
                self.phoneNumber = person.data?.users?[0].login
            } else {
                AlertService.shared.show(title: "Ошибка", message: "Повторите позднее", cancelButtonTitle: "Отмена", okButtonTitle: "ОК", cancelCompletion: nil, okCompletion: nil)
            }

            NetworkManager.shared().getAnywayPaymentBegin(numberCard: "BANK_DEF", puref: "iFora||SetBankDef") { (success, anywayPaymentBegin, errorMessage) in
                if success{
                    print("success")
                    NetworkManager.shared().getAnywayPayment { (success, anywayInputs, errorMessage) in
                        if success == false{
                            AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Ok", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil)
                        }
                        print(anywayInputs)
                        self.activityIndicator.isHidden = true
                        self.activitiIndicatorView.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    AlertService.shared.show(title: "Ошибка", message: errorMessage, cancelButtonTitle: "Ok", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil)
                    self.activityIndicator.isHidden = true
                    self.activitiIndicatorView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        setUpLayout()
           let agreementSbp = UserDefaults.standard.object(forKey: "sbpAgree")
          setAgree = (agreementSbp != nil)
//        if setAgree == false{
//            agreementSBP.isHidden = false
//            backgroundViewSbpModal.isHidden = false
//        } else {
//            agreementSBP.isHidden = true
//            backgroundViewSbpModal.isHidden = true
//        }
//        if let source = sourceConfigurations, let dest = destinationConfigurations {
//            sourcePagerView.setConfig(config: source)
//            destinationPagerView.setConfig(config: dest)
//        }
         let source = [PaymentOptionsPagerItem(provider: PaymentOptionCellProvider(), delegate: self)]
        self.sourcePagerView.setConfig(config: source)
        
        let dest = [PhoneNumberPagerItem(provider: PhoneNumberCellProvider(), delegate: self)]
        destinationPagerView.setConfig(config: dest)
        
        //self.messageRecipientView.isHidden = messageRecipientIsHidden
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
 

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //store.unsubscribe(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradientView() // TODO: Replace with GradientView view
    }

    internal func newState(state: ProductState) {
        //optionsTable.reloadData()
//        setUpRemittanceViews()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "fromPaymentToPaymentVerification", let destinationVC = segue.destination as? RegistrationCodeVerificationViewController {
//            destinationVC.sourceConfig = destinationConfig
//            destinationVC.sourceValue = sourceValue
//            destinationVC.destinationConfig = destinationConfig
//            destinationVC.destinationValue = destinationValue
//        }
    }
}

// - MARK: Private methods

private extension SaveDefaultSPBBankVC {
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
        sendButton.changeEnabled(isEnabled: true)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        setUpPicker()
    }
}

extension SaveDefaultSPBBankVC: OptionPickerDelegate {
    func setSelectedOption(option: String?) {
        // Set current option to selected one if not just dismissed
//        if let option = option {
//            //pickerLabel.text = option
//        }
        //pickerButton.isEnabled = true
    }
}

extension SaveDefaultSPBBankVC: RemittancePickerDelegate {
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

extension SaveDefaultSPBBankVC: PaymentDetailsPresenterDelegate {
    func didPrepareData(data: DataClassPayment?) {
        
    }
    func didFinishPreparation(success: Bool, data: DataClassPayment?) {
        if success {
            performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)
        } else {
            AlertService.shared.show(title: "Ошибка", message: "При выполнении платежа произошла ошибка, попробуйте ещё раз позже", cancelButtonTitle: "Продолжить", okButtonTitle: nil, cancelCompletion: nil, okCompletion: nil)
        }
    }

    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool) {
        print(isLoading, canAskFee, canMakePayment)
        //sendButton.changeEnabled(isEnabled: canAskFee)
//        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

extension SaveDefaultSPBBankVC: ICellConfiguratorDelegate {
    func didReciveNewValue(value: Any, from configurator: ICellConfigurator) {
        print("value = ",value)
        print("value = ",configurator)
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
}

