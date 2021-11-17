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
            isEditable: false,
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
    
    var dateView = DateChooseView()
    
    lazy var generateButton: UIButton = {
        let button = UIButton(title: "Сформировать выписку")
        button.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Выписка по счету"
        view.backgroundColor = .white
        addCloseButton()
        setupUI()
        setupActions()
        setButtonEnabled(button: generateButton, isEnabled: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardFromField.balanceLabel.isHidden = true
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
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.82)
        let topView = UIView()
        topView.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.82)
        
        let segmentedControl = UISegmentedControl(items: ["Новая", "Готовые"])
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 224, height: 32)
//        segmentedControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.isEnabled = false
        
        let topLabel = UILabel(text: "Отражает подтвержденные оперции по счету за выбранный период.", font: .systemFont(ofSize: 12))
        topLabel.numberOfLines = 0
        
        
        stackView = UIStackView(arrangedSubviews: [cardFromField, cardListView, dateField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        
        view.addSubview(topView)
        topView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            height: 40)
        
        topView.addSubview(segmentedControl)
        segmentedControl.setDimensions(height: 32, width: 224)
        segmentedControl.centerX(
            inView: topView,
            topAnchor: topView.topAnchor,
            paddingTop: 0)
        
        view.addSubview(topLabel)
        topLabel.anchor(
            top: topView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20,
            paddingLeft: 20,
            paddingRight: 20,
            height: 32)
        
        view.addSubview(stackView)
        stackView.anchor(
            top: topLabel.bottomAnchor,
            left: view.leftAnchor, right: view.rightAnchor,
            paddingTop: 20)
        
        view.addSubview(dateView)
        dateView.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        
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
        
        dateField.didChooseButtonTapped = { () in
            self.openOrHideView(self.dateView)
            if self.cardListView.isHidden == false {
                self.hideView(self.cardListView, needHide: true)
            }
        }
        
        dateView.buttonIsTapped = { button in
            print(button.tag)
            if self.cardListView.isHidden == false {
                self.hideView(self.cardListView, needHide: true)
            }
            if self.dateView.isHidden == false {
                self.hideView(self.dateView, needHide: true)
            }
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
