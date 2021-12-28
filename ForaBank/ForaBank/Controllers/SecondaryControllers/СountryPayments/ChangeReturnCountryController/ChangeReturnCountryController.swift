//
//  ChangeReturnCountryController.swift
//  ForaBank
//
//  Created by Mikhail on 21.12.2021.
//

import UIKit
//import RealmSwift

class ChangeReturnCountryController: UIViewController {
    
    enum ChangeReturnType {
        case changePay
        case returnPay
    }
    
    var type: ChangeReturnType
    
//    lazy var realm = try? Realm()
    var confurmVCModel: ConfirmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            setupData(with: model)
        }
    }
    
    var numberTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер перевода",
            image: UIImage(named: "hash")!,
            isEditable: false))
    
    var fullNameField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: false))
    
    var surnameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Фамилия",
            image: #imageLiteral(resourceName: "accountImage"),
            isEditable: true))
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Имя",
            isEditable: true))
    
    var secondNameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Отчество",
            isEditable: true))
    
    var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: UIImage(named: "coins")!,
            isEditable: false))
    
    var cardFromField = CardChooseView()
    
    let doneButton = UIButton(title: "Продолжить")
    
    init(type: ChangeReturnType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doneButton.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(
            arrangedSubviews: [numberTransctionField,
                               fullNameField,
                               surnameField,
                               nameField,
                               secondNameField,
                               summTransctionField,
                               cardFromField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20)
        
        view.addSubview(doneButton)
        doneButton.anchor(left: stackView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: stackView.rightAnchor,
                          paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 44)
    }
    
    func setupData(with model: ConfirmViewControllerModel) {
        cardFromField.isHidden = false
        cardFromField.choseButton.isHidden = true
        cardFromField.balanceLabel.isHidden = true
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.model = model.cardFromRealm
        cardFromField.cardModel = model.cardFrom
        
        fullNameField.text =  model.fullName ?? ""
        
        summTransctionField.text = model.summTransction
        numberTransctionField.text = model.numberTransction
        
        surnameField.text = model.surname ?? ""
        nameField.text = model.name ?? ""
        secondNameField.text = model.secondName ?? ""
        
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: #imageLiteral(resourceName: "Vector")))
        self.navigationItem.rightBarButtonItem = customViewItem
        
        if model.paymentSystem != nil {
            let navImage: UIImage = model.paymentSystem?.svgImage?.convertSVGStringToImage() ?? UIImage()
            
            let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
            self.navigationItem.rightBarButtonItem = customViewItem
        }
        
        switch type {
        case .returnPay:
            title = "Возврат перевода"
            surnameField.isHidden = true
            nameField.isHidden = true
            secondNameField.isHidden = true
            doneButton.setTitle("Вернуть", for: .normal)
        case .changePay:
            title = "Изменения перевода"
            fullNameField.isHidden = true
            doneButton.setTitle("Продолжить", for: .normal)
        }
    }
    
    @objc func doneButtonTapped() {
        print(#function)
        switch type {
        case .returnPay:
            returnPay()
        case .changePay:
            let surname = self.surnameField.textField.text ?? ""
            let name = self.nameField.textField.text ?? ""
            let secondName = self.secondNameField.textField.text ?? ""
            changePay(name: name, surname: surname, secondName: secondName)
        }
    }
    
    // MARK: API
    
    private func returnPay() {
        guard let model = confurmVCModel else { return }
        let body = ["paymentOperationDetailId": model.paymentOperationDetailId,
                    "transferReference": model.numberTransction
        ] as [String : AnyObject]
        showActivity()
        NetworkManager<ReturnPaymentContactDecodableModel>.addRequest(.returnOutgoing, [:], body) { modelResp, error in
            self.dismissActivity()
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            } else {
                if modelResp?.statusCode == 0 {
                    let controller = PaymentsDetailsSuccessViewController()
                    model.status = .returnRequest
                    controller.confurmVCModel = model
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                } else {
                    self.showAlert(with: "Ошибка", and: modelResp?.errorMessage ?? "")
                }
            }
        }
    }
    
    private func changePay(name: String, surname: String, secondName: String) {
        guard let model = confurmVCModel else { return }
        let body = ["bLastName": surname,
                    "bName": name,
                    "bSurName": secondName,
                    "transferReference": model.numberTransction
        ] as [String : AnyObject]
        showActivity()
        NetworkManager<ChangePaymentContactDecodableModel>.addRequest(.changeOutgoing, [:], body) { modelResp, error in
            self.dismissActivity()
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            } else {
                if modelResp?.statusCode == 0 {
                    let controller = PaymentsDetailsSuccessViewController()
                    model.status = .changeRequest
                    controller.confurmVCModel = model
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                } else {
                    self.showAlert(with: "Ошибка", and: modelResp?.errorMessage ?? "")
                }
            }
        }
    }
    
}
