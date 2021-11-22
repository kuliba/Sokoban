//
//  AccountStatementController.swift
//  ForaBank
//
//  Created by Mikhail on 10.11.2021.
//

import UIKit
import RealmSwift

class AccountStatementController: UIViewController {
    var startProduct: GetProductListDatum?
    lazy var realm = try? Realm()
    
    var toolBar: UIToolbar?
    var datePicker: UIDatePicker?
    let titleButton = UIBarButtonItem(title: "Начало периода", style: .plain, target: nil, action: nil)
    
    var selectDate: Date?
    var enterDate = false
    
    var startDate: Date?
    var endDate: Date?
    
    var dateField = ForaInput(
        viewModel: ForaInputModel(
            title: "Выберите период",
            image: #imageLiteral(resourceName: "date"),
            isEditable: false,
            showChooseButton: true))
    
    var cardFromField: CardChooseView = {
        let cardView =  CardChooseView()
        
        cardView.titleLabel.text = "Банковский продукт"
        cardView.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardView.imageView.isHidden = false
        cardView.leftTitleAncor.constant = 64
        cardView.layoutIfNeeded()
        return cardView
    }()
    
    var cardListView = CardsScrollView(onlyMy: false)
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    var dateView = DateChooseView()
    
    lazy var generateButton: UIButton = {
        let button = UIButton(title: "Сформировать выписку")
        button.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Выписка по счету"
        view.backgroundColor = .white
        addCloseButton()
        setupUI()
        setupActions()
        
        setButtonEnabled(button: generateButton, isEnabled: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardFromField.balanceLabel.isHidden = true
    }
    
    private func setButtonEnabled(button: UIButton, isEnabled: Bool) {
        button.isEnabled = isEnabled
        button.backgroundColor = !isEnabled
        ? UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        : UIColor(red: 1, green: 0.212, blue: 0.212, alpha: 1)
        
        button.setTitleColor(!isEnabled
                             ? UIColor(red: 0.827, green: 0.827, blue: 0.827, alpha: 1)
                             : UIColor.white, for: .normal)
    }
    
    private func setupUI() {
        
        let topLabel = UILabel(text: "Отражает подтвержденные оперции по счету за выбранный период.", font: .systemFont(ofSize: 12))
        topLabel.numberOfLines = 0
        
        
        stackView = UIStackView(arrangedSubviews: [cardFromField, cardListView, dateField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        
        view.addSubview(topLabel)
        topLabel.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 40,
            paddingLeft: 20,
            paddingRight: 20,
            height: 32)
        
        view.addSubview(stackView)
        stackView.anchor(
            top: topLabel.bottomAnchor,
            left: view.leftAnchor, right: view.rightAnchor,
            paddingTop: 20)
        
        view.addSubview(dateView)
        dateView.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        
        view.addSubview(generateButton)
        generateButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20, paddingBottom: 20,
            paddingRight: 20, height: 48)
        
    }
    
    
    private func readAndSetupCard() {
        DispatchQueue.main.async {
            let cards = ReturnAllCardList.cards()
            self.cardListView.cardList = cards
            if cards.count > 0 {
                cards.forEach { card in
                    if card.id == self.startProduct?.id {
                        self.cardFromField.model = card
                    }
                }
            }
        }
    }
    
    private func setupActions() {
        readAndSetupCard()
        
        cardFromField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
        }
        
        dateField.didChooseButtonTapped = { () in
            self.openOrHideView(self.dateView)
            if self.cardListView.isHidden == false {
                self.hideView(self.cardListView, needHide: true)
            }
        }
        
        dateView.buttonIsTapped = { button in
            switch button.tag {
            case 0:
                let now = Date()
                self.startDate = now
                self.endDate = now
                
            case 1:
                let now = Date()
                self.endDate = now
                guard let date = Date.date(now, addDays: -7) else { return }
                self.startDate = date
                
            case 2:
                let now = Date()
                self.endDate = now
                guard let date = Date.date(now, addMonths: -1) else { return }
                self.startDate = date
                
            case 3:
                let now = Date()
                self.endDate = now
                guard let date = Date.date(now, addMonths: -3) else { return }
                self.startDate = date
                
            case 4:
                let now = Date()
                self.endDate = now
                guard let date = Date.date(now, addMonths: -6) else { return }
                self.startDate = date
                
            case 5:
                let now = Date()
                self.endDate = now
                guard let date = Date.date(now, addYears: -1) else { return }
                self.startDate = date
                
            case 6:
//                break
                self.showDatePicker()
            default:
                break
            }
            self.setDate()
        }
        
        cardListView.didCardTapped = { cardId in
            DispatchQueue.main.async {
                let cardList = self.realm?.objects(UserAllCardsModel.self).compactMap {$0} ?? []
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
    
    func showDatePicker() {
        if datePicker == nil {
            generateButton.isHidden = true
            datePicker = UIDatePicker.init()
            datePicker!.backgroundColor = .white
//            datePicker!.backgroundColor = UIColor.blueColor()
            datePicker!.setValue(UIColor.black, forKeyPath: "textColor")
            datePicker!.setValue(0.8, forKeyPath: "alpha")
            datePicker!.autoresizingMask = .flexibleWidth
            datePicker!.datePickerMode = .date
            if #available(iOS 13.4, *) {
                datePicker!.preferredDatePickerStyle = UIDatePickerStyle.wheels
            }
            datePicker!.maximumDate = Date()
            datePicker!.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
            
//            datePicker!.frame = CGRect(x: 0, y: 0, width: 0, height: 300)
            self.view.addSubview(datePicker!)
            datePicker!.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 300)
            
            toolBar = UIToolbar()
            toolBar!.barStyle = .default
            toolBar!.tintColor = .black
            let left = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(self.onCancelButtonClick))
            let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            titleButton.isEnabled = false
            titleButton.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .disabled)
            
            let right = UIBarButtonItem(title: "Далее", style: .done, target: self, action: #selector(self.onDoneButtonClick))
            toolBar!.items = [left, flexible, titleButton, flexible, right]
            toolBar!.sizeToFit()
            self.view.addSubview(toolBar!)
            toolBar!.anchor(left: view.leftAnchor, bottom: datePicker!.topAnchor, right: view.rightAnchor, height: 50)
        }
    }

