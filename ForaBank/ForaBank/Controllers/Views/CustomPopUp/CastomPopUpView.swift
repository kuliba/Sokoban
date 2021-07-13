//
//  CastomPopUpView.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.06.2021.
//

import UIKit
//import SwiftEntryKit

protocol CutomViewProtocol: UIView {
    
}

class MemeDetailVC : AddHeaderImageViewController {

    var titleLabel = UILabel(text: "Между своими", font: .boldSystemFont(ofSize: 16), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
    
    var onlyMy = true {
        didSet {
//            cardFromListView.onlyMy = onlyMy
//            cardToListView.onlyMy = onlyMy
        }
    }
    
    var viewModel = ConfirmViewControllerModel(type: .card2card) {
        didSet {
            checkModel(with: viewModel)
        }
    }
    
    var cardFromField = CardChooseView()
    var seporatorView = SeparatorView()
    var cardFromListView: CardListView!
    var cardToField = CardChooseView()
    var cardToListView: CardListView!
    var bottomView = BottomInputView()
    lazy var cardView = CastomCardView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        setupActions()
        setupCardViewActions()
    }
    
    private func setupUI() {
        cardFromField.titleLabel.text = "Откуда"
        cardFromListView = CardListView(onlyMy: onlyMy)
        cardFromListView.lastItemTap = {
            print("Открывать все карты ")
            let vc = AllCardListViewController()
            let navVc = UINavigationController(rootViewController: vc)
//            navVc.title = "Выберите карту"
//            navVc.addCloseButton()
            navVc.modalPresentationStyle = .fullScreen
            self.present(navVc, animated: true, completion: nil)
        }
        
        bottomView.currency = "₽"
        
        
        cardToField.titleLabel.text = "Куда"
        cardToListView = CardListView(onlyMy: onlyMy)
        
        cardToListView.lastItemTap = {
            print("Открывать все карты ")
        }
        
        cardToListView.firstItemTap = { [weak self] in
            self?.view.addSubview(self?.cardView ?? UIView())
            self?.cardView.frame = (self?.view.bounds)!
            self?.cardView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
            print("Показываем окно новой карты ")
            self?.stackView.isHidden = true
            self?.titleLabel.isHidden = true
            self?.bottomView.isHidden = true
            self?.hideAllCardList()
        }
        
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
        
        cardFromField.didChooseButtonTapped = { [weak self]  () in
            UIView.animate(withDuration: 0.2) {
                if self?.cardFromListView.isHidden == true {
                    self?.cardFromListView.alpha = 1
                    self?.cardFromListView.isHidden = false
                } else {
                    self?.cardFromListView.alpha = 0
                    self?.cardFromListView.isHidden = true
                }
                
                self?.seporatorView.curvedLineView.isHidden.toggle()
                self?.seporatorView.straightLineView.isHidden.toggle()
                
                if self?.cardToListView.isHidden == false {
                    self?.cardToListView.isHidden = true
                    self?.cardToListView.alpha = 0
                }
                self?.stackView.layoutIfNeeded()
            }
        }
        
        cardFromListView.didCardTapped = { [weak self] (card) in
            self?.viewModel.cardFrom = card
            self?.cardFromField.cardModel = card
            self?.bottomView.currency = card.currency?.getSymbol() ?? ""
            UIView.animate(withDuration: 0.2) {
                self?.cardFromListView.isHidden = true
                
                self?.cardToListView.isHidden = true
                self?.cardFromListView.alpha = 0
                
                self?.seporatorView.curvedLineView.isHidden = false
                self?.seporatorView.straightLineView.isHidden = true
                
                self?.stackView.layoutIfNeeded()
            }
        }
        
        cardToField.didChooseButtonTapped = { [weak self]  () in
            UIView.animate(withDuration: 0.2) {
                if self?.cardToListView.isHidden == true {
                    self?.cardToListView.alpha = 1
                    self?.cardToListView.isHidden = false
                } else {
                    self?.cardToListView.alpha = 0
                    self?.cardToListView.isHidden = true
                }
                
                if self?.cardFromListView.isHidden == false {
                    
                    self?.cardFromListView.isHidden = true
                    self?.cardFromListView.alpha = 0
                    
                    self?.seporatorView.curvedLineView.isHidden = false
                    self?.seporatorView.straightLineView.isHidden = true
                }
                self?.stackView.layoutIfNeeded()
            }
        }
        
        cardToListView.didCardTapped = { [weak self] (card) in
            self?.viewModel.cardTo = card
            self?.cardToField.cardModel = card
            self?.hideAllCardList()
        }
        
        seporatorView.buttonSwitchCardTapped = { () in
            guard let tmpModelFrom = self.cardFromField.cardModel else { return }
            guard let tmpModelTo = self.cardToField.cardModel else { return }
            self.cardFromField.cardModel = tmpModelTo
            self.bottomView.currency = tmpModelTo.currency?.getSymbol() ?? ""
            self.cardToField.cardModel = tmpModelFrom
            self.viewModel.cardFrom = tmpModelTo
            self.viewModel.cardTo = tmpModelFrom
            self.checkModel(with: self.viewModel)
        }
        
        bottomView.didDoneButtonTapped = { [weak self] (amaunt) in
            self?.viewModel.summTransction = amaunt
            self?.doneButtonTapped(with: self!.viewModel)
        }
    }
    
