//
//  ExtensionCustomPopUpWithRateView.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import UIKit
import RealmSwift

extension CustomPopUpWithRateView {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        AddAllUserCardtList.add() {
            print("REALM Add")
        }
        updateObjectWithNotification()
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
    
    private func createTopLabel(title: String) -> UIView {
        let view = UIView()
        let label = UILabel(text: title, font: .systemFont(ofSize: 12), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        
        view.addSubview(label)
        label.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 20)
        view.anchor(height: 20)
        
        return view
    }
    
    func updateObjectWithNotification() {
        let object = realm?.objects(UserAllCardsModel.self)
        token = object?.observe { ( changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                print("REALM Initial")
//                let cards = self.updateCardsList(with: object)
//                self.allCardsFromRealm = cards
            case .update:
                print("REALM Update")
                let cards = self.updateCardsList(with: object)
                self.allCardsFromRealm = cards
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
            if card.productType == "CARD" {
                cardsArray.append(card)
            } else if !onlyCard &&  card.productType == "ACCOUNT" {
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
        
        bottomView.didDoneButtonTapped = { [weak self] (amaunt) in
            self?.viewModel.summTransction = amaunt
            self?.doneButtonTapped(with: self!.viewModel)
        }
    }
    
    private func setupFieldFrom() {
        cardFromField.titleLabel.text = onlyMy ? "Откуда" : "С карты"
        cardFromField.numberCardLabel.text = onlyMy
            ? "Номер карты или счета"
            : "Номер карты отправителя"
        cardFromField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardFromListView) {
                self.seporatorView.curvedLineView.isHidden.toggle()
                self.seporatorView.straightLineView.isHidden.toggle()
                if !self.cardToListView.isHidden {
                    self.hideView(self.cardToListView, needHide: true) { }
                }
            }
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
                if !self.cardFromListView.isHidden {
                    self.hideView(self.cardFromListView, needHide: true) {
                        self.stackView.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    /// Инициализация верхних карт
    private func setupListFrom() {
        cardFromListView = CardsScrollView(onlyMy: onlyMy)
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
    
    /// Инициализация нижних карт
    private func setupListTo() {
        cardToListView = CardsScrollView(onlyMy: onlyMy)
        cardToListView.didCardTapped = { (cardId) in
            DispatchQueue.main.async {
                guard let cardList = self.allCardsFromRealm else { return }
                cardList.forEach({ card in
                    if card.id == cardId {
                        self.viewModel.cardToRealm = card
                        self.reversCard = ""
                        self.cardToField.model = card
                        self.hideView(self.cardToListView, needHide: true) {
                            if !self.cardFromListView.isHidden {
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
                    if !self.cardFromListView.isHidden {
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
