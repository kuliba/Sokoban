//
//  ConfurmOpenDepositViewController.swift
//  ForaBank
//
//  Created by Mikhail on 03.12.2021.
//

import UIKit
import AnyFormatKit
import RealmSwift

class ConfurmOpenDepositViewController: PaymentViewController {
    
    lazy var realm = try? Realm()
    var product: OpenDepositDatum? {
        didSet {
            guard let product = product else { return }
            nameField.text = product.name ?? ""
        }
    }
    var choosenRateList: [TermRateSumTermRateList]?
    var choosenRate: TermRateSumTermRateList? {
        didSet {
            guard let choosenRate = choosenRate else { return }
            termField.text = "\(choosenRate.termName ?? "")"
            rateField.text = "\(choosenRate.rate ?? 0.0)%"
        }
    }
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Наименования вклада",
            image: UIImage(named: "depositIcon")!,
            isEditable: false))
    
    var termField = ForaInput(
        viewModel: ForaInputModel(
            title: "Срок вклада",
            image: #imageLiteral(resourceName: "date"),
            isEditable: false,
            showChooseButton: true))
    
    var rateField = ForaInput(
        viewModel: ForaInputModel(
            title: "Процентная ставка",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    var incomeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Ваш потенциальный доход",
            image: #imageLiteral(resourceName: "Frame 579"),
            isEditable: false,
            showChooseButton: true))
    
    var cardFromField = CardChooseView()
    
    var cardListView = CardsScrollView(onlyMy: false)
    
    var smsCodeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Введите код из СМС",
            image: UIImage(named: "message-square")!,
            type: .smsCode))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        readAndSetupCard()
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: bottomView.amountTextField, queue: .main) { _ in
            guard let text = self.bottomView.amountTextField.text else { return }
            guard let unformatText = self.bottomView.moneyFormatter?.unformat(text) else { return }
            guard let value = Float(unformatText) else { return }
            self.calculateSumm(with: value)
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: bottomView.amountTextField, queue: .main) { _ in
            guard let text = self.bottomView.amountTextField.text else { return }
            guard let unformatText = self.bottomView.moneyFormatter?.unformat(text) else { return }
            guard let value = Int(unformatText) else { return }
            if value < self.product?.generalСondition?.minSum ?? 5000 {
                let newText = self.bottomView.moneyFormatter?.format("\(self.product?.generalСondition?.minSum ?? 5000)")
                self.bottomView.amountTextField.text = newText
                self.calculateSumm(with: Float(self.product?.generalСondition?.minSum ?? 5000))
            }
        }
    }
    
    func setupUI() {
        
        title = "Подтвердите параметры вклада"
//        view.addSubview(bottomView)
        bottomView.currencySymbol = "₽"
        bottomView.buttomLabel.isHidden = true
        stackView.addArrangedSubview(nameField)
        stackView.addArrangedSubview(termField)
        stackView.addArrangedSubview(rateField)
        stackView.addArrangedSubview(incomeField)
        stackView.addArrangedSubview(cardFromField)
        stackView.addArrangedSubview(cardListView)
        stackView.addArrangedSubview(smsCodeField)
        
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()
        
        termField.didChooseButtonTapped = {
            let controller = SelectDepositPeriodViewController()
            controller.elements = self.choosenRateList
            controller.itemIsSelect = { elem in
                self.choosenRate = elem
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .custom
            navController.transitioningDelegate = self
            self.present(navController, animated: true)
        }
        
        cardFromField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                let cardList = self.realm?.objects(UserAllCardsModel.self).compactMap { $0 } ?? []
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
    
    private func readAndSetupCard() {
        DispatchQueue.main.async {
            var filterProduct: [UserAllCardsModel] = []
            let cards = ReturnAllCardList.cards()
            cards.forEach { product in
                if (product.productType == "CARD"
                        || product.productType == "ACCOUNT") && product.currency == "RUB" {
                    filterProduct.append(product)
                }
            }
            self.cardListView.cardList = filterProduct
            if filterProduct.count > 0 {
                self.cardFromField.model = filterProduct.first
            }
        }
    }
    
    private func calculateSumm(with value: Float) {
        chooseRate(from: value)
        let interestRate = Float(choosenRate?.rate ?? 0)
        let termDay = Float(choosenRate?.term ?? 0)
        
        let income = ( (value * interestRate * termDay) / 365 ) / 100
        
        incomeField.text = bottomView.moneyFormatter?.format("\(income)") ?? ""
    }
    
    private func chooseRate(from value: Float) {
        guard let mainRateList = self.product?.termRateList else { return }
        mainRateList.forEach { termRateList in
            if termRateList.сurrencyCode == "RUR" || termRateList.сurrencyCode == "RUB" {
                let termRateSumm = termRateList.termRateSum
                termRateSumm?.forEach({ rateSum in
                    if value >= Float(rateSum.sum ?? 0) {
                        choosenRateList = rateSum.termRateList
                    }
                })
            }
        }
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

extension ConfurmOpenDepositViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        if let nav = presented as? UINavigationController {
            if let controller = nav.viewControllers.first as? SelectDepositPeriodViewController {
                presenter.height = ((controller.elements?.count ?? 1) * 56) + 80
            }
        } else {
            presenter.height = (4 * 44) + 160
        }
        return presenter
    }
}
