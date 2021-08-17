//
//  MeToMeSettingViewController.swift
//  ForaBank
//
//  Created by Mikhail on 11.08.2021.
//

import UIKit

class MeToMeSettingViewController: UIViewController {

    var model: [FastPaymentContractFindListDatum]? {
        didSet {
            guard let model = model else { return }
            configure(with: model)
        }
    }
    
    var topSwitch = MeToMeSetupSwitchView()
    var cardFromField = CardChooseView()
    var cardListView = CardListView(onlyMy: false)
    var stackView = UIStackView(arrangedSubviews: [])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addCloseButton()
        setupPaymentsUI()
        setupStackView()
        setupTopSwitch()
        setupCardFromView()
        setupCardList { [weak self] error in
            if error != nil {
                self?.showAlert(with: "Ошибка", and: error!)
            }
        }
    }
    
    func configure(with model: [FastPaymentContractFindListDatum]) {
        if !model.isEmpty {
            topSwitch.bankByPhoneSwitch.isOn = true
            topSwitch.configViewWithValue(true)
        } else {
            topSwitch.configViewWithValue(false)
            cardFromField.isHidden = true
        }
    }
    
    func setupStackView() {
        stackView = UIStackView(arrangedSubviews: [topSwitch, cardFromField, cardListView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor)
    }

    func setupPaymentsUI() {
        // настраиваем название контроллера в 2 строки
        self.navigationItem.titleView = setTitle(title: "Настройки СБП", subtitle: "Система быстрых платежей")
        // настраиваем логотип экрана
        let navImage = UIImage(named: "logo-spb-mini")
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.rightBarButtonItem = customViewItem
    }
    
    func setTitle(title: String, subtitle: String) -> UIView {
        // создаем верхний UILabel
        let titleLabel = UILabel(text: title, font: .boldSystemFont(ofSize: 16), color: .black)
        // создаем нижний UILabel
        let subtitleLabel = UILabel(text: subtitle, font: .systemFont(ofSize: 12), color: .gray)
        
        // создаем контейнер для UILabeles
        let titleView = UIView(frame: .zero)
        
        // добавляем UILabeles в контейнер и настраиваем констрайнты
        titleView.addSubview(titleLabel)
        titleLabel.centerX(inView: titleView, topAnchor: titleView.topAnchor)
        titleView.addSubview(subtitleLabel)
        subtitleLabel.centerX(inView: titleView, topAnchor: titleLabel.bottomAnchor, paddingTop: 2)
        titleView.sizeToFit()
        titleView.anchor(left: subtitleLabel.leftAnchor, bottom: subtitleLabel.bottomAnchor, right: subtitleLabel.rightAnchor)
        return titleView
    }
    
    private func setupCardFromView() {
        // настройка поля с текущим счетом
        cardFromField.titleLabel.text = "Счет списания и зачисления"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()
        
        // действие по нажатию на поле с текущем счетом
        cardFromField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
        }
    }
    
    private func setupCardList(completion: @escaping ( _ error: String?) ->() ) {
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async {
                
                if error != nil {
                    completion(error)
                }
                guard let data = data else { return }
                var filterProduct: [GetProductListDatum] = []
                data.forEach { product in
                    if (product.productType == "CARD" || product.productType == "ACCOUNT") && product.currency == "RUB" {
                        filterProduct.append(product)
                    }
                }
                
                self?.cardListView.cardList = filterProduct
                
                if filterProduct.count > 0 {
                    self?.cardFromField.cardModel = filterProduct.first
                    completion(nil)
                }
            }
        }
    }
    
    func setupTopSwitch() {
        topSwitch.switchIsChanged = { (sender) in
            self.hideView(self.cardFromField, needHide: !sender.isOn) {
                if !self.cardListView.isHidden {
                    self.hideView(self.cardListView, needHide: true) { }
                }
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
    
    func hideView(_ view: UIView, needHide: Bool, completion: @escaping () -> Void ) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                view.isHidden = needHide
                view.alpha = needHide ? 0 : 1
                self.stackView.layoutIfNeeded()
            }
        }
        completion()
    }
    
    
    
    //MARK: - API
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?)->()) {
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]
        
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let cardList = model.data else { return }
                completion(cardList, nil)
            } else {
                guard let error = model.errorMessage else { return }
                completion(nil, error)
            }
        }
    }
    
    
}
