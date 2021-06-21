//
//  LoginCardEntryViewController.swift
//  ForaBank
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

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
        creditCardView.cardNumberTextField.delegate = self
        creditCardView.scanerCardTapped = { self.scanCardTapped() }
        creditCardView.enterCardNumberTapped = { [weak self] (cardNumber) in
            self?.checkCardNumber(with: cardNumber)
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
    
    fileprivate func checkCardNumber(with number: String) {
        
        let body = ["cardNumber": "\(number)"] as [String : AnyObject]
        
        NetworkManager<CheckClientDecodebleModel>.addRequest(.checkCkient, [:], body) { (model, error) in
            if error != nil {
                guard let error = error else { return }
                self.showAlert(with: "Ошибка", and: error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    guard let phone = model?.data?.phone else { return }
                    DispatchQueue.main.async { [weak self] in
                        let vc = CodeVerificationViewController(phone: phone)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    guard let error = model?.errorMessage else { return }
                    self.showAlert(with: "Ошибка", and: error)
                }
            }
        }
    }

    fileprivate func scanCardTapped() {
        print(#function + " Открываем экран сканера")
        let scannerView = CardScannerController.getScanner { card in
            guard let cardNumder = card else { return }
            self.creditCardView.cardNumberTextField.text = "\(cardNumder)"
        }
        present(scannerView, animated: true, completion: nil)
    }
        
}
    
//MARK: - TextFieldDelegate
extension LoginCardEntryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let textField = textField as? MaskedTextField else { return }
        guard let cardNumber = textField.unmaskedText else { return }
        creditCardView.doneButton.isHidden = cardNumber.count >= 16 ? false : true
        creditCardView.cardNumberTextField.maskString = cardNumber.count >= 16 ? "00000000000000000000" : "0000 0000 0000 0000"
        let newPosition = textField.endOfDocument
        creditCardView.cardNumberTextField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
    }
}
