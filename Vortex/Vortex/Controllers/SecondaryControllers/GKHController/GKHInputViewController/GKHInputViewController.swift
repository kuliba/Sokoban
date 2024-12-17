//
//  GKHDetailViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.08.2021.
//

import UIKit
import RealmSwift

class GKHInputViewController: BottomPopUpViewAdapter {
    
    var bodyValue = [String : String]()
    var bodyArray = [[String : String]]()
    var operatorData: GKHOperatorsModel?
    var valueToPass : String?
    var puref = ""
    var cardNumber = ""
    var cardId = 0
    var personalAccount = ""
    // Шаг при многошаговом операторе
    var fieldid = 0
    // Указывает, является данная итерация запросов последней
    var finalStep = true
    /// Параметр, указывающий на то, то это последний шаг. Используеься для перехода к запросу nextStep
    var endStep = true
    // Параметр, указывающий, надо ли отображать поле суммы
    var needSum = true
    // Массив, в котором копим значения, которые говорят о заполнении ячеек в таблице
    var emptyArray = [Bool]()
    // Скрываем или отображаем кнопку "Продолжить" в зависимости от заполнения полей
    func empty() {
        let dataCount = dataArray.count
        if emptyArray.count == dataCount {
            animationShow(goButton)
        } else {
            animationHidden(goButton)
        }
    }
    var qrData = [String: String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomInputView: BottomInputView!
    @IBOutlet weak var goButton: UIButton!
    
    var nextStepModel: NextStepServiceTransferDecodableModel? = nil
    
    /// MARK - REALM
    lazy var realm = try? Realm()
    var cardList: Results<UserAllCardsModel>? = nil
    
    let footerView = GKHInputFooterView()
    var summ = ""
    var dataArray = [[String: String]]()
    // Тип оператора (одношаговый или многошаговый)
    var operatorType: Bool = true {
        didSet {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardList = realm?.objects(UserAllCardsModel.self)

        if !qrData.isEmpty {
            summ = qrData.filter { $0.key == "Сумма"}.first?.value ?? ""
            bottomInputView.amountTextField.text = summ
            personalAccount = qrData.filter { $0.key == "Лицевой счет"}.first?.value ?? ""
            var d = GKHInputModel(qrData)
            d?.qData().forEach({ value in
                dataArray.append(value)
            })
        } else {
            guard operatorData != nil else { return }
            var d = GKHInputModel(operatorData!)
            d?.data().forEach({ value in
                dataArray.append(value)
            })
        }

        setupNavBar()
        goButton.add_CornerRadius(5)
        puref = operatorData?.puref ?? ""
        tableView.register(UINib(nibName: "GKHInputCell", bundle: nil), forCellReuseIdentifier: GKHInputCell.reuseId)
        
        // Изменения символа валюты
        bottomInputView.currencySymbol = "₽"
        
        // Замыкание которое срабатывает по нажатию на кнопку продолжить
        // amount значение выдает отформатированное значение для передачи в запрос
        bottomInputView.didDoneButtonTapped = { amount in
            self.showActivity()
            
            if self.operatorType == true {
                // Одношаг
                self.paymentGKH(amount: amount) { model, error in
                    self.dismissActivity()
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error!)
                    } else {
                        guard let model = model else { return }
                        // Переход на экран подтверждения
                        self.goToConfurmVC(with: model)
                    }
                    // Функция настройки выбранной карты и список карт
                    self.setupCardList { error in
                        guard let error = error else { return }
                        self.showAlert(with: "Ошибка", and: error)
                    }
                }
            } else {
            
            // Многошаг
            self.operatorNexStep(amount: amount) { model, error in
//                self.dismissActivity()
                // Запрос на платеж в ЖКХ : нужно добавить параметры в рапрос
               self.nextStepModel = model
                let gkhModel = GkhPaymentModel(gkhModel: self.nextStepModel,
                                               bodyArray: self.bodyArray,
                                               gkhPuref: self.puref,
                                               amount: amount)
                guard let model = model else { return }
                // Переход на экран подтверждения
                let m = ConfirmViewControllerModel(type: .gkh, status: .succses)

                let r = Double(model.data?.debitAmount ?? 0)

                m.summTransction = r.currencyFormatter(symbol: "RUB")

                let c = Double(model.data?.fee ?? 0)
                m.taxTransction = c.currencyFormatter(symbol: "RUB")
                m.cardFromRealm = self.footerView.cardFromField.model
                m.cardFrom = self.footerView.cardFromField.cardModel
                m.gkhModel = gkhModel
                self.goToConfurmVC(with: m)
            }
            }
        }
        
        setupCardList { error in
            guard let error = error else { return }
            self.showAlert(with: "Ошибка", and: error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch operatorType {
        case true:
            if qrData.isEmpty == false {
                animationShow (goButton)
                animationHidden(bottomInputView)
            } else {
//                animationHidden (goButton)
//                animationHidden(bottomInputView)
            }
        case false:
            if qrData.isEmpty == false {
                animationShow (goButton)
                animationHidden(bottomInputView)
            } else {
                animationHidden (goButton)
                animationHidden(bottomInputView)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height + 70
//            tableView.tableFooterView = footerView
//            tableView.layoutIfNeeded()
        }
    }
    
    @IBAction func goButton(_ sender: UIButton) {
        switch operatorType {
        case true:
            animationHidden(goButton)
            animationShow(bottomInputView)
        case false:
            if finalStep == false {
                if endStep == true {
                    animationHidden(goButton)
                    animationShow(bottomInputView)
                }
            } else {
                // Запрос по получения полей при многошаговом операторе
                operatorStep()
                animationHidden(goButton)
                animationHidden(bottomInputView)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        qrData.removeAll()
    }
    
    final func animationHidden (_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                view.alpha = 0
            }
            view.isHidden = true
        }
    }
    
    final func animationShow (_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                view.alpha = 1
            }
            view.isHidden = false
        }
    }
    
    final func animateQueue (_ view_1: UIView, _ view_2: UIView) {
        UIView.animateKeyframes(withDuration: 0.3, delay: .zero, options: []) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                view_1.alpha = 1.0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                view_2.alpha = 0.0
            }
        }
    }
    
    
}


struct GkhPaymentModel {
    var gkhModel: NextStepServiceTransferDecodableModel? = nil
    var bodyArray = [[String : String]]()
    var gkhPuref = ""
    var amount = ""
}
