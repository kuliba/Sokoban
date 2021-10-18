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
    
    var trasfer = ("", "") {
        didSet {
               /// Обновляем модели в BottomView
            self.bottomView.models = (trasfer.0, trasfer.1)
        }
    }
    
    var onlyCard = false
    
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
    
    deinit {
        token?.invalidate()
    }
    
    final func checkModel(with model: ConfirmViewControllerModel) {
        guard model.cardFromRealm != nil, model.cardToRealm != nil else { return }
        /// Отображаем кнопку для переворачивания списка карт
        
        self.seporatorView.changeAccountButton.isHidden = false
        self.bottomView.currencySwitchButton.isHidden = (model.cardFromRealm?.currency! == model.cardToRealm?.currency!) ? true : false // Правильно true : false сейчас для теста
        self.bottomView.currencySwitchButton.setTitle((model.cardFromRealm?.currency?.getSymbol() ?? "") + " ⇆ " + (model.cardToRealm?.currency?.getSymbol() ?? ""), for: .normal)
        /// Когда скрывается кнопка смены валют, то есть валюта одинаковая, то меняем содержание лейбла на то, что по умолчанию
        
        if self.bottomView.currencySwitchButton.isHidden == true {
            self.bottomView.buttomLabel.text = "Возможна комиссия ℹ︎"
        }
    }
}

