//
//  CustomPopUpWithRateView.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import UIKit

class CustomPopUpWithRateView : AddHeaderImageViewController {

    var titleLabel = UILabel(text: "Между счетами", font: .boldSystemFont(ofSize: 18), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
    
    var onlyMy = true
    
    var trasfer = ("", "") {
        didSet {
               /// Обновляем модели в BottomView
            self.bottomView.models = (trasfer.0, trasfer.1)
        }
    }
    
    var onlyCard = false
    
    var viewModel = ConfirmViewControllerModel(type: .card2card) {
        didSet {
            checkModel(with: viewModel)
        }
    }
    
    var reversCard = "" {
        didSet {
            self.trasfer = (viewModel.cardFrom?.currency ?? "", viewModel.cardTo?.currency ?? "")
        }
    }
    
    
    var cardFromField = CardChooseView()
    var seporatorView = SeparatorView()
    var cardFromListView: CardListView!
    var cardToField = CardChooseView()
    var cardToListView: CardListView!
    var bottomView = BottomInputViewWithRateView()
    lazy var cardView = CastomCardView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    final func checkModel(with model: ConfirmViewControllerModel) {
        guard model.cardFrom != nil, model.cardTo != nil else { return }
        /// Отображаем кнопку для переворачивания списка карт
        
        self.seporatorView.changeAccountButton.isHidden = false
        self.bottomView.currencySwitchButton.isHidden = (model.cardFrom?.currency! == model.cardTo?.currency!) ? true : false // Правильно true : false сейчас для теста
        self.bottomView.currencySwitchButton.setTitle((model.cardFrom?.currency?.getSymbol() ?? "") + " ⇆ " + (model.cardTo?.currency?.getSymbol() ?? ""), for: .normal)
        /// Когда скрывается кнопка смены валют, то есть валюта одинаковая, то меняем содержание лейбла на то, что по умолчанию
        
        if self.bottomView.currencySwitchButton.isHidden == true {
            self.bottomView.buttomLabel.text = "Возможна комиссия ℹ︎"
        }
    }
}

