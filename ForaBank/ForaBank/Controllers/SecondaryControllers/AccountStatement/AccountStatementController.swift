//
//  AccountStatementController.swift
//  ForaBank
//
//  Created by Mikhail on 10.11.2021.
//

import UIKit
import RealmSwift
import SwiftUI

class AccountStatementController: UIViewController {
    
    var viewModel: ProductStatementViewModel?
    
    var startProduct: UserAllCardsModel?
    
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
    
    var cardListView = CardsScrollView(onlyMy: false, loans: true)
    
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
        cardFromField.getUImage = viewModel?.getUImage
        cardFromField.model = startProduct
//        setupCloseButton()
        setupUI()
        setupActions()
        
        setButtonEnabled(button: generateButton, isEnabled: false)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardFromField.balanceLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewDidAppear(animated)
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
    
    func setupCloseButton() {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(onCloseButtonAction))
        button.tintColor = .black
        navigationItem.leftBarButtonItem = button
    }
    
    @objc func onCloseButtonAction() {
        
        viewModel?.closeAction()
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        
        let topLabel = UILabel(text: "Отражает подтвержденные операции по счету за выбранный период.", font: .systemFont(ofSize: 12))
        topLabel.numberOfLines = 0
        
        
        stackView = UIStackView(arrangedSubviews: [cardFromField, cardListView, dateField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        
        view.addSubview(topLabel)
        topLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20,
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
    
    private func setupActions() {
        
        cardFromField.didChooseButtonTapped = { () in
            self.openOrHideView(self.cardListView)
            if self.dateView.isHidden == false {
                self.hideView(self.dateView, needHide: true)
            }
        }
        
        dateField.didChooseButtonTapped = { () in
            self.openOrHideView(self.dateView)
            if self.cardListView.isHidden == false {
                self.hideView(self.cardListView, needHide: true)
            }
            self.hideDatePicker()
            
        }
        
        dateView.buttonIsTapped = { button in
            if self.cardListView.isHidden == false {
                self.hideView(self.cardListView, needHide: true)
            }
            if self.dateView.isHidden == false {
                self.hideView(self.dateView, needHide: true)
            }
            
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
                let cardList = ReturnAllCardList.cards()
                cardList.forEach({ card in
                        if card.id == cardId {
                            self.cardFromField.getUImage = self.viewModel?.getUImage
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
            datePicker!.setValue(UIColor.black, forKeyPath: "textColor")
            datePicker!.setValue(1, forKeyPath: "alpha")
            datePicker!.autoresizingMask = .flexibleWidth
            datePicker!.datePickerMode = .date
            if #available(iOS 13.4, *) {
                datePicker!.preferredDatePickerStyle = UIDatePickerStyle.wheels
            }
            datePicker!.maximumDate = Date()
            datePicker!.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
            
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
        }
    }

    @objc func onCancelButtonClick() {
        endDate = selectDate
        hideDatePicker()
        startDate = nil
        endDate = nil
        self.setButtonEnabled(button: self.generateButton, isEnabled: false)
    }
    
    
    @objc func onDoneButtonClick() {
        if enterDate {
            endDate = selectDate
            hideDatePicker()
            setDate()
            
        } else {
            startDate = selectDate
            enterDate = true
            titleButton.title = "Конец периода"
            
        }
    }
    
    func hideDatePicker() {
        toolBar?.removeFromSuperview()
        datePicker?.removeFromSuperview()
        toolBar = nil
        datePicker = nil
        enterDate = false
        generateButton.isHidden = false
    }
    
    private func setDate() {
        guard let startDate = self.startDate else { return }
        guard let endDate = self.endDate else { return }
        
        let formatter = Date.dateFormatterSimpleDateConvenient()
        
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        self.dateField.text = "\(start) - \(end)"
        
        self.setButtonEnabled(button: self.generateButton, isEnabled: true)
    }
    
    @objc private func generateButtonTapped() {
        
        guard let card = cardFromField.model else { return }
        
        let startDate = self.startDate ?? Date()
        let endDate = self.endDate ?? Date()
        let printFormViewModel = PrintFormView.ViewModel(type: .product(productId: card.id, startDate: startDate, endDate: endDate), model: Model.shared)
        let printFormView = PrintFormView(viewModel: printFormViewModel)
        let printFormviewController = UIHostingController(rootView: printFormView)
        
        present(printFormviewController, animated: true)
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
