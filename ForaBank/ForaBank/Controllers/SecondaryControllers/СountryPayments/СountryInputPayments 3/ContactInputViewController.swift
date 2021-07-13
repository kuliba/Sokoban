//
//  ContactInputViewController.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit
import SVGKit

class ContactInputViewController: UIViewController {
    
    let popView = CastomPopUpView()
    var typeOfPay: PaymentType = .contact {
        didSet {
            print("DEBUG: Puref: ", typeOfPay.puref)
//            self.startPayment(with: selectedCardNumber, type: typeOfPay) { error in
//                self.dismissActivity()
//                if error != nil {
//                    self.showAlert(with: "Ошибка", and: error!)
//                }
//            }
        }
    }
    var selectedCardNumber = ""
    var selectedBank: BanksList? {
        didSet {
            guard let bank = selectedBank else { return }
            setupBankField(bank: bank)
        }
    }
    var needShowSwitchView: Bool = false {
        didSet {
            foraSwitchView.isHidden = needShowSwitchView ? false : true
        }
    }
    
    var country: CountriesList? {
        didSet {
            if country?.code == "AM" {
                self.typeOfPay = .migAIbank
                self.configure(with: country, byPhone: true)
            } else {
                self.typeOfPay = .contact
                self.configure(with: country, byPhone: false)
            }
        }
    }
    
    var banks: [BanksList]? {
        didSet {
            guard let banks = banks else { return }
            bankListView.bankList = banks
        }
    }
    
    var foraSwitchView = ForaSwitchView()
    
    var surnameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Фамилия получателя",
            image: #imageLiteral(resourceName: "accountImage"),
            errorText: "Фамилия указана не верно"))
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Имя получателя",
            errorText: "Имя указана не верно"))
    
    var secondNameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Отчество получателя (если есть)"))
    
    var phoneField = ForaInput(
        viewModel: ForaInputModel(
            title: "По номеру телефона",
            image: #imageLiteral(resourceName: "Phone"),
            type: .phone))
    
    var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк получателя",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false,
            showChooseButton: true))
    
    var bankListView = BankListView()
        
    var cardField = ForaInput(
        viewModel: ForaInputModel(
            title: "Счет списания",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false))
    
    var cardListView = CardListView(onlyMy: false)
    
    var bottomView = BottomInputView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Viewlifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        setupActions()
        
    }

    //MARK: - Actions
    @objc func titleDidTaped() {
        print("countryField didChooseButtonTapped")
        let vc = ChooseCountryTableViewController()
        vc.modalPresent = true
        vc.didChooseCountryTapped = { [weak self]  (country) in
            self?.country = country
        }
        let navVc = UINavigationController(rootViewController: vc)
        self.present(navVc, animated: true, completion: nil)
    }
    
    func setupActions() {
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async {
                
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
                guard let data = data else { return }
                self?.cardListView.cardList = data
                
                if data.count > 0 {
                    self?.cardField.configCardView(data.first!)
                    guard let cardNumber  = data.first?.number else { return }
                    self?.selectedCardNumber = cardNumber
                }
            }
        }
        
        getBankList { [weak self]  banksList, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
                
                guard let banksList = banksList else { return }
                var filteredbanksList : [BanksList] = []
                
                banksList.forEach { bank in
                    guard let codeList = bank.paymentSystemCodeList else { return }
                    guard let countrylist = self?.country?.paymentSystemCodeList else { return }
                    countrylist.forEach { code in
                        if codeList.contains(code) {
                            filteredbanksList.append(bank)
                        }
                    }
                }
                self?.banks = filteredbanksList
            }
        }
        
        bankListView.didBankTapped = { (bank) in
            self.selectedBank = bank
//            self.openOrHideView(self.bankListView)
            self.hideView(self.bankListView, needHide: true)
            self.hideView(self.cardListView, needHide: true)
        }
        
        foraSwitchView.switchIsChanged = { [weak self] (switchView) in
            self?.typeOfPay = switchView.isOn ? .migAIbank : .contact
            self?.configure(with: self?.country, byPhone: switchView.isOn)
        }
        
        cardField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
            self.hideView(self.bankListView, needHide: true)
        }
        
        bankField.didChooseButtonTapped = { () in
            print("bankField didChooseButtonTapped")
            self.openOrHideView(self.bankListView)
            self.hideView(self.cardListView, needHide: true)
        }
        
        cardListView.didCardTapped = { card in
            self.cardField.configCardView(card)
            self.selectedCardNumber = card.number ?? ""
            
            self.hideView(self.cardListView, needHide: true)
            self.hideView(self.bankListView, needHide: true)
            
        }
        
        bottomView.didDoneButtonTapped = { [weak self] (_) in
            self?.doneButtonTapped()
        }
    }
    
    @objc func doneButtonTapped() {
        // TODO : Нужна проверка данных на не пустые Имя, Телефон, Сумма
        showActivity()
        startPayment(with: selectedCardNumber, type: typeOfPay) { error in
            self.dismissActivity()
            if error != nil {
                self.showAlert(with: "Ошибка", and: error!)
            }
        }
    }
    
    //MARK: - Helpers
    func goToConfurmVC(with model: ConfirmViewControllerModel) {
        DispatchQueue.main.async {
            let vc = ContactConfurmViewController()
            vc.confurmVCModel = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func setupBankField(bank: BanksList) {
        self.bankField.text = bank.memberNameRus ?? "" //"АйДиБанк"
        self.bankField.imageView.image = convertSVGStringToImage(bank.svgImage ?? "")
    }
    
    func convertSVGStringToImage(_ string: String) -> UIImage {
        let stringImage = string.replacingOccurrences(of: "\\", with: "")
        let imageData = Data(stringImage.utf8)
        let imageSVG = SVGKImage(data: imageData)
        let image = imageSVG?.uiImage ?? UIImage()
        return image
    }
    
    //MARK: - API
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?)->()) {
        
        NetworkHelper.request(.getProductList) { cardList , error in
            if error != nil {
                completion(nil, error)
            }
            guard let cardList = cardList as? [GetProductListDatum] else { return }
            completion(cardList, nil)
            print("DEBUG: Load card list... Count is: ", cardList.count)
        }
    }
    
    func getBankList(completion: @escaping (_ banksList: [BanksList]?, _ error: String?)->()) {
        
        NetworkHelper.request(.getBanks) { banksList , error in
            if error != nil {
                completion(nil, error)
            }
            guard let banksList = banksList as? [BanksList] else { return }
            completion(banksList, nil)
            print("DEBUG: Load Banks List... Count is: ", banksList.count)
        }
    }
    
    
//    jj
    
    private func openOrHideView(_ view: UIView) {
        UIView.animate(withDuration: 0.2) {
            if view.isHidden == true {
                view.alpha = 1
                view.isHidden = false
            } else {
                view.alpha = 0
                view.isHidden = true
            }
            self.stackView.layoutIfNeeded()
        }
    }
    
    private func hideView(_ view: UIView, needHide: Bool) {
        UIView.animate(withDuration: 0.2) {
            view.alpha = needHide ? 0 : 1
            view.isHidden = needHide
            self.stackView.layoutIfNeeded()
        }
    }

    
}

