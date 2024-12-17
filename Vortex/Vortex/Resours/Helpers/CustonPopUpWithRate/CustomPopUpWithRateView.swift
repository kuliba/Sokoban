//
//  CustomPopUpWithRateView.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import UIKit
import RealmSwift
import Combine

class CustomPopUpWithRateView: UIViewController {
    
    private var bindings = Set<AnyCancellable>()
    let model: Model = .shared
    
    var titleLabel = UILabel(text: "Между своими", font: .boldSystemFont(ofSize: 18), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
    
    var onlyMy = true
    var cardTo: UserAllCardsModel?
    var cardFrom: UserAllCardsModel?
    var withProducts: Bool = true
    var paymentTemplate: PaymentTemplateData? = nil
    var depositClose: Bool = false
    var meToMeViewModelType: InfoViewController.DepositType? = nil
    var sumMax: Double?
    
    var trasfer = ("", "") {
        didSet {
            /// Обновляем модели в BottomView
            self.bottomView.models = (trasfer.0, trasfer.1)
            self.bottomView.infoButton.isHidden = true
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
            self.trasfer = (cardFrom?.currency ?? "", viewModel.cardToRealm?.currency ?? "")
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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(cardTo: UserAllCardsModel) {
        super.init(nibName: nil, bundle: nil)
        self.cardTo = cardTo
        self.cardToField.getUImage = { self.model.images.value[$0]?.uiImage }
        self.cardToField.model = cardTo
    }
    
    init(cardFrom: UserAllCardsModel, maxSum: Double?) {
        super.init(nibName: nil, bundle: nil)
        self.sumMax = maxSum
        
        self.cardFrom = cardFrom
        self.cardFromField.getUImage = { self.model.images.value[$0]?.uiImage }
        self.cardFromField.model = cardFrom
        self.cardFromField.choseButton?.isHidden = true
        self.cardFromField.choseButton?.isHidden = true
        self.cardFromField.didChooseButtonTapped = nil
        self.bottomView.isEnable = false
        self.withProducts = false
        
        self.bottomView.buttomLabel.text = "Условия снятия"
        self.bottomView.buttomLabel.isHidden = false
        self.bottomView.buttomLabel.alpha = 1
        
        self.bottomView.infoButton.isHidden = false
        self.bottomView.infoButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.bottomView.infoButton.setTitle("", for: .normal)
        self.bottomView.infoButton.isHidden = false
        
        self.bottomView.topLabel.alpha = 1
        
        self.bottomView.doneButton.isEnabled = true
        self.bottomView.doneButtonIsEnabled(false)
        bind()
        guard let currency = cardFrom.currency?.getSymbol() else {
            return
        }
        
        if let maxSum = maxSum {
            
            self.bottomView.amountTextField.text = String(maxSum)
            self.bottomView.setupMoneyController(amount: String(maxSum), currency: currency)
            self.bottomView.maxSum = maxSum
        }
        
        self.bottomView.currencySymbol = currency
    }
    
    init(cardFrom: UserAllCardsModel, totalAmount: Double) {
        super.init(nibName: nil, bundle: nil)
        self.sumMax = totalAmount
        self.cardFrom = cardFrom
        self.cardFromField.getUImage = { self.model.images.value[$0]?.uiImage }
        self.cardFromField.model = cardFrom
        self.cardFromField.choseButton?.isHidden = true
        self.cardFromField.choseButton?.isHidden = true
        self.cardFromField.didChooseButtonTapped = nil
        
        self.bottomView.isEnable = false
        self.withProducts = false
        
        self.bottomView.buttomLabel.text = "Условия снятия"
        self.bottomView.buttomLabel.isHidden = false
        self.bottomView.buttomLabel.alpha = 1
        
        self.bottomView.infoButton.isHidden = false
        self.bottomView.infoButton.addTarget(self, action: #selector(buttonActionTotal), for: .touchUpInside)
        self.bottomView.infoButton.setTitle("", for: .normal)
        self.bottomView.infoButton.isHidden = false
        
        self.bottomView.topLabel.alpha = 1
        
        self.bottomView.doneButton.isEnabled = true
        self.bottomView.doneButtonIsEnabled(false)
        
        bind()
        
        guard let currency = cardFrom.currency?.getSymbol() else {
            return
        }
        
        self.bottomView.amountTextField.text = String(totalAmount)
        self.bottomView.setupMoneyController(amount: String(totalAmount), currency: currency)
        self.bottomView.amountTextField.isUserInteractionEnabled = false
        self.bottomView.currencySymbol = currency
    }
    
    func backButton() {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(back))
        navigationItem.leftBarButtonItem = button
    }
    
    @objc func back(){
        
        if #available(iOS 15, *) {
            viewModel.closeAction()
            navigationController?.popViewController(animated: true)
        } else {
            viewModel.closeAction()
        }
    }
    
    func bind() {
        model.action
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] action in
                
                switch action {
                case _ as ModelAction.Deposits.Close.Request:
                    self.showActivity()
                    
                case let payload as ModelAction.Deposits.Close.Response:
                    self.dismissActivity()
                    switch payload {
                    case .success(let data):
                        let vc = PaymentsDetailsSuccessViewController()
                        
                        if data.documentStatus == .complete {
                            
                            viewModel.status = .succses
                            viewModel.summTransction = self.bottomView.amountTextField.text ?? ""
                            
                            if let paymentOperationDetailId = data.paymentOperationDetailId {
                                
                                viewModel.paymentOperationDetailId = paymentOperationDetailId
                                
                            }
                            
                            guard let cardFrom = self.cardFrom else {
                                return
                            }
                            viewModel.cardFromRealm = cardFrom
                            
                            if let category = data.category {
                                
                                viewModel.dateOfTransction = category
                            }
                            
                            if let comment = data.comment {
                                
                                viewModel.comment = comment
                            }
                            
                        } else if data.documentStatus == .suspended {
                            
                            viewModel.status = .antifraudCanceled
                            viewModel.summTransction = self.bottomView.amountTextField.text ?? ""
                        }
                        
                        vc.confurmVCModel = viewModel
                        vc.confurmVCModel?.type = .closeDeposit
                        vc.printFormType = "closeDeposit"
                        
                        self.present(vc, animated: true, completion: nil)
                        
                    case .failure(let error):
                        self.showAlert(with: "Ошибка", and: error)
                    }
                    
                case _ as ModelAction.Transfers.CreateInterestDepositTransfer.Request:
                    self.showActivity()
                    
                case let payload as ModelAction.Transfers.CreateInterestDepositTransfer.Response:
                    self.dismissActivity()
                    switch payload {
                    case .success(let data):
                        let vc = PaymentsDetailsSuccessViewController()
                        
                        if data.documentStatus == .complete {
                            
                            viewModel.status = .succses
                            viewModel.summTransction = self.bottomView.amountTextField.text ?? ""
                            
                            viewModel.paymentOperationDetailId = data.paymentOperationDetailId
                            
                            viewModel.cardFromRealm = self.cardFrom
                            
                        } else if data.documentStatus == .suspended {
                            
                            viewModel.status = .antifraudCanceled
                            viewModel.summTransction = self.bottomView.amountTextField.text ?? ""
                        }
                        
                        vc.confurmVCModel = viewModel
                        vc.confurmVCModel?.type = .card2card
                        vc.printFormType = "closeDeposit"
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        
                    case .failure(let error):
                        self.dismissActivity()
                        self.showAlert(with: "Ошибка", and: error)
                    }
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        
        let vc = InfoViewController(depositType: .fullWithAmount("Вы можете снять полную или частичную сумму выплаченных процентов, но не более \(sumMax?.currencyFormatter() ?? "")"))
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = self
        self.present(nav, animated: true, completion: nil)
        
    }
    
    @objc func buttonActionTotal(sender: UIButton) {
        
        switch meToMeViewModelType {
            
        case .beforeClosing:
            let vc = InfoViewController(depositType: .beforeClosing)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .custom
            nav.transitioningDelegate = self
            self.present(nav, animated: true, completion: nil)
            
        default:
            let vc = InfoViewController(depositType: .full)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .custom
            nav.transitioningDelegate = self
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    init(paymentTemplate: PaymentTemplateData) {
        super.init(nibName: nil, bundle: nil)
        self.paymentTemplate = paymentTemplate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final func checkModel(with model: ConfirmViewControllerModel) {
        guard let cardFrom = model.cardFromRealm else { return }
        guard let cardTo = model.cardToRealm else { return }
        
        /// Отображаем кнопку для переворачивания списка карт
        
        self.seporatorView.changeAccountButton.isHidden = false
        self.bottomView.currencySwitchButton.isHidden = (model.cardFromRealm?.currency! == model.cardToRealm?.currency!) ? true : false // Правильно true : false сейчас для теста
        self.bottomView.currencySwitchButton.setTitle((model.cardFromRealm?.currency?.getSymbol() ?? "") + " ⇆ " + (model.cardToRealm?.currency?.getSymbol() ?? ""), for: .normal)
        /// Когда скрывается кнопка смены валют, то есть валюта одинаковая, то меняем содержание лейбла на то, что по умолчанию
        
        if self.bottomView.currencySwitchButton.isHidden == true, cardFrom.productType != ProductType.deposit.rawValue, withProducts {
            
            self.bottomView.buttomLabel.text = "Возможна комиссия ℹ︎"
        }
    }
    
    func updateCards(cards: [UserAllCardsModel]) {
        
        self.cardToField.getUImage = { self.model.images.value[$0]?.uiImage }

        if let cardTo = cardTo, cardTo.productType != ProductType.loan.rawValue {
            
            self.cardToField.model = cardTo
            self.viewModel.cardToRealm = cardTo
            
        } else if cardTo?.productType == ProductType.loan.rawValue {
            
            let accountLoan = cards.filter({$0.accountNumber == cardTo?.settlementAccount})
            self.cardToField.model = accountLoan.first
            self.viewModel.cardToRealm = accountLoan.first
        }
        
        self.viewModel.cardFromRealm = cards.first
    }
    
}

extension CustomPopUpWithRateView: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        
        presenter.height = 276
        return presenter
    }
}
