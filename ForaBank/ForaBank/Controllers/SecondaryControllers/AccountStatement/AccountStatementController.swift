//
//  AccountStatementController.swift
//  ForaBank
//
//  Created by Mikhail on 10.11.2021.
//

import UIKit
import RealmSwift

class AccountStatementController: UIViewController {
    var startProduct: GetProductListDatum?
    lazy var realm = try? Realm()

    var dateField = ForaInput(
        viewModel: ForaInputModel(
            title: "Выберите период",
            image: #imageLiteral(resourceName: "date"),
            showChooseButton: true))
    
    var cardFromField: CardChooseView = {
        let cardView =  CardChooseView()
        
        cardView.titleLabel.text = "Банковский продукт"
        cardView.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardView.imageView.isHidden = false
        cardView.leftTitleAncor.constant = 64
        cardView.layoutIfNeeded()
        return cardView
    }()
    
    var cardListView = CardsScrollView(onlyMy: false)
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    lazy var generateButton: UIButton = {
        let button = UIButton(title: "Сформировать выписку")
        button.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        modalPresentationStyle = .fullScreen
        title = "Выписка по счету"
        view.backgroundColor = .white
        addCloseButton()
        setupUI()
        setupActions()
        setButtonEnabled(button: generateButton, isEnabled: true)
    }
    
    private func setButtonEnabled(button: UIButton, isEnabled: Bool) {
        button.isEnabled = isEnabled
        button.backgroundColor = !isEnabled
            ? UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
            : UIColor(red: 1, green: 0.212, blue: 0.212, alpha: 1)
        
        button.setTitleColor(!isEnabled
                             ? UIColor(red: 0.827, green: 0.827, blue: 0.827, alpha: 1)
                             : UIColor.white, for: .normal)
    }
    
    private func setupUI() {
        
        stackView = UIStackView(arrangedSubviews: [cardFromField, cardListView, dateField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        stackView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor, right: view.rightAnchor,
            paddingTop: 20)
        view.addSubview(generateButton)
        generateButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20, paddingBottom: 20,
            paddingRight: 20, height: 48)
        
    }
    
    
    private func readAndSetupCard() {
        DispatchQueue.main.async {
            let cards = ReturnAllCardList.cards()
            self.cardListView.cardList = cards
            if cards.count > 0 {
                cards.forEach { card in
                    if card.id == self.startProduct?.id {
                        self.cardFromField.model = card
                    }
                }
            }
        }
    }
    
    private func setupActions() {
        readAndSetupCard()
        
        cardFromField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                let cardList = self.realm?.objects(UserAllCardsModel.self).compactMap {$0} ?? []
                cardList.forEach({ card in
                    if card.id == cardId {
                        self.cardFromField.model = card
                        if self.cardListView.isHidden == false {
                            self.hideView(self.cardListView, needHide: true)
                        }
                    }
                })
            }
        }
        
    }
    
    @objc private func generateButtonTapped() {
        print(#function)
        
    }
    
    //MARK: - Animation
    func openOrHideView(_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                if view.isHidden == true {
                    view.isHidden = false
                    view.alpha = 1
                } else {
                    view.isHidden = true
                    view.alpha = 0
                }
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    func hideView(_ view: UIView, needHide: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                view.isHidden = needHide
                view.alpha = needHide ? 0 : 1
                self.stackView.layoutIfNeeded()
            }
        }
    }

    
}
