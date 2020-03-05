/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import ReSwift


typealias AccountNumberPagerItem = PagerViewCellHandler<TextFieldPagerViewCell, AccountNumberCellProvider>
typealias CardNumberPagerItem = PagerViewCellHandler<TextFieldPagerViewCell, CardNumberCellProvider>
typealias PaymentOptionsPagerItem = PagerViewCellHandler<DropDownPagerViewCell, CardNumberCellProvider>
typealias PhoneNumberPagerItem = PagerViewCellHandler<TextFieldPagerViewCell, PhoneNumberCellProvider>

protocol PaymentsDetailsViewControllerDelegate {

    func didChangeSource(paymentOption: PaymentOptionType)
    func didChangeDestination(paymentOption: PaymentOptionType)

    func didChangeAmount(amount: Double?)

    func didPressPrepareButton()
    func didPressPaymentButton()
}

class PaymentsDetailsViewController: UIViewController, StoreSubscriber, UITextFieldDelegate {

    
    // MARK: - Properties
    @IBOutlet weak var sourcePagerView: PagerView!
    @IBOutlet weak var destinationPagerView: PagerView!
    //@IBOutlet weak var picker: UIView!
    //@IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var containterView: RoundedEdgeView!
    //@IBOutlet weak var pickerLabel: UILabel!
    //@IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var sendButton: ButtonRounded!
    //@IBOutlet weak var messageRecipient: UITextField!
    @IBOutlet weak var messageRecipientView: UIView!
    @IBOutlet weak var messageRecipient: UITextView!
    

    // MARK: - Actions
    @IBAction func amountTextFieldValueChanged(_ sender: Any) {
        delegate?.didChangeAmount(amount: Double(amountTextField.text!.replacingOccurrences(of: ",", with: ".")))
      
        let dotString = "."
        var maxLength = 9
        if (amountTextField.text?.contains(dotString))! {
                maxLength = 12
            }
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        delegate?.didPressPrepareButton()
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
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

 
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
        setUpLayout()
        setupTextView()
        amountTextField.delegate = self
     
        if let source = sourceConfigurations, let dest = destinationConfigurations {
            sourcePagerView.setConfig(config: source)
            destinationPagerView.setConfig(config: dest)
        }
        
        self.messageRecipientView.isHidden = messageRecipientIsHidden
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
 

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
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
        if segue.identifier == "fromPaymentToPaymentVerification", let destinationVC = segue.destination as? RegistrationCodeVerificationViewController {
            destinationVC.sourceConfig = destinationConfig
            destinationVC.sourceValue = sourceValue
            destinationVC.destinationConfig = destinationConfig
            destinationVC.destinationValue = destinationValue
            destinationVC.operationSum = amountTextField.text
        }
    }
}

// - MARK: Private methods

private extension PaymentsDetailsViewController {
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
        sendButton.changeEnabled(isEnabled: false)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        setUpPicker()
    }
}

extension PaymentsDetailsViewController: OptionPickerDelegate {
    func setSelectedOption(option: String?) {
        // Set current option to selected one if not just dismissed
        if let option = option {
            //pickerLabel.text = option
        }
        //pickerButton.isEnabled = true
    }
}

extension PaymentsDetailsViewController: RemittancePickerDelegate {
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

extension PaymentsDetailsViewController: PaymentDetailsPresenterDelegate {
    func didFinishPreparation(success: Bool) {
        if success {
            performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)

            
            
        } else {
            AlertService.shared.show(title: "Ошибка", message: "При выполнении платежа произошла ошибка, попробуйте ещё раз позже", cancelButtonTitle: "Продолжить", okButtonTitle: nil, cancelCompletion: nil, okCompletion: nil)
        }
    }

    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool) {
        print(isLoading, canAskFee, canMakePayment)
        sendButton.changeEnabled(isEnabled: canAskFee)
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

extension PaymentsDetailsViewController: ICellConfiguratorDelegate {
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
}

//MARK: UITextViewDelegate
extension PaymentsDetailsViewController: UITextViewDelegate{
    //настраиваем окно сообщения
    private func setupTextView(){
        self.messageRecipient.delegate = self
        self.messageRecipient.layer.cornerRadius = 5.0
        self.messageRecipient.layer.borderColor = colorBorderMessageRecipient
        self.messageRecipient.text = self.placeHolderMessageRecipient
        self.messageRecipient.layer.borderColor = UIColor.red.cgColor
        self.messageRecipient.textColor = UIColor.systemGray
    }
    
    //ставим огранечения в 210 символов для textView
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
    
    //условия при начале работы с textView
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.messageRecipient.layer.borderWidth = 1
        //place Holder Message Recipient off
        if self.messageRecipient.text == self.placeHolderMessageRecipient{
            self.messageRecipient.text = ""
            self.messageRecipient.textColor = .black
        }
    }
    
    // условия при окончании работы с textView
    func textViewDidEndEditing(_ textView: UITextView) {
        self.messageRecipient.layer.borderWidth = 0
        //place Holder Message Recipient on
        if self.messageRecipient.text == ""{
            self.messageRecipient.text = self.placeHolderMessageRecipient
            self.messageRecipient.textColor = .systemGray
        }
    }
}
