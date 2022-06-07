//
//  ExtensionCustomPopUpWithRateView.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import UIKit
import RealmSwift
import AnyFormatKit

extension CustomPopUpWithRateView {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        AddAllUserCardtList.add() { }
        if let template = paymentTemplate {
            
            if let cardId = template.parameterList.first?.payer.cardId {
                updateObjectWithNotification(cardId: cardId)
            } else if let accountId = template.parameterList.first?.payer.accountId {
                updateObjectWithNotification(cardId: accountId)
            }
            updateObjectWithTamplate(paymentTemplate: template)
        } else {
            updateObjectWithNotification()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let template = paymentTemplate {
            runBlockAfterDelay(0.2) {
                self.setupAmount(amount: template.amount)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupActions()
        setupCardViewActions()
    }
    
    private func setupUI() {
        setupFieldFrom()
        setupFieldTo()
        setupListFrom()
        setupListTo()
        
        paymentTemplate != nil ? nil : addHeaderImage()
        
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.backgroundColor = .white
        if withProducts {
            
            stackView = UIStackView(arrangedSubviews: [cardFromField,
                                                       seporatorView,
                                                       cardFromListView,
                                                       cardToField,
                                                       cardToListView])
        } else {
            
            stackView = UIStackView(arrangedSubviews: [cardFromField,
                                                       seporatorView,
                                                       cardToField,
                                                       cardToListView])
        }
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
    }
    
    private func setupConstraint() {
        view.addSubview(titleLabel)
        titleLabel.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            paddingTop: 28,
            paddingLeft: 20)
        
        view.addSubview(bottomView)
        bottomView.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor)
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(
            top: view.safeAreaLayoutGuide.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
        
        stackView.anchor(
            top: titleLabel.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 16)
    }
    
    private func createTopLabel(title: String) -> UIView {
        let view = UIView()
        let label = UILabel(text: title, font: .systemFont(ofSize: 12), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        
        view.addSubview(label)
        label.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 20)
        view.anchor(height: 20)
        
        return view
    }
    
    func updateObjectWithTamplate(paymentTemplate: PaymentTemplateData) {
        title = paymentTemplate.name
        titleLabel.text = ""
        
        let button = UIBarButtonItem(image: UIImage(named: "edit-2"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(updateNameTemplate))
        button.tintColor = .black
        navigationItem.rightBarButtonItem = button
        
        
        switch paymentTemplate.type {
        case .betweenTheir:
            if let transfer = paymentTemplate.parameterList.first as? TransferGeneralData {
                
                let object = realm?.objects(UserAllCardsModel.self)
                
                if let cardId = transfer.payeeInternal?.cardId {
                    
                    let card = object?.first(where: { $0.id == cardId })
                    self.cardToField.model = card
                    self.viewModel.cardToRealm = card
                    
                } else if let accountId = transfer.payeeInternal?.accountId {
                    
                    let card = object?.first(where: { $0.id == accountId })
                    self.cardToField.model = card
                    self.viewModel.cardToRealm = card
                }
            }
            self.trasfer = (viewModel.cardFromRealm?.currency ?? "", viewModel.cardToRealm?.currency ?? "")
        default:
            break
        }
    }
    
    @objc private func updateNameTemplate() {
        self.showInputDialog(title: "Название шаблона",
                             actionTitle: "Сохранить",
                             cancelTitle: "Отмена",
                             inputText: paymentTemplate?.name,
                             inputPlaceholder: "Введите название шаблона",
                             actionHandler:  { text in
            
            guard let text = text else { return }
            guard let templateId = self.paymentTemplate?.paymentTemplateId else { return }
            
            if text.isEmpty != true {
                if text.count < 20 {
                    Model.shared.action.send(ModelAction.PaymentTemplate.Update.Requested(
                        name: text,
                        parameterList: nil,
                        paymentTemplateId: templateId))
                    
                    // FIXME: В рефактре нужно слушатель на обновление title
                    self.title = text
                    
                } else {
                    self.showAlert(with: "Ошибка", and: "В названии шаблона не должно быть более 20 символов")
                }
            } else {
                self.showAlert(with: "Ошибка", and: "Название шаблона не должно быть пустым")
            }
        })
    }
    
    func setupAmount(amount: Double?) {
        
        let moneyFormatter = bottomView.moneyFormatter
        let newText = moneyFormatter.format("\(amount ?? 0)") ?? ""
        bottomView.amountTextField.text = newText
        bottomView.doneButtonIsEnabled(newText.isEmpty)
    }
    
    func updateObjectWithNotification(cardId: Int? = nil) {
        let object = realm?.objects(UserAllCardsModel.self)
        if let cardId = cardId {
            let card = object?.first(where: { $0.id == cardId })
            self.cardFromField.model = card
            self.viewModel.cardFromRealm = card
        }
        
        token = object?.observe { [weak self] changes in
            
            guard let self = self else { return }
            switch changes {
            case .initial:
                print("REALM Initial")
                self.allCardsFromRealm = self.updateCardsList(with: object)
            case .update:
                print("REALM Update")
                self.allCardsFromRealm = self.updateCardsList(with: object)
            case .error(let error):
                print("DEBUG token fatalError:", error)
                fatalError("\(error)")
            }
        }
    }
    
    private func updateCardsList(with result: Results<UserAllCardsModel>?) -> [UserAllCardsModel] {
        var cardsArray = [UserAllCardsModel]()
        let cards = result?.compactMap { $0 } ?? []
        cards.forEach { card in
            if card.productType == "CARD", card.productType != ProductType.loan.rawValue {
                cardsArray.append(card)
            } else if !onlyCard && (card.productType == "ACCOUNT" || card.productType == "DEPOSIT" ), card.productType != ProductType.loan.rawValue {
                cardsArray.append(card)
            }
        }
        return cardsArray
    }
    
    
    func setupActions() {
        /// Переворот карт
        seporatorView.buttonSwitchCardTapped = { () in
            guard let tmpModelFrom = self.cardFromField.model else { return }
            guard let tmpModelTo = self.cardToField.model else { return }
            
            self.cardFromField.model = tmpModelTo
            self.cardToField.model = tmpModelFrom
            self.viewModel.cardFromRealm = tmpModelTo
            self.viewModel.cardToRealm = tmpModelFrom
            self.reversCard = ""
        }
        
        if self.cardFromField.model?.productType == ProductType.deposit.rawValue {
            
            self.bottomView.didDoneButtonTapped = { [weak self] (amount) in
                if self?.depositClose ?? false {
                   
                    self?.closeDeposit()
                } else {
                    if let amount = Double(amount) {
                        
                        self?.interestPayment(amount: amount)
                    }
                }
            }
            
        } else {
            bottomView.didDoneButtonTapped = { [weak self] (amount) in
                self?.viewModel.summTransction = amount
                self?.doneButtonTapped(with: self!.viewModel)
            }
        }
    }
    
    private func setupFieldFrom() {
        cardFromField.titleLabel.text = onlyMy ? "Откуда" : "С карты"
        cardFromField.numberCardLabel.text = onlyMy
        ? "Номер карты или счета"
        : "Номер карты отправителя"
        
        if withProducts {
            
            cardFromField.didChooseButtonTapped = { () in
                
                self.openOrHideView(self.cardFromListView) {
                    self.seporatorView.curvedLineView.isHidden.toggle()
                    self.seporatorView.straightLineView.isHidden.toggle()
                    if !self.cardToListView.isHidden {
                        self.hideView(self.cardToListView, needHide: true) { }
                    }
                }
            }
        } else {
            self.cardFromField.model = self.cardFrom
        }
    }
    
    private func setupFieldTo() {
        cardToField.titleLabel.text = onlyMy ? "Куда" : "На карту"
        cardToField.numberCardLabel.text = onlyMy
        ? "Номер карты или счета"
        : "Номер карты получателя"
        
        cardToField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardToListView) {
                self.seporatorView.curvedLineView.isHidden = false
                self.seporatorView.straightLineView.isHidden = true
                if self.withProducts, !self.cardFromListView.isHidden {
                    self.hideView(self.cardFromListView, needHide: true) {
                        self.stackView.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    /// Инициализация верхних карт
    private func setupListFrom() {
        if withProducts {
            cardFromListView = CardsScrollView(onlyMy: onlyMy, deleteDeposit: true)
            cardFromListView.didCardTapped = { (cardId) in
                DispatchQueue.main.async {
                    guard let cardList = self.allCardsFromRealm else { return }
                    cardList.forEach({ card in
                        if card.id == cardId {
                            self.viewModel.cardFromRealm = card
                            self.reversCard = ""
                            self.cardFromField.model = card
                            self.hideView(self.cardFromListView, needHide: true) {
                                if !self.cardToListView.isHidden {
                                    self.hideView(self.cardToListView, needHide: true) { }
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
                vc.didCardTapped = { card in
                    self.viewModel.cardFrom = card
                    self.reversCard = ""
                    self.cardFromField.cardModel = card
                    if !self.cardFromListView.isHidden {
                        self.hideView(self.cardFromListView, needHide: true) {
                            self.hideView(self.cardToListView, needHide: true) {
                                self.stackView.layoutIfNeeded()
                            }
                        }
                    }
                    vc.dismiss(animated: true, completion: nil)
                }
                let navVc = UINavigationController(rootViewController: vc)
                navVc.modalPresentationStyle = .fullScreen
                self.present(navVc, animated: true, completion: nil)
            }
        }
    }
    
    /// Инициализация нижних карт
    private func setupListTo() {
        
        if withProducts {
            
            cardToListView = CardsScrollView(onlyMy: onlyMy)
        } else {
            
            cardToListView = CardsScrollView(onlyMy: onlyMy, deleteDeposit: true)
            
        }
        
        cardToListView.didCardTapped = { (cardId) in
            DispatchQueue.main.async {
                guard let cardList = self.allCardsFromRealm else { return }
                cardList.forEach({ card in
                    if card.id == cardId {
                        self.viewModel.cardToRealm = card
                        self.reversCard = ""
                        self.cardToField.model = card
                        self.hideView(self.cardToListView, needHide: true) {
                            if self.withProducts, !self.cardFromListView.isHidden {
                                self.hideView(self.cardFromListView, needHide: true) { }
                            }
                            self.stackView.layoutIfNeeded()
                        }
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
            vc.didCardTapped = { card in
                self.viewModel.cardTo = card
                self.reversCard = ""
                self.cardToField.cardModel = card
                self.hideView(self.cardToListView, needHide: true) {
                    if let cardFromListView = self.cardFromListView, !cardFromListView.isHidden {
                        self.hideView(self.cardFromListView, needHide: true) { }
                    }
                    self.stackView.layoutIfNeeded()
                }
                vc.dismiss(animated: true, completion: nil)
            }
            vc.didTemplateTapped = { card in
                self.viewModel.customCardTo = CastomCardViewModel(cardNumber: card.numberMask ?? "", cardName: card.customName, cardId: card.id)
                self.cardToField.tempCardModel = card
                if !self.cardFromListView.isHidden {
                    self.hideView(self.cardFromListView, needHide: true) { }
                }
                if !self.cardToListView.isHidden {
                    self.hideView(self.cardToListView, needHide: true) { }
                }
                self.stackView.layoutIfNeeded()
                vc.dismiss(animated: true, completion: nil)
            }
            let navVc = UINavigationController(rootViewController: vc)
            navVc.modalPresentationStyle = .fullScreen
            self.present(navVc, animated: true, completion: nil)
        }
    }
   
}
