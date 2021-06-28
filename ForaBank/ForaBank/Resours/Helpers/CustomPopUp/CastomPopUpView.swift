//
//  CastomPopUpView.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.06.2021.
//

import UIKit
import SwiftEntryKit

protocol CutomViewProtocol: UIView {
    
}

struct CastomPopUpView  {
    
//    let v = MainPopUpView()
    
    let a = MemeDetailVC()
    
    func setupAttributs () -> EKAttributes {
        
        
        var attributes = EKAttributes.bottomNote
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: .init(light: UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), dark: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)))
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.roundCorners = .top(radius: 16)
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 10, offset: .zero))
//        attributes.roundCorners = .all(radius: 10)
        
        attributes.screenBackground = .clear
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 1)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.fill
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.positionConstraints.safeArea = .overridden
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
        attributes.statusBar = .dark
        return attributes
    }
    
    
    func showAlert () {
        
        SwiftEntryKit.display(entry: a , using: setupAttributs())
        
    }
    
    func exit() {
        
        SwiftEntryKit.dismiss()
        
    }
}

class MemeDetailVC : AddHeaderImageViewController {

    var titleLabel = UILabel(text: "Между своими", font: .boldSystemFont(ofSize: 16), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
    
    var cardFromField = ForaInput(
        viewModel: ForaInputModel(
            title: "Откуда",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false))
    
    var seporatorView = SeparatorView()
    var cardFromListView = CardListView()
    
    var cardToField = ForaInput(
        viewModel: ForaInputModel(
            title: "Куда",
            image: #imageLiteral(resourceName: "credit-card"),
            type: .credidCard,
            isEditable: false))
    
    var cardToListView = CardListView()
    
    var bottomView = BottomInputView()
    
    let changeCardButtonCollection = AllCardView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addHeaderImage()
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
        addCloseButton()
        
        self.view.heightAnchor.constraint(equalToConstant: 480).isActive = true
        self.view.backgroundColor = .white
        
        
        cardFromField.didChooseButtonTapped = { [weak self]  () in
            UIView.animate(withDuration: 0.2) {
                self?.cardFromListView.isHidden.toggle()
            }
        }
        cardFromListView.didCardTapped = { [weak self] (card) in
            self?.cardFromField.configCardView(card)
            UIView.animate(withDuration: 0.2) {
                self?.cardFromListView.isHidden = true
                self?.cardToListView.isHidden = true
            }
        }
        cardToField.didChooseButtonTapped = { [weak self]  () in
            UIView.animate(withDuration: 0.2) {
                self?.cardToListView.isHidden.toggle()
            }
        }
        cardToListView.didCardTapped = { [weak self] (card) in
            self?.cardToField.configCardView(card)
            UIView.animate(withDuration: 0.2) {
                self?.cardFromListView.isHidden = true
                self?.cardToListView.isHidden = true
            }
        }
        
        stackView = UIStackView(arrangedSubviews: [cardFromField, seporatorView, cardFromListView, cardToField, cardToListView, changeCardButtonCollection])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
//        addSubview(doneButton)
        
        setupConstraint()
        setupActions()
    }

    private func setupConstraint() {
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 28, paddingLeft: 20)
        
        
        view.addSubview(bottomView)
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor)
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        
        stackView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 20)
//        topLabel.anchor(left: stackView.leftAnchor, paddingLeft: 20)
//        doneButton.anchor(left: leftAnchor, bottom: bottomAnchor,
//                          right: rightAnchor, paddingLeft: 20,
//                          paddingBottom: 40, paddingRight: 20, height: 44)
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
                if data.count > 0 {
                    self?.cardFromField.configCardView(data.first!)
                    self?.cardToField.configCardView(data.first!)
                }
            }
        }
        bottomView.didDoneButtonTapped = { [weak self] () in
            self?.doneButtonTapped()
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
    
    func doneButtonTapped() {
        
        print(#function)
        
        guard let cardFrom = cardFromField.viewModel.cardModel?.number else { return }
        guard let cardto = cardToField.viewModel.cardModel?.number else { return }
        guard let amaunt = bottomView.amountTextField.text else { return }
        
        DispatchQueue.main.async {
            self.showActivity()
        }
        bottomView.doneButtonIsEnabled(true)
        let body = ["check" : false,
                    "amount" : amaunt,
                    "payer" : [ "cardId" : "",
                                "cardNumber" : cardFrom,
                                "carExpireDate" : "",
                                "cardCVV" : "",
                                "accountId" : "",
                                "accountNumber" : "",
                                "phoneNumber" : ""
                    ],
                    "payee" : [ "cardId" : "",
                                "cardNumber" : cardto,
                                "accountId" : "",
                                "accountNumber" : "",
                                "phoneNumber" : ""
                    ]
                    
        ] as [String : AnyObject]
        
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { [weak self] model, error in
            
            self?.dismissActivity()
            self?.bottomView.doneButtonIsEnabled(false)
            if error != nil {
                guard let error = error else { return }
                print("DEBUG: ", #function, error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
                    print("DEBUG: ", #function, model)
                    
                    
                } else {
                    print("DEBUG: ", #function, model?.errorMessage ?? "nil")
                }
                
            }
        }
    }
    
}
