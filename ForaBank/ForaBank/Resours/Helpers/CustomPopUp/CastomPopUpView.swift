//
//  CastomPopUpView.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.06.2021.
//

import UIKit
import RealmSwift
//import SwiftEntryKit

//protocol CutomViewProtocol: UIView {
//    
//}

class MemeDetailVC : AddHeaderImageViewController {

    var titleLabel = UILabel(text: "Между своими", font: .boldSystemFont(ofSize: 18), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
    
    var onlyMy = true
    var onlyCard = false
    
    var viewModel = ConfirmViewControllerModel(type: .card2card) {
        didSet {
            checkModel(with: viewModel)
        }
    }
    
    var cardFromField = CardChooseView()
    var seporatorView = SeparatorView()
    var cardFromListView: CardsScrollView!
    var cardToField = CardChooseView()
    var cardToListView: CardsScrollView!
    var bottomView = BottomInputView()
    lazy var cardView = CastomCardView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    lazy var realm = try? Realm()
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        setupActions()
        setupCardViewActions()
        /// Add REALM
        AddAllUserCardtList.add() {
            print("REALM Add")
        }
        updateObjectWithNotification()
    }
    
    deinit {
        token?.invalidate()
    }
    
    private func setupUI() {
        setupFieldFrom()
        setupFieldTo()
        setupListFrom()
        setupListTo()
        
        bottomView.currencySymbol = "₽"
        
        self.addHeaderImage()
        self.view.layer.cornerRadius = 16
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.clipsToBounds = true
        self.view.backgroundColor = .white
        self.view.anchor(width: UIScreen.main.bounds.width, height: 490)
        
        stackView = UIStackView(arrangedSubviews: [cardFromField,
                                                   seporatorView,
                                                   cardFromListView,
                                                   cardToField,
                                                   cardToListView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
    }
    
    private func setupConstraint() {
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor,
                          paddingTop: 28, paddingLeft: 20)
        
        view.addSubview(bottomView)
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor)
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        
        stackView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 16)
    }
    
    func updateObjectWithNotification() {
        let object = realm?.objects(UserAllCardsModel.self)
        token = object?.observe { ( changes: RealmCollectionChange) in
            switch changes {
            case .initial:
//                print("REALM Initial")
//                self.cardFromListView.cardList = self.updateCardsList(with: object)
                self.cardFromField.model = self.updateCardsList(with: object).first
                self.viewModel.cardFromRealm = self.updateCardsList(with: object).first
//                self.cardToListView.cardList = self.updateCardsList(with: object)
            case .update:
//                print("REALM Update")
//                self.cardFromListView.cardList = self.updateCardsList(with: object)
                self.cardFromField.model = self.updateCardsList(with: object).first
//                self.cardToListView.cardList = self.updateCardsList(with: object)
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    private func updateCardsList(with result: Results<UserAllCardsModel>?) -> [UserAllCardsModel] {
        var cardsArray = [UserAllCardsModel]()
        result?.forEach { card in
            if card.productType == "CARD" {
                cardsArray.append(card)
            } else if !onlyCard &&  card.productType == "ACCOUNT" {
                cardsArray.append(card)
            }
        }
        return cardsArray
    }
    
    private func createTopLabel(title: String) -> UIView {
        let view = UIView()
        let label = UILabel(text: title, font: .systemFont(ofSize: 12), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        
        view.addSubview(label)
        label.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 20)
        view.anchor(height: 20)
        
        return view
    }
    
    func setupActions() {
        
        seporatorView.buttonSwitchCardTapped = { () in
            guard let tmpModelFrom = self.cardFromField.model else { return }
            guard let tmpModelTo = self.cardToField.model else { return }
            self.cardFromField.model = tmpModelTo
            self.cardToField.model = tmpModelFrom
            self.viewModel.cardFromRealm = tmpModelTo
            self.viewModel.cardToRealm = tmpModelFrom
            
            self.bottomView.currencySymbol = tmpModelTo.currency?.getSymbol() ?? ""
            
            let tempBottomViewCurrencyFrom = self.bottomView.currencyFrom
            let tempBottomViewCurrencyTo = self.bottomView.currencyTo
            self.bottomView.currencyFrom = tempBottomViewCurrencyTo
            self.bottomView.currencyTo = tempBottomViewCurrencyFrom
            
            
            self.bottomView.currencyCode = tmpModelTo.currency ?? ""
            
            
            let text = self.bottomView.amountTextField.text
            let unformatText = self.bottomView.moneyFormatter?.unformat(text)
            self.bottomView.exchangeRate(unformatText ?? "")
            self.checkModel(with: self.viewModel)
        }
        
        bottomView.didDoneButtonTapped = { (amaunt) in
            self.doneButtonTapped(with: self.viewModel, amaunt: amaunt)
        }
    }
    
    private func setupFieldFrom() {
        cardFromField.titleLabel.text = "С карты"
        cardFromField.numberCardLabel.text = "Номер карты отправителя"
        cardFromField.didChooseButtonTapped = { [weak self]  () in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    if self?.cardFromListView.isHidden == true {
                        self?.cardFromListView.alpha = 1
                        self?.cardFromListView.isHidden = false
                    } else {
                        self?.cardFromListView.alpha = 0
                        self?.cardFromListView.isHidden = true
                    }
                    
                    self?.seporatorView.curvedLineView.isHidden.toggle()
                    self?.seporatorView.straightLineView.isHidden.toggle()
                    
                    if self?.cardToListView.isHidden == false {
                        self?.cardToListView.isHidden = true
                        self?.cardToListView.alpha = 0
                    }
                    self?.stackView.layoutIfNeeded()
                }
            }
        }
    }
    
    private func setupFieldTo() {
        cardToField.titleLabel.text = "На карту"
        cardToField.numberCardLabel.text = "Номер карты получателя"
        cardToField.didChooseButtonTapped = { [weak self]  () in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    if self?.cardToListView.isHidden == true {
                        self?.cardToListView.alpha = 1
                        self?.cardToListView.isHidden = false
                    } else {
                        self?.cardToListView.alpha = 0
                        self?.cardToListView.isHidden = true
                    }
                    
                    if self?.cardFromListView.isHidden == false {
                        
                        self?.cardFromListView.isHidden = true
                        self?.cardFromListView.alpha = 0
                        
                        self?.seporatorView.curvedLineView.isHidden = false
                        self?.seporatorView.straightLineView.isHidden = true
                    }
                    self?.stackView.layoutIfNeeded()
                }
            }
        }
    }
    
    private func setupListFrom() {
        cardFromListView = CardsScrollView(onlyMy: onlyMy)
        cardFromListView.didCardTapped = { (cardId) in
            DispatchQueue.main.async {
                let cardList = self.realm?.objects(UserAllCardsModel.self).compactMap { $0 } ?? []
                cardList.forEach({ card in
                    if card.id == cardId {
                        self.viewModel.cardFromRealm = card
                        self.cardFromField.model = card
                        self.bottomView.currencySymbol = card.currency?.getSymbol() ?? ""
                        UIView.animate(withDuration: 0.2) {
                            self.cardFromListView.isHidden = true
                            self.cardFromListView.alpha = 0
                            if self.cardToListView.isHidden == false {
                                self.cardToListView.isHidden = true
                            }
                            self.seporatorView.curvedLineView.isHidden = false
                            self.seporatorView.straightLineView.isHidden = true
                            
                            self.stackView.layoutIfNeeded()
                        }
                    }
                })
            }
        }
        cardFromListView.lastItemTap = {
            print("Открывать все карты ")
            let vc = AllCardListViewController()
            vc.withTemplate = false
            if self.onlyMy {
                vc.onlyCard = false
            }
            vc.didCardTapped = { [weak self] card in
//                self?.viewModel.cardFromRealm = card
                self?.viewModel.cardFrom = card
                self?.cardFromField.cardModel = card
                self?.bottomView.currencySymbol = card.currency?.getSymbol() ?? ""
                self?.hideAllCardList()
                vc.dismiss(animated: true, completion: nil)
            }
            let navVc = UINavigationController(rootViewController: vc)
            navVc.modalPresentationStyle = .fullScreen
            self.present(navVc, animated: true, completion: nil)
        }
    }
    
    private func setupListTo() {
        cardToListView = CardsScrollView(onlyMy: onlyMy)
        cardToListView.canAddNewCard = onlyMy ? false : true
        
        cardToListView.firstItemTap = {
            print("Показываем окно новой карты ")
            self.view.addSubview(self.cardView)
            self.cardView.frame = self.view.bounds
            self.cardView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
            self.stackView.isHidden = true
            self.titleLabel.isHidden = true
            self.bottomView.isHidden = true
            self.hideAllCardList()
        }
        cardToListView.didCardTapped = { (cardId) in
            DispatchQueue.main.async {
                let cardList = self.realm?.objects(UserAllCardsModel.self).compactMap { $0 } ?? []
                cardList.forEach({ card in
                    if card.id == cardId {
                        self.viewModel.cardToRealm = card
                        self.cardToField.model = card
                        self.hideAllCardList()
                    }
                })
            }
        }
        cardToListView.lastItemTap = {
            print("Открывать все карты ")
            let vc = AllCardListViewController()
            if self.onlyMy {
                vc.onlyCard = false
                vc.withTemplate = false
            }
            vc.didCardTapped = { [weak self] card in
//                self?.viewModel.cardToRealm = card
                self?.viewModel.cardTo = card
                self?.cardToField.cardModel = card
//                self?.bottomView.currency = card.currency?.getSymbol() ?? ""
                self?.hideAllCardList()
                vc.dismiss(animated: true, completion: nil)
            }
            vc.didTemplateTapped = { [weak self] card in
                self?.viewModel.customCardTo = CastomCardViewModel(cardNumber: card.numberMask ?? "", cardName: card.customName, cardId: card.id)
                self?.cardToField.tempCardModel = card
                self?.hideAllCardList()
                vc.dismiss(animated: true, completion: nil)
            }
            let navVc = UINavigationController(rootViewController: vc)
            navVc.modalPresentationStyle = .fullScreen
            self.present(navVc, animated: true, completion: nil)
        }
    }
    
    private func checkModel(with model: ConfirmViewControllerModel) {
        guard model.cardFromRealm != nil, model.cardToRealm != nil else { return }
        // TODO: какие условия для смены местами: счет - счет, карта - карта?
        self.seporatorView.changeAccountButton.isHidden = true // TODO: для релиза отключена кнопка
        /// Когда скрывается кнопка смены валют, то есть валюта одинаковая, то меняем содеожание лейбла на то, что по умолчанию
        /// Если нет, то оправляем запрос на получения курса валют
        if self.bottomView.currencySwitchButton.isHidden == true {
            self.bottomView.buttomLabel.text = "Возможна комиссия ℹ︎"
        }
    }
       
    private func setupCardViewActions() {
        cardView.closeView = { [weak self] () in
//            self?.hideCustomCardView()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    self?.cardView.alpha = 0
                    self?.stackView.isHidden = false
                    self?.titleLabel.isHidden = false
                    self?.bottomView.isHidden = false
                } completion: { finish in
                    if finish {
                        self?.cardView.removeFromSuperview()
                        self?.cardView.alpha = 1
                    }
                }
            }
        }
        cardView.finishAndCloseView = { [weak self]  (model) in
//            self?.hideCustomCardView()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    self?.cardView.alpha = 0
                    self?.stackView.isHidden = false
                    self?.titleLabel.isHidden = false
                    self?.bottomView.isHidden = false
                } completion: { finish in
                    if finish {
                        self?.cardView.removeFromSuperview()
                        self?.cardView.alpha = 1
                    }
                    self?.viewModel.customCardTo = model
                    self?.cardToField.customCardModel = model
                }
            }
        }
    }
    
    private func hideCustomCardView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.cardView.alpha = 0
                self.stackView.isHidden = false
                self.titleLabel.isHidden = false
                self.bottomView.isHidden = false
            } completion: { finish in
                if finish {
                    self.cardView.removeFromSuperview()
                    self.cardView.alpha = 1
                }
            }
        }
    }
    
    private func hideAllCardList() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                if self.cardFromListView.isHidden == false {
                    self.cardFromListView.isHidden = true
                    self.cardFromListView.alpha = 0
                }
                if self.cardToListView.isHidden == false {
                    self.cardToListView.isHidden = true
                    self.cardToListView.alpha = 0
                }
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - API
    
    func doneButtonTapped(with viewModel: ConfirmViewControllerModel, amaunt: String) {
//        self?.viewModel.summTransction = amaunt
        var viewModel = viewModel
        self.dismissKeyboard()
        self.showActivity()
        bottomView.doneButtonIsEnabled(true)
        let body = [ "check" : false,
                     "amount" : amaunt,
                     "currencyAmount" : self.bottomView.currencyCode,
                     "payer" : [
                        "cardId" : viewModel.cardFromCardId,
                        "cardNumber" : viewModel.cardFromCardNumber,
                        "accountId" : viewModel.cardFromAccountId,
                        "accountNumber" : viewModel.cardFromAccountNumber
                     ],
                     "payeeInternal" : [
                        "cardId" : viewModel.cardToCardId,
                        "cardNumber" : viewModel.cardToCardNumber,
                        "accountId" : viewModel.cardToAccountId,
                        "accountNumber" : viewModel.cardToAccountNumber,
                        "productCustomName" : viewModel.cardToCastomName
                     ] ] as [String : AnyObject]
//        print("DEBUG: ", #function, body)
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { [weak self] model, error in
            DispatchQueue.main.async {
                self?.dismissActivity()
                self?.bottomView.doneButtonIsEnabled(false)
                if error != nil {
                    guard let error = error else { return }
                    print("DEBUG: ", #function, error)
                    self?.showAlert(with: "Ошибка", and: error)
                } else {
                    guard let model = model else { return }
                    guard let statusCode = model.statusCode else { return }
                    if statusCode == 0 {
                        if let needMake = model.data?.needMake {
                            if needMake {
                                viewModel.taxTransction = "\(model.data?.fee ?? 0)"
                                viewModel.statusIsSuccses = true
                                print("DEBUG: cardToCard payment Succses", #function, model)
                                let vc = ContactConfurmViewController()
                                vc.modalPresentationStyle = .fullScreen
                                vc.confurmVCModel?.type = .card2card
                                viewModel.summTransction = model.data?.debitAmount?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                                viewModel.summInCurrency = model.data?.creditAmount?.currencyFormatter(symbol: model.data?.currencyPayee ?? "RUB") ?? ""
                                viewModel.taxTransction = model.data?.fee?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                                vc.smsCodeField.isHidden = !(model.data?.needOTP ?? true)
                                vc.confurmVCModel = viewModel
                                vc.addCloseButton()
                                vc.title = "Подтвердите реквизиты"
                                let navVC = UINavigationController(rootViewController: vc)
                                self?.present(navVC, animated: true)
                                
                            } else {
                                let vc = PaymentsDetailsSuccessViewController()
                                if model.data?.documentStatus == "COMPLETE" {
                                    viewModel.statusIsSuccses = true
                                    viewModel.taxTransction = model.data?.fee?.currencyFormatter(symbol: model.data?.currencyAmount ?? "RUB") ?? ""
                                    viewModel.summTransction = model.data?.debitAmount?.currencyFormatter(symbol: model.data?.currencyAmount ?? "RUB") ?? ""
                                    vc.id = model.data?.paymentOperationDetailID ?? 0
                                    vc.printFormType = "internal"
                                  
                                }
                                vc.confurmVCModel = viewModel
                                vc.modalPresentationStyle = .fullScreen
                                self?.present(vc, animated: true, completion: nil)
                                
                            }
                        } else {
                            viewModel.statusIsSuccses = true
                            let vc = PaymentsDetailsSuccessViewController()
                            vc.confurmVCModel = viewModel
                            vc.modalPresentationStyle = .fullScreen
                            self?.present(vc, animated: true, completion: nil)
                        }
                    } else {
                        print("DEBUG: ", #function, model.errorMessage ?? "nil")
                        self?.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                    }
                }
            }
        }
    }
    
}