    private func checkModel(with model: ConfirmViewControllerModel) {
        //     curvedLineView straightLineView changeAccountButton
        guard model.cardFrom != nil, model.cardTo != nil else { return }
        // TODO: какие условия для смены местами: счет - счет, карта - карта?
        self.seporatorView.changeAccountButton.isHidden = false
        self.bottomView.currencySwitchButton.isHidden = (model.cardFrom?.currency! == model.cardTo?.currency!) ? true : false // Правильно true : false сейчас для теста
        self.bottomView.currencySwitchButton.setTitle((model.cardFrom?.currency?.getSymbol() ?? "") + " ⇆ " + (model.cardTo?.currency?.getSymbol() ?? ""), for: .normal)
        
        // Запрос на курс валют и после отображение bottomView.currencySwitchButton
//        Запрос курса валют:
//        POST /rest/getExchangeCurrencyRates
//        В телеге описание запроса
    }
    
    private func setupCardViewActions() {
        cardView.closeView = { [weak self] () in
//            self?.hideCustomCardView()
            UIView.animate(withDuration: 0.1) {
                self?.cardView.alpha = 0
                self?.stackView.isHidden = false
                self?.titleLabel.isHidden = false
                self?.bottomView.isHidden = false
            } completion: { finish in
                if finish {
                    self?.cardView.removeFromSuperview()
                    self?.cardView.alpha = 1
                }
            }
        }
        cardView.finishAndCloseView = { [weak self]  (model) in
//            self?.hideCustomCardView()
            UIView.animate(withDuration: 0.1) {
                self?.cardView.alpha = 0
                self?.stackView.isHidden = false
                self?.titleLabel.isHidden = false
                self?.bottomView.isHidden = false
            } completion: { finish in
                if finish {
                    self?.cardView.removeFromSuperview()
                    self?.cardView.alpha = 1
                }
                self?.viewModel.customCardTo = model
                self?.cardToField.customCardModel = model
            }
            
        }
    }
    
