//
//  ContactInputViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

class ContactInputViewController: UIViewController {

    var country: Сountry? {
        didSet {
            guard let country = country else { return }
            if country.code == "AM" {
                title = "Денежные переводы Миг"
            } else {
                title = "Денежные переводы Contact"
            }
            guard let countryName = country.name else { return }
            countryField.textField.text = countryName
            countryField.text = countryName
        }
    }
    
    var surnameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Фамилия получателя",
            image: #imageLiteral(resourceName: "accountImage"),
//            needValidate: true,
            errorText: "Фамилия указана не верно"))
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Имя получателя",
//            needValidate: true,
            errorText: "Имя указана не верно"))
    
    var secondNameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Отчество получателя (если есть)"))
    
    var countryField = ForaInput(
        viewModel: ForaInputModel(
            title: "Страна",
            image: #imageLiteral(resourceName: "map-pin"),
            isEditable: false,
            showChooseButton: true))
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: #imageLiteral(resourceName: "coins"),
            type: .amountOfTransfer))
    
    var cardField = ForaInput(
        viewModel: ForaInputModel(
            title: "Счет списания",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard))
    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        cardField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            
        }
        countryField.didChooseButtonTapped = { () in
            print("countryField didChooseButtonTapped")
        }
        getCard()
    }

    fileprivate func setupUI() {
        
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: #imageLiteral(resourceName: "Vector")))
        self.navigationItem.rightBarButtonItem = customViewItem
        view.backgroundColor = .white
        
        view.addSubview(doneButton)
        doneButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20,
                          paddingRight: 20, height: 44)
        
        let topView = UIView()
        topView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        
        let topViewSwitch = UISwitch()
        topViewSwitch.isOn = true
        topViewSwitch.isUserInteractionEnabled = true
        
        let topViewLabel = UILabel(text: "Я знаю номер телефона и банк получателя",
                                   font: .systemFont(ofSize: 12), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        topViewLabel.adjustsFontSizeToFitWidth = true
        
        
        topView.addSubview(topViewSwitch)
        topViewSwitch.centerY(inView: topView)
        topViewSwitch.anchor(right: topViewSwitch.leftAnchor, paddingRight: 20)
        
        topView.addSubview(topViewLabel)
        topViewLabel.centerY(inView: topView, leftAnchor: topView.leftAnchor, paddingLeft: 20)
        topViewLabel.anchor(right: topViewSwitch.leftAnchor, paddingRight: 27)
        
        
        
        view.addSubview(topView)
        topView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 48)
        
        
        
        
        //TODO: добавить скроллвью что бы избежать проблем на маленьких экранах
        // let scroll
        //  let view1 = UIView()
        //  view1.addSubview(stackView)
        // scroll add view1
        
        
        let stackView = UIStackView(arrangedSubviews: [surnameField, nameField, secondNameField, countryField ,summTransctionField, cardField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.anchor(top: topView.bottomAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 20)
        
    }
    
    @objc func doneButtonTapped() {
        let vc = ContactConfurmViewController()
        let model = ConfurmViewControllerModel(
            name: surnameField.viewModel.text + " " + nameField.viewModel.text + " " + secondNameField.viewModel.text,
            country: countryField.viewModel.text,
            numberTransction: "1235634790",
            summTransction: summTransctionField.viewModel.text,
            taxTransction: "100.00 ₽ ",
            currancyTransction: "Наличные")
        
        vc.confurmVCModel = model
        navigationController?.pushViewController(vc, animated: true)
    }
    
        func getCard() {
            
            NetworkManager<GetCardListDecodebleModel>.addRequest(.getCardList, [:], [:]) { model, error in
                print("DEBUG: Error: ", error)
                print("DEBUG: Card list: ", model)
            }
            
            
            
        }
    
    
}