    @objc func dateChanged(_ sender: UIDatePicker?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
            
        if let date = sender?.date {
            selectDate = date
            print("Picked the date \(dateFormatter.string(from: date))")
        }
    }

    @objc func onCancelButtonClick() {
        endDate = selectDate
        toolBar?.removeFromSuperview()
        datePicker?.removeFromSuperview()
        toolBar = nil
        datePicker = nil
        
        enterDate = false
        startDate = nil
        endDate = nil
        generateButton.isHidden = false
        self.setButtonEnabled(button: self.generateButton, isEnabled: false)
    }
    
    @objc func onDoneButtonClick() {
        if enterDate {
            endDate = selectDate
            toolBar?.removeFromSuperview()
            datePicker?.removeFromSuperview()
            toolBar = nil
            datePicker = nil
            enterDate = false
            generateButton.isHidden = false
            setDate()
            
        } else {
            startDate = selectDate
            enterDate = true
            titleButton.title = "Конец периода"
            
        }
        
    }
    
    private func setDate() {
        guard let startDate = self.startDate else { return }
        guard let endDate = self.endDate else { return }
        
        let formatter = Date.dateFormatterSimpleDateConvenient()
        
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        self.dateField.text = "\(start) - \(end)"
        
        self.setButtonEnabled(button: self.generateButton, isEnabled: true)
        
        if self.cardListView.isHidden == false {
            self.hideView(self.cardListView, needHide: true)
        }
        if self.dateView.isHidden == false {
            self.hideView(self.dateView, needHide: true)
        }
    }
    
    @objc private func generateButtonTapped() {
        print(#function)
        guard let card = cardFromField.model else { return }
        
        guard let model = ResultAccountStatementModel(product: card, statTime: self.startDate ?? Date(), endTime: self.endDate ?? Date()) else { return }
        guard let vc = AccountStatementPDFController(model: model) else { return }
        self.navigationController?.pushViewController(vc, animated: true)
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
