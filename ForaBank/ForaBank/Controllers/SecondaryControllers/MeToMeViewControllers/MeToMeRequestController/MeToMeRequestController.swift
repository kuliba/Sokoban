//
//  MeToMeRequestController.swift
//  ForaBank
//
//  Created by Mikhail on 30.08.2021.
//

import UIKit

struct RequestMeToMeModel {
    var amount: Double?
    var bank: BankFullInfoList?
}

class MeToMeRequestController: UIViewController {

    var viewModel: RequestMeToMeModel?
    
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
        
        
        
//        guard let model = self.viewModel else { return }
//        fillData(model: model)
    }
    
    func fillData(model: RequestMeToMeModel) {
//        self.currencyLabel.text = model.amount?.currencyFormatter(symbol: "RUB")
//        self.bankLabel.text = model.bank?.fullName
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
        
        summTransctionField.text = Double(1000).currencyFormatter(symbol: "RUB")
        taxTransctionField.text = Double(0).currencyFormatter(symbol: "RUB")
    }
    
    
    
    
    
    
}
