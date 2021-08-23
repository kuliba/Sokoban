//
//  ExtensionCustomPopUpWithRateView.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import UIKit

extension CustomPopUpWithRateView {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
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
        self.view.layer.cornerRadius = 20
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.clipsToBounds = true
        self.view.backgroundColor = .white
        self.view.anchor(width: UIScreen.main.bounds.width, height: 470)
        
        stackView = UIStackView(arrangedSubviews: [cardFromField,
                                                   seporatorView,
                                                   cardFromListView,
                                                   cardToField,
                                                   cardToListView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 0
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
    
    func setupActions() {
        /// Получаем список карт для обеих списков карт
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async {
                if error != nil {
                    print("Ошибка", error!)
                }
                guard let data = data else { return }
                self?.cardFromListView.cardList = data
                self?.cardToListView.cardList = data
            }
        }
        
        /// Переворот карт
        seporatorView.buttonSwitchCardTapped = { () in
            guard let tmpModelFrom = self.cardFromField.cardModel else { return }
            guard let tmpModelTo = self.cardToField.cardModel else { return }
            
                self.cardFromField.cardModel = tmpModelTo
                self.cardToField.cardModel = tmpModelFrom
                self.viewModel.cardFrom = tmpModelTo
                self.viewModel.cardTo = tmpModelFrom
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
        cardFromListView = CardListView(onlyMy: onlyMy)
        cardFromListView.didCardTapped = { [weak self] (card) in
            self?.viewModel.cardFrom = card
            self?.reversCard = ""
            self?.cardFromField.cardModel = card
            self?.hideView((self?.cardFromListView)!, needHide: true) {
                self?.hideView((self?.cardToListView)!, needHide: true) {
                    self?.seporatorView.curvedLineView.isHidden = false
                    self?.seporatorView.straightLineView.isHidden = true
                    self?.stackView.layoutIfNeeded()
                }
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
                self?.viewModel.cardFrom = card
                self?.reversCard = ""
                self?.cardFromField.cardModel = card
                self?.hideView((self?.cardFromListView)!, needHide: true) {
                    self?.hideView((self?.cardToListView)!, needHide: true) {
                        self?.stackView.layoutIfNeeded()
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
        cardToListView = CardListView(onlyMy: onlyMy)
        cardToListView.canAddNewCard = onlyMy ? false : true
//        cardToListView.firstItemTap = { [weak self] in
//            print("Показываем окно новой карты ")
//            self?.view.addSubview(self?.cardView ?? UIView())
//            self?.cardView.frame = (self?.view.bounds)!
//            self?.cardView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
//            self?.stackView.isHidden = true
//            self?.titleLabel.isHidden = true
//            self?.bottomView.isHidden = true
//          //  self?.hideAllCardList()
//        }
        cardToListView.didCardTapped = { [weak self] (card) in
            self?.viewModel.cardTo = card
            self?.reversCard = ""
            self?.cardToField.cardModel = card
            self?.hideView((self?.cardFromListView)!, needHide: true) {
                self?.hideView((self?.cardToListView)!, needHide: true) {
                    self?.stackView.layoutIfNeeded()
                }
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
                self?.viewModel.cardTo = card
                self?.reversCard = ""
                self?.cardToField.cardModel = card
                self?.hideView((self?.cardFromListView)!, needHide: true) {
                    self?.hideView((self?.cardToListView)!, needHide: true) {
                        self?.stackView.layoutIfNeeded()
                    }
                }
                vc.dismiss(animated: true, completion: nil)
            }
            vc.didTemplateTapped = { [weak self] card in
                self?.viewModel.customCardTo = CastomCardViewModel(cardNumber: card.numberMask ?? "", cardName: card.customName, cardId: card.id)
                self?.cardToField.tempCardModel = card
                self?.hideView((self?.cardFromListView)!, needHide: true) {
                    self?.hideView((self?.cardToListView)!, needHide: true) {
                        self?.stackView.layoutIfNeeded()
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
