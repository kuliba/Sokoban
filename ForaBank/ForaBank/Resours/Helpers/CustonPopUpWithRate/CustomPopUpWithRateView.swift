//
//  CustomPopUpWithRateView.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import UIKit
import RealmSwift

class CustomPopUpWithRateView : AddHeaderImageViewController {
    
    var titleLabel = UILabel(text: "Между счетами", font: .boldSystemFont(ofSize: 18), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
    lazy var realm = try? Realm()
    var token: NotificationToken?
    var onlyMy = true
    var cardTo: UserAllCardsModel?
    
    var paymentTemplate: PaymentTemplateData? = nil
    
    var trasfer = ("", "") {
        didSet {
            /// Обновляем модели в BottomView
            self.bottomView.models = (trasfer.0, trasfer.1)
        }
    }
    
    var onlyCard = false
    var allCardsFromRealm: [UserAllCardsModel]? {
        didSet {
            guard let allCardsFromRealm = allCardsFromRealm else { return }
            updateCards(cards: allCardsFromRealm)
        }
    }
    var viewModel: ConfirmViewControllerModel! {
        didSet {
            checkModel(with: viewModel)
        }
    }
    
    var reversCard = "" {
        didSet {
            self.trasfer = (viewModel.cardFromRealm?.currency ?? "", viewModel.cardToRealm?.currency ?? "")
        }
    }
    
    
    var cardFromField = CardChooseView()
    var seporatorView = SeparatorView()
    var cardFromListView: CardsScrollView!
    var cardToField = CardChooseView()
    var cardToListView: CardsScrollView!
    
    var bottomView = BottomInputViewWithRateView()
    lazy var cardView = CastomCardView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        token?.invalidate()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(cardTo: UserAllCardsModel) {
        super.init(nibName: nil, bundle: nil)
        self.cardTo = cardTo
    }
    
    init(paymentTemplate: PaymentTemplateData) {
        super.init(nibName: nil, bundle: nil)
        self.paymentTemplate = paymentTemplate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        token?.invalidate()
    }
    
    final func checkModel(with model: ConfirmViewControllerModel) {
        guard let cardFrom = model.cardFromRealm else { return }
        guard let cardTo = model.cardToRealm else { return }
        //        guard model.cardFrom != nil, model.cardTo != nil else { return }
        print("Отображаем кнопку для переворачивания списка карт")
        /// Отображаем кнопку для переворачивания списка карт
        
        self.seporatorView.changeAccountButton.isHidden = false
        self.bottomView.currencySwitchButton.isHidden = (model.cardFromRealm?.currency! == model.cardToRealm?.currency!) ? true : false // Правильно true : false сейчас для теста
        self.bottomView.currencySwitchButton.setTitle((model.cardFromRealm?.currency?.getSymbol() ?? "") + " ⇆ " + (model.cardToRealm?.currency?.getSymbol() ?? ""), for: .normal)
        /// Когда скрывается кнопка смены валют, то есть валюта одинаковая, то меняем содержание лейбла на то, что по умолчанию
        
        if self.bottomView.currencySwitchButton.isHidden == true {
            self.bottomView.buttomLabel.text = "Возможна комиссия ℹ︎"
        }
    }
    
    func updateCards(cards: [UserAllCardsModel]) {
  
        if let cardTo = cardTo, cardTo.productType != ProductType.loan.rawValue {
            
            self.cardToField.model = cardTo
            self.viewModel.cardToRealm = cardTo
        } else if cardTo?.productType == ProductType.loan.rawValue {
            
            let accountLoan = cards.filter({$0.accountNumber == cardTo?.settlementAccount})
            self.cardToField.model = accountLoan.first
            self.viewModel.cardToRealm = accountLoan.first
        }
        
        self.cardFromField.model = cards.first
        self.viewModel.cardFromRealm = cards.first
    }
    
}

