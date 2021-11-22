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
    // Параметр, указывающий, надо ли отображать поле суммы
    var needSum = true
    // Массив, в котором копим значения, которые говорят о заполнении ячеек в таблице
    var emptyArray = [Bool]()
    // Скрываем или отображаем кнопку "Продолжить" в зависимости от заполнения полей
    func empty() {
        let dataCount = dataArray.count
        if emptyArray.count == dataCount {
            self.goButton.isHidden = false
        } else {
            self.goButton.isHidden = true
        }
    }
    var qrData = [String: String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomInputView: BottomInputView!
    @IBOutlet weak var goButton: UIButton!
    
    /// MARK - REALM
    lazy var realm = try? Realm()
    var cardList: Results<UserAllCardsModel>? = nil
    
    let footerView = GKHInputFooterView()
    var summ = ""
    var dataArray = [[String: String]]()
    // Тип оператора (одношаговый или многошаговый)
    var operatorType: Bool = true {
        didSet {
            switch operatorType {
            case true:
                goButton?.isEnabled = true
              //  goButton.backgroundColor = .lightGray
            case false:
                goButton?.isEnabled = false
                goButton?.backgroundColor = .lightGray
            }
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
        
        bottomInputView?.isHidden = true
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
            // Запрос на платеж в ЖКХ : нужно добавить параметры в рапрос
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
        }
        
        setupCardList { error in
            guard let error = error else { return }
            self.showAlert(with: "Ошибка", and: error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.goButton.isHidden = true
//        switch operatorType {
//        case true:
//            goButton.isHidden = false
//            bottomInputView.isHidden = true
//        case false:
//            goButton.isHidden = false
//            bottomInputView.isHidden = true
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height + 70
            tableView.tableFooterView = footerView
            tableView.layoutIfNeeded()
        }
    }
    
    @IBAction func goButton(_ sender: UIButton) {
        operatorStep()
        switch operatorType {
        case true:
            break
        case false:
            operatorStep()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        qrData.removeAll()
    }
    
    
}

