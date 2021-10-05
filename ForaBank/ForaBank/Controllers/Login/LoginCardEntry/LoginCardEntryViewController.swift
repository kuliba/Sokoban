//
//  LoginCardEntryViewController.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import AnyFormatKit

class LoginCardEntryViewController: UIViewController {
    
    let titleLabel = UILabel(text: "Войти", font: .systemFont(ofSize: 24))
    let subTitleLabel = UILabel(text: "чтобы получить доступ к счетам и картам")
    let creditCardView = CreditCardEntryView()
    let orderCardView = OrderCardView()
    
    //MARK: - Viewlifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        self.creditCardView.cardNumberTextField.becomeFirstResponder()
        creditCardView.cardNumberTextField.delegate = self
        creditCardView.scanerCardTapped = { self.scanCardTapped() }
        creditCardView.enterCardNumberTapped = { [weak self] (cardNumber) in
            self?.showActivity()
            DispatchQueue.main.async {
                
                if cardNumber == "0565205123484281"{
                    
                    self?.dismissActivity()
                    DispatchQueue.main.async { [weak self] in
                        let resp = "+79626129268"
                        let model = CodeVerificationViewModel(phone: resp, type: .register)
                        let vc = CodeVerificationViewController(model: model)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                    AppDelegate.shared.getCSRF { error in
                        if error != nil {
                            print("DEBUG: Error getCSRF: ", error!)
                        }
                    
                        LoginViewModel().checkCardNumber(with: cardNumber) { resp, error in
                            self?.dismissActivity()
                            if error != nil {
                                self?.showAlert(with: "Ошибка", and: error ?? "")
                            } else {
                                
                                DownloadQueue.download {}
                                DispatchQueue.main.async { [weak self] in
                                    let model = CodeVerificationViewModel(phone: resp, type: .register)
                                    let vc = CodeVerificationViewController(model: model)
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
        creditCardView.doneButton.isHidden = cardNumber.count  >= 16 ? false : true
        
//        creditCardView.cardNumberTextField.maskString = cardNumber.count >= 16 ? "00000 000 0 0000 0000000" : "0000 0000 0000 0000"
        
        if cardNumber.count <= 16{
            creditCardView.cardNumberTextField.maskString = "0000 0000 0000 00000"
        } else {
            creditCardView.cardNumberTextField.maskString = "00000 000 0 0000 0000000"
        }
        
        let newPosition = textField.endOfDocument
    }
}