    private func hideCustomCardView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.cardView.alpha = 0
                self.stackView.isHidden = false
                self.titleLabel.isHidden = false
                self.bottomView.isHidden = false
            } completion: { finish in
                if finish {
                    self.cardView.removeFromSuperview()
                    self.cardView.alpha = 1
                }
            }
        }
    }
    
    private func hideAllCardList() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.cardFromListView.isHidden = true
                self.cardFromListView.alpha = 0
                
                self.cardToListView.isHidden = true
                self.cardToListView.alpha = 0
                
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - API
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?,_ error: String?)->()) {
        
        NetworkHelper.request(.getProductList) { cardList , error in
            if error != nil {
                completion(nil, error)
            }
            guard let cardList = cardList as? [GetProductListDatum] else { return }
            completion(cardList, nil)
            print("DEBUG: Load card list... Count is: ", cardList.count)
        }
    }
    
    func doneButtonTapped(with viewModel: ConfirmViewControllerModel) {
        
        var viewModel = viewModel
        self.dismissKeyboard()
        self.showActivity()
//        DispatchQueue.main.async {
//            UIApplication.shared.keyWindow?.startIndicatingActivity()
//        }
        bottomView.doneButtonIsEnabled(true)
        let body = [ "check" : false,
                     "amount" : viewModel.summTransction,
                     "currencyAmount" : "RUB",
                     "payer" : [
                        "cardId" : viewModel.cardFromCardId,
                        "cardNumber" : viewModel.cardFromCardNumber,
                        "accountId" : viewModel.cardFromAccountId,
                        "accountNumber" : viewModel.cardFromAccountNumber
                     ],
                     "payeeInternal" : [
                        "cardId" : viewModel.cardToCardId,
                        "cardNumber" : viewModel.cardToCardNumber,
                        "accountId" : viewModel.cardToAccountId,
                        "accountNumber" : viewModel.cardToAccountNumber,
                        "productCustomName" : viewModel.cardToCastomName
                     ] ] as [String : AnyObject]
        print("DEBUG: ", #function, body)
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { [weak self] model, error in
            DispatchQueue.main.async {
//                UIApplication.shared.keyWindow?.stopIndicatingActivity()
                self?.dismissActivity()
                self?.bottomView.doneButtonIsEnabled(false)
                if error != nil {
                    guard let error = error else { return }
                    print("DEBUG: ", #function, error)
                    self?.showAlert(with: "Ошибка", and: error)
                } else {
                    guard let model = model else { return }
                    guard let statusCode = model.statusCode else { return }
                    if statusCode == 0 {
                        if let needMake = model.data?.needMake {
                            if needMake {
                                viewModel.taxTransction = "\(model.data?.fee ?? 0)"
                                viewModel.statusIsSuccses = true
                                print("DEBUG: cardToCard payment Succses", #function, model)
                                let vc = ContactConfurmViewController()
                                vc.modalPresentationStyle = .fullScreen
                                vc.confurmVCModel = viewModel
                                vc.addCloseButton()
                                vc.title = "Подтвердите реквизиты"
                                let navVC = UINavigationController(rootViewController: vc)
                                self?.present(navVC, animated: true)
                                
                            } else {
                                let vc = PaymentsDetailsSuccessViewController()
                                vc.confurmVCModel = viewModel
                                vc.modalPresentationStyle = .fullScreen
                                self?.present(vc, animated: true, completion: nil)
                                
                            }
                        } else {
                            viewModel.statusIsSuccses = true
                            let vc = PaymentsDetailsSuccessViewController()
                            vc.confurmVCModel = viewModel
                            vc.modalPresentationStyle = .fullScreen
                            self?.present(vc, animated: true, completion: nil)
                        }
                    } else {
                        print("DEBUG: ", #function, model.errorMessage ?? "nil")
                        self?.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                    }
                }
            }
        }
    }
    
}

//struct CastomPopUpView  {
//
////    let v = MainPopUpView()
//
//    let a = MemeDetailVC()
//
//    func setupAttributs () -> EKAttributes {
//
//
//        var attributes = EKAttributes.bottomNote
//        attributes.displayDuration = .infinity
//        attributes.screenBackground = .color(color: .init(light: UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), dark: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)))
//        attributes.windowLevel = .normal
//        attributes.position = .bottom
//        attributes.roundCorners = .top(radius: 16)
//        attributes.screenInteraction = .dismiss
//        attributes.entryInteraction = .absorbTouches
//        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 10, offset: .zero))
////        attributes.roundCorners = .all(radius: 10)
//
//        attributes.screenBackground = .clear
//        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
//
//        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 1)
//        let heightConstraint = EKAttributes.PositionConstraints.Edge.fill
//        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
//        attributes.positionConstraints.safeArea = .overridden
//
//        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
//        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
//        attributes.positionConstraints.keyboardRelation = keyboardRelation
//
//        attributes.statusBar = .dark
//        return attributes
//    }
//
//
//    func showAlert () {
//
//        SwiftEntryKit.display(entry: a , using: setupAttributs())
//
//    }
//
//    func exit() {
//
//        SwiftEntryKit.dismiss()
//
//    }
//}
