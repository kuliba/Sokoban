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
        setupBackground()
        setupUI()
        hideKeyboardWhenTappedAround()
        creditCardView.cardNumberTextField.delegate = self
        creditCardView.scanerCardTapped = { self.scanCardTapped() }
        orderCardView.orderCardTapped = { self.orderCardTapped() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Helpers
    fileprivate func setupBackground() {
        view.backgroundColor = .white
        let imageView = UIImageView(image: UIImage(named: "BackgroundLine"))
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor,
                         bottom: view.bottomAnchor ,right: view.rightAnchor,
                         paddingBottom: 160)
    }
    
    fileprivate func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(creditCardView)
        view.addSubview(orderCardView)
        
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                          paddingTop: 54, paddingLeft: 20)
        subTitleLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                             paddingTop: 8, paddingLeft: 20)
        creditCardView.anchor(top: subTitleLabel.bottomAnchor, left: view.leftAnchor,
                              right: view.rightAnchor, paddingTop: 50,
                              paddingLeft: 20, paddingRight: 20, height: 204)
        orderCardView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                             paddingLeft: 20, paddingBottom: 50, paddingRight: 20, height: 72)
        
        let image = UIImage(systemName: "arrow.down")?.withRenderingMode(.alwaysOriginal)
        let arrowImage = UIImageView(image: image)
        view.addSubview(arrowImage)
        arrowImage.setDimensions(height: 15, width: 15)
        arrowImage.centerY(inView: titleLabel, leftAnchor: titleLabel.rightAnchor, paddingLeft: 8)
        
    }
    
    //MARK: - Actions
    fileprivate func orderCardTapped() {
        let vc = OrderProductsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    fileprivate func scanCardTapped() {
        print(#function + " Открываем экран сканера")
    }
        
}
    
//MARK: - TextFieldDelegate
extension LoginCardEntryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let textField = textField as? MaskedTextField else { return }
        guard let cardNumber = textField.unmaskedText else { return }
        if cardNumber.count == 16 {
            print("Открываем экран СМС, карта№: " + cardNumber)
            let vc = CodeVerificationViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
