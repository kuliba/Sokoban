//
//  LoginCardEntryViewController.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import AnyFormatKit
import IQKeyboardManagerSwift

class LoginCardEntryViewController: UIViewController {
    
    let titleLabel = UILabel(text: "Войти", font: .systemFont(ofSize: 24))
    let subTitleLabel = UILabel(text: "чтобы получить доступ к счетам и картам")
    let creditCardView = CreditCardEntryView()
    let orderCardView = OrderCardView()
    
    //MARK: - Viewlifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        setupUI()
        hideKeyboardWhenTappedAround()
        self.creditCardView.cardNumberTextField.becomeFirstResponder()
        creditCardView.cardNumberTextField.delegate = self
        creditCardView.scanerCardTapped = { self.scanCardTapped() }
        // Срабатывает когда вводим карту
        creditCardView.enterCardNumberTapped = { [weak self] (cardNumber) in
            self?.showActivity()
            DispatchQueue.main.async {
                
                // Для тестировщиков AppStore
                if cardNumber == "0565205123484281"{
                    
                    self?.dismissActivity()
                    DispatchQueue.main.async { [weak self] in
                        let resp = "+79626129268"
                        let model = CodeVerificationViewModel(phone: resp, type: .register)
                        let vc = CodeVerificationViewController(model: model)
                        vc.cardNumber = cardNumber
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                } else {
                    // Для остальных
                    DispatchQueue.main.async {
                    AppDelegate.shared.getCSRF { error in
                        if error != nil {
                            print("DEBUG: Error getCSRF: ", error!)
                        }
                         // Запрос на проверку карты
                        LoginViewModel().checkCardNumber(with: cardNumber.digits) { resp, error in
                            self?.dismissActivity()
                            if error != nil {
                                self?.showAlert(with: "Ошибка", and: error ?? "")
                            } else {
                                // Зарузка кэша
                                DownloadQueue.download {}
                                DispatchQueue.main.async { [weak self] in
                                    let model = CodeVerificationViewModel(phone: resp, type: .register)
                                    let vc = CodeVerificationViewController(model: model)
                                    vc.cardNumber = cardNumber
                                    self?.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                }
            }
            }
        }
        
        orderCardView.orderCardTapped = { self.orderCardTapped() }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Actions
    fileprivate func orderCardTapped() {
        let vc = OrderProductsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    fileprivate func scanCardTapped() {
        print(#function + " Открываем экран сканера")
        
        let scannerView = CardScannerController.getScanner { card in
            guard let cardNumder = card else { return }
            self.creditCardView.cardNumberTextField.text = "\(cardNumder)"
            self.creditCardView.doneButton.isHidden = cardNumder.count  >= 16 ? false : true
            self.creditCardView.cardNumberTextField.becomeFirstResponder()
        }
        present(scannerView, animated: true, completion: nil)
    }
    
}

//MARK: - TextFieldDelegate
extension LoginCardEntryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let textField = textField as? MaskedTextField else { return }
        guard let cardNumber = textField.unmaskedText else { return }
//        formattedNumber(number: cardNumber)
        creditCardView.doneButton.isHidden = cardNumber.count  >= 16 ? false : true

        creditCardView.cardNumberTextField.maskString = cardNumber.digits.count <= 16 ? "0000 0000 0000 00000"  : "00000 000 0 0000 0000000"
    }
    
    func formattedNumber(number: String) -> String {
                    let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        var mask = String()
        if cleanPhoneNumber.count <= 16{
            mask = "#### #### #### ####"
        } else{
            mask = "##### #### # #### ######"
        }
                    var result = ""
                    var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
                        if ch == "#" {
                            result.append(cleanPhoneNumber[index])
                            index = cleanPhoneNumber.index(after: index)
                        } else {
                            result.append(ch)
                        }
                    }
                    return result
                }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string:  String) -> Bool {
//        guard let text = textField.text else {
//                return true
//            }
//            let lastText = (text as NSString).replacingCharacters(in: range, with: string) as String
//            
//            if creditCardView.cardNumberTextField == textField,  creditCardView.cardNumberTextField.text?.digits.count ?? 0 < 16 {
//                textField.text = lastText.format("nnnn nnnn nnnn nnnn", oldString: text)
//                return false
//            } else if creditCardView == textField, creditCardView.cardNumberTextField.text?.digits.count ?? 0 > 16{
//                textField.text = lastText.format("nnnnn nnn n nnnn nnnnnnn", oldString: text)
//                return false
//            }
//            return true
//    }
}
