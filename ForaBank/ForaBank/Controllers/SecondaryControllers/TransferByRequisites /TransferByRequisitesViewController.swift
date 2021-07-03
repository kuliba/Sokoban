//
//  TransferByRequisitesViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 30.06.2021.
//

import UIKit

class TransferByRequisitesViewController: UIViewController, UITextFieldDelegate {

    
    var bottomView = BottomInputView()
    
    var bikBankField = ForaInput(
        viewModel: ForaInputModel(
            title: "Бик банка получателя",
            image: #imageLiteral(resourceName: "bikbank"),
            showChooseButton: true))
    
    var accountNumber = ForaInput(
        viewModel: ForaInputModel(
            title: "Номер счета получателя",
            image: #imageLiteral(resourceName: "accountIcon")))
    
    var fioField = ForaInput(
        viewModel: ForaInputModel(
            title: "ФИО получателя",
            image: #imageLiteral(resourceName: "Phone")))
    
    var nameField = ForaInput(
        viewModel: ForaInputModel(
            title: "Имя"))
    
    var surField = ForaInput(
        viewModel: ForaInputModel(
            title: "Отчество"))
    
    var cardListView = CardListView()
    
    
    var stackView = UIStackView(arrangedSubviews: [])

    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Продолжить")
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bikBankField.textField.delegate = self
        bikBankField.didChangeValueField = {(field) in
            print(field.text)
        }
        accountNumber.didChangeValueField = {(field) in
            print(field.text)
        }
        setupUI()
        setupActions()
        
        // Do any additional setup after loading the view.
    }
    func setupActions() {
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async {
                if error != nil {
                    print("Ошибка", error!)
                }
                guard let data = data else { return }
                self?.cardListView.cardList = data
            }
        }
    }
    
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
    
    func setupUI() {
        
        addCloseButton()
        view.backgroundColor = .white
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        view.addSubview(bottomView)
        
        self.navigationItem.titleView = setTitle(title: "Перевести", subtitle: "Человеку или организации")
        cardListView.didCardTapped = {[weak self] (card) in
            print(card)
        }
        
        
        stackView = UIStackView(arrangedSubviews: [bikBankField,accountNumber, cardListView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        
        setupConstraint()
    }
    
    func updateUI(){
        stackView = UIStackView(arrangedSubviews: [bikBankField,accountNumber, cardListView, fioField])
    }
    
    func setupConstraint() {
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 20)
        
    }
    
    @objc func doneButtonTapped() {
//        prepareCard2Phone()
    }
    
  
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        
        let completeText = NSMutableAttributedString(string: "")
        let text = NSAttributedString(string: title + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)])
        completeText.append(text)
        
        titleLabel.attributedText = completeText
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .gray
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width

        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        return titleView
    }

}
