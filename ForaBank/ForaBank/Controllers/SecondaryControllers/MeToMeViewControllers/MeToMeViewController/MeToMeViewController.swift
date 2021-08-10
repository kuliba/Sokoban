//
//  MeToMeViewController.swift
//  ForaBank
//
//  Created by Mikhail on 09.08.2021.
//

import UIKit

class MeToMeViewController: UIViewController {
    
    var selectedCardNumber = ""
    var selectedBank: BankFullInfoList? {
        didSet {
            guard let bank = selectedBank else { return }
            setupBankField(bank: bank)
        }
    }

    var banks: [BankFullInfoList] = [] {
        didSet {
            bankListView.bankList = banks
        }
    }
    var cardFromField = CardChooseView()
    var cardListView = CardListView(onlyMy: false)
    var bankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Из банка",
            image: #imageLiteral(resourceName: "BankIcon"),
            isEditable: false,
            showChooseButton: true)
    )
    var bankListView = FullBankInfoListView()
    var commentView = ForaInput(
        viewModel: ForaInputModel(
            title: "Комментарий",
            image: #imageLiteral(resourceName: "comment"))
    )
    var bottomView = BottomInputView()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    //MARK: - Viewlifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()

    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        setupBottomView()
        setupStackView()
        setupCardFromView()
        setupActions()
        setupPaymentsUI()
        setupCardList { [weak self] error in
            if error != nil {
                self?.showAlert(with: "Ошибка", and: error!)
            }
        }
    }
    
    func setupStackView() {
        //TODO: добавить скроллвью что бы избежать проблем на маленьких экранах
        // let scroll
        //  let view1 = UIView()
        //  view1.addSubview(stackView)
        // scroll add view1
        stackView = UIStackView(arrangedSubviews: [cardFromField, cardListView,  bankField, bankListView, commentView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 20)
    }
    
    func setupPaymentsUI() {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 44.0))
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "Пополнить со счета\nв другом банке"
        self.navigationItem.titleView = label
        
        var system: PaymentSystemList?
//        Dict.shared.paymentList?.forEach({ $0.code == "SFP"
//
//        })
        
        Dict.shared.paymentList?.forEach({ systemlist in
            if systemlist.code == "SFP" {
                system = systemlist
            }
        })
        let navImage: UIImage = system?.svgImage?.convertSVGStringToImage() ?? UIImage()
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.rightBarButtonItem = customViewItem
        
    }
    
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        
//        let imageAttachment = NSTextAttachment()
//        imageAttachment.image = UIImage(systemName: "chevron.down")
//        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)

//        let attachmentString = NSAttributedString(attachment: imageAttachment)
        
        
        let completeText = NSMutableAttributedString(string: "")
        let text = NSAttributedString(string: title , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)])
        completeText.append(text)
//        completeText.append(attachmentString)
        
        titleLabel.attributedText = completeText
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .black
        subtitleLabel.font = .boldSystemFont(ofSize: 16)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
//        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
//
//        if widthDiff < 0 {
//            let newX = widthDiff / 2
//            subtitleLabel.frame.origin.x = abs(newX)
//        } else {
//            let newX = widthDiff / 2
//            titleLabel.frame.origin.x = newX
//        }
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.titleDidTaped))
//        titleView.addGestureRecognizer(gesture)
        return titleView
    }
    
    private func setupCardFromView() {
        cardFromField.titleLabel.text = "Счет зачисления"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()
        
        cardFromField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
            self.hideView(self.bankListView, needHide: true)
        }
        
    }
    
    private func setupBottomView() {
        view.addSubview(bottomView)
        bottomView.currencySymbol = "₽"
        bottomView.anchor(left: view.leftAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor)
        
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        
    }
    
    private func setupActions() {
        
        bankListView.didBankTapped = { (bank) in
            self.selectedBank = bank
//            self.openOrHideView(self.bankListView)
            self.hideView(self.bankListView, needHide: true)
            self.hideView(self.cardListView, needHide: true)
        }
        
        bankField.didChooseButtonTapped = { () in
            print("bankField didChooseButtonTapped")
            self.openOrHideView(self.bankListView)
            self.bankListView.collectionView.reloadData()
            self.hideView(self.cardListView, needHide: true)
        }
        
        cardListView.didCardTapped = { card in
            self.cardFromField.cardModel = card
            self.selectedCardNumber = card.number ?? ""
            
            self.hideView(self.cardListView, needHide: true)
            self.hideView(self.bankListView, needHide: true)
            
        }
        
        suggestBank("") { model, error in
            if error != nil {
                self.showAlert(with: "Ошибка", and: error ?? "")
            } else {
                guard let bankList = model else { return }
                self.banks = bankList
            }
        }
    }
    
    private func setupBankField(bank: BankFullInfoList) {
        self.bankField.text = bank.name ?? "" //"АйДиБанк"
        
        if let imageString = bank.svgImage {
            self.bankField.imageView.image =  imageString.convertSVGStringToImage()
        } else {
            self.bankField.imageView.image = UIImage(named: "BankIcon")!
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
                    guard let cardNumber  = filterProduct.first?.number else { return }
                    self?.selectedCardNumber = cardNumber
//                    self?.cardIsSelect = true
                    completion(nil)
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
    
    func hideView(_ view: UIView, needHide: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                view.isHidden = needHide
                view.alpha = needHide ? 0 : 1
                self.stackView.layoutIfNeeded()
            }
        }
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
    func suggestBank(_ bic: String, completion: @escaping (_ bankList: [BankFullInfoList]?, _ error: String?) -> Void ) {
        showActivity()
        
        let body = [ "bic": bic,
                     "serviceType" : "5",
                     "type": "20"
        ]
        
        NetworkManager<GetFullBankInfoListDecodableModel>.addRequest(.getFullBankInfoList , body, [:]) { [weak self] model, error in
            self?.dismissActivity()
            if error != nil {
                guard let error = error else { return }
                print("DEBUG: Error: ", error)
                completion(nil, error)
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
            if model.statusCode == 0 {
                guard let data  = model.data else { return }
                completion(data.bankFullInfoList ?? [], nil)
            } else {
                guard let error = model.errorMessage else { return }
                print("DEBUG: Error: ", error)
                completion(nil, error)
            }
        }
    }
    
}
