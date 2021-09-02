//
//  MeToMeRequestController.swift
//  ForaBank
//
//  Created by Mikhail on 30.08.2021.
//

import UIKit
import RealmSwift

struct RequestMeToMeModel {
    var amount: Double
    var fee: Double
    var bank: BankFullInfoList?
    var card: UserAllCardsModel?
    var RecipientID: String?
    var RcvrMsgId: String?
    var RefTrnId: String?
    
    lazy var realm = try? Realm()
    
    init(amount: Double, bankId: String, fee: Double, cardId: Int?, accountId: Int?) {
        self.amount = amount
        self.fee = fee
        self.bank = findBank(with: bankId)
        self.card = findProduct(with: cardId, with: accountId)
    }
    
    private func findBank(with bankId: String) -> BankFullInfoList? {
        let bankList = Dict.shared.bankFullInfoList
        var bankForReturn: BankFullInfoList?
        bankList?.forEach({ bank in
            if bank.memberID == bankId {
                bankForReturn = bank
            }
        })
        return bankForReturn
    }
    
    private mutating func findProduct(with cardId: Int?, with accountId: Int?) -> UserAllCardsModel? {
        let cardList = realm?.objects(UserAllCardsModel.self)
        var card: UserAllCardsModel?
        cardList?.forEach { product in
            if cardId != nil {
                if product.id == cardId {
                    card = product
                }
            } else {
                if product.id == accountId {
                    card = product
                }
            }
        }
        return card
    }
    
}

class MeToMeRequestController: UIViewController {

    var viewModel: RequestMeToMeModel? {
        didSet {
            guard let model = self.viewModel else { return }
            fillData(model: model)
        }
    }
    
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 400)
    
    // MARK: - Views
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .white
        view.frame = self.view.bounds
        view.contentSize = contentViewSize
        view.autoresizingMask = .flexibleHeight
        view.showsHorizontalScrollIndicator = true
        view.bounces = true
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame.size = contentViewSize
        return view
    }()
    
    lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular_Medium", size: 18)
        label.text = "Вы запросили перевод на свой счет"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    lazy var labelSubTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 14)
        label.text = "Денежные средства будут списываться по вашим запросам из Bank Y без подтверждения?"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Банк",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false))
    
    lazy var cardFromField: CardChooseView = {
       let cardField = CardChooseView()
        cardField.titleLabel.text = "Счет списания"
        cardField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardField.imageView.isHidden = false
        cardField.choseButton.isHidden = true
        cardField.leftTitleAncor.constant = 64
        cardField.layoutIfNeeded()
        return cardField
    }()
        
    lazy var cardListView = CardListView(onlyMy: false)
    
    lazy var summTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма перевода",
            image: #imageLiteral(resourceName: "coins"),
            isEditable: false))
    
    lazy var taxTransctionField = ForaInput(
        viewModel: ForaInputModel(
            title: "Комиссия",
            image: #imageLiteral(resourceName: "Frame 580"),
            isEditable: false))
    
    lazy var fpsSwitch: UIView = {
        let view = UIView()
        var topSwitch = MeToMeSetupSwitchView()
        view.addSubview(topSwitch)
        topSwitch.anchor(
            top: view.topAnchor, left: view.leftAnchor,
            bottom: view.bottomAnchor, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        topSwitch.layer.cornerRadius = 8
        topSwitch.clipsToBounds = true
        return view
    }()
    
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Center of container view"
        return label
    }()
    
    //MARK: - Viewlifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        
        let navImage = UIImage(named: "logo-spb-mini")
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.rightBarButtonItem = customViewItem
        
        let model = RequestMeToMeModel(amount: 2344.59, bankId: "100000000004", fee: 0.5, cardId: 10000164837, accountId: nil)
        
        self.viewModel = model
    }
    
    func fillData(model: RequestMeToMeModel) {
        summTransctionField.text = model.amount.currencyFormatter(symbol: "RUB")
        taxTransctionField.text = model.fee.currencyFormatter(symbol: "RUB")
        bankField.text = model.bank?.rusName ?? ""
        bankField.imageView.image = model.bank?.svgImage?.convertSVGStringToImage()
        labelSubTitle.text = "Денежные средства будут списываться по вашим запросам из \(model.bank?.rusName ?? "bank") без подтверждения?"
        cardFromField.model = model.card
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        
        let topView = UIView()
        let labelImage = UIImageView(image: UIImage(named: "incomeMeToMe"))
        topView.addSubview(labelImage)
        topView.setDimensions(height: 72, width: 72)
        topView.backgroundColor = #colorLiteral(red: 1, green: 0.6547051072, blue: 0.2695361376, alpha: 1)
        topView.layer.cornerRadius = 36
        topView.clipsToBounds = true
        labelImage.setDimensions(height: 48, width: 48)
        labelImage.center(inView: topView)
        
        let stackView = UIStackView(
            arrangedSubviews: [bankField, cardFromField, cardListView, summTransctionField, taxTransctionField, fpsSwitch])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 24
        
        containerView.addSubview(topView)
        containerView.addSubview(labelTitle)
        containerView.addSubview(labelSubTitle)
        containerView.addSubview(stackView)
        
        topView.centerX(
            inView: view, topAnchor: containerView.topAnchor, paddingTop: 30)
        
        labelTitle.centerX(
            inView: view, topAnchor: topView.bottomAnchor, paddingTop: 24)
        
        labelTitle.anchor(
            left: view.leftAnchor, right: view.rightAnchor,
            paddingLeft: 20, paddingRight: 20)
        
        labelSubTitle.centerX(
            inView: view, topAnchor: labelTitle.bottomAnchor, paddingTop: 24)
        
        labelSubTitle.anchor(
            left: view.leftAnchor, right: view.rightAnchor,
            paddingLeft: 20, paddingRight: 20)
        
        stackView.anchor(
            top: labelSubTitle.bottomAnchor, left: containerView.leftAnchor,
            right: containerView.rightAnchor, paddingTop: 20, paddingRight: 20)
        
    }
    
    
    
    
    
    
}
