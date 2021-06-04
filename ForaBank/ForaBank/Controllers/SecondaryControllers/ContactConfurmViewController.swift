//
//  ContactConfurmViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 30.05.2021.
//

import UIKit


//TODO: отрефакторить под сетевые запросы, вынести в отдельный файл
struct ConfurmViewControllerModel {
    var name: String
    var country: String
    var numberTransction: String
    var summTransction: String
    var taxTransction: String
    var currancyTransction: String
}

class ContactConfurmViewController: UIViewController {
    
    var confurmVCModel: ConfurmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            setupData(with: model)
        }
    }

    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: false))
    
    var countryField = ForaInput(
        viewModel: ForaInputModel(
            title: "Страна",
            image: #imageLiteral(resourceName: "map-pin"),
            isEditable: false))
    
    var numberTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер перевода",
            image: #imageLiteral(resourceName: "hash"),
            isEditable: false))
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: #imageLiteral(resourceName: "coins"),
            isEditable: false))
    
    var taxTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    var currancyTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Способ выплаты",
            image: #imageLiteral(resourceName: "Frame 579"),
            isEditable: false))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupData(with model: ConfurmViewControllerModel) {
        nameField.text =  model.name //"Колотилин Михаил Алексеевич"
        countryField.text = model.country // "Армения"
        numberTransctionField.text = model.numberTransction //"1235634790"
        summTransctionField.text = model.summTransction //"10 000.00 ₽ "
        taxTransctionField.text = model.taxTransction //"100.00 ₽ "
        currancyTransctionField.text = model.currancyTransction //"Наличные"
    }
    
    fileprivate func setupUI() {
        title = "Подтвердите реквизиты"
        view.backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.setTitle("Оплатить", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.003921568627, blue: 0.1058823529, alpha: 1)
        button.layer.cornerRadius = 22
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        
        
        let stackView = UIStackView(arrangedSubviews: [nameField, countryField, numberTransctionField, summTransctionField, taxTransctionField, currancyTransctionField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        let customView = UIImageView(image: #imageLiteral(resourceName: "Vector"))
        let customViewItem = UIBarButtonItem(customView: customView)
        self.navigationItem.rightBarButtonItem = customViewItem
    }
    
    @objc func doneButtonTapped() {
        print(#function)
    }
    

}

