/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

class Deposit {

    let depositProductName: String?
    let ownerAgentBrief: String?
    let accountNumber: String?
    let customName: String?
    let number: String?
    var blocked: Bool?
    let depositorBrief: String?
    let balanceCUR: Double?
    let accountID: String?
    let availableBalance: Double?
    let id: Int?
    let currencyCode: String?
    let balance: Double?
    let branch: String?
    var minimumBalance: Double?
    var isCreditOperationsAvailable: Bool?
    var interestRate: Double?
    var isDebitOperationsAvailable: Bool?
    var creditMinimumAmount: Double?
    var initialAmount: Double?
    var dateEnd: String?
    var dateStart: String?
    
    
    
    init(depositProductName: String?, isCreditOperationsAvailable: Bool?, balanceCUR: Double? = nil, depositorBrief: String? = nil, currencyCode: String? = nil, ownerAgentBrief: String? = nil, balance: Double? = nil, accountNumber: String? = nil, accountID: String? = nil, customName: String? = nil, accountList: String? = nil, number: String? = nil, blocked: Bool? = nil, expirationDate: Date? = nil, availableBalance: Double? = nil, blockedMoney: Double? = nil, updatingDate: Date? = nil, tariff: String? = nil, id: Int? = nil, branch: String? = nil, maskedNumber: String? = nil, minimumBalance: Double? = nil, interestRate: Double? = nil, isDebitOperationsAvailable: Bool? = nil,creditMinimumAmount: Double? = nil, initialAmount: Double? = nil, dateEnd: String? = nil, dateStart: String? = nil) {
        self.depositProductName = depositProductName
        self.balance = balance
        self.currencyCode = currencyCode
        self.depositorBrief = depositorBrief
        self.ownerAgentBrief = ownerAgentBrief
        self.balanceCUR = balanceCUR
        self.accountNumber = accountNumber
        self.accountID = accountID
        self.customName = customName
        self.number = number
        self.blocked = blocked
        self.availableBalance = availableBalance
        self.id = id
        self.branch = branch
        self.minimumBalance = minimumBalance
        self.isCreditOperationsAvailable  = isCreditOperationsAvailable
        self.interestRate = interestRate
        self.isDebitOperationsAvailable = isDebitOperationsAvailable
        self.creditMinimumAmount = creditMinimumAmount
        self.initialAmount = initialAmount
        self.dateEnd = dateEnd
        self.dateStart = dateStart
    }

    func getProductAbout() -> Array<AboutItem> {
        if minimumBalance == nil{
            minimumBalance = 0.00
        }
        
//        if isCreditOperationsAvailable ==  nil{
//            isCreditOperationsAvailable!.description
//        } else {
//            isCreditOperationsAvailable!.description = "Да"
//
//        }
//        if isDebitOperationsAvailable ==  nil{
//            isDebitOperationsAvailable.description = "Нет"
//        } else{
//            isDebitOperationsAvailable.description = "Да"
//        }
        
        
        
        return [
        AboutItem(title: "Дата открытия", value: "\(String(describing: dateStart ?? "00"))"),
        AboutItem(title: "Дата окончания", value: "\(String(describing: dateEnd ?? "00"))"),
        AboutItem(title: "Доступно для снятия", value: "\(String(describing: balance!)) \(String(describing: currencyCode!))"),
        AboutItem(title: "Сумма неснижаемого остатка ", value: "\(String(minimumBalance!))  \(String(describing: currencyCode!))"),
        AboutItem(title: "Пополнение/Снятие  ", value: "\(String(isCreditOperationsAvailable?.description ?? "Да"))/\(String(isDebitOperationsAvailable?.description ?? "Да"))"),
        AboutItem(title: "Процентная ставка", value: "\(String(interestRate ?? 0.01))%"),
        AboutItem(title: "Сумма минимального пополнения ", value: "\(String(creditMinimumAmount ?? 0.00)) \(String(describing: currencyCode!))"),
        AboutItem(title: "Первоначальная сумма вклада ", value: "\(String(initialAmount ?? 0.00))\(String(describing: currencyCode!))")]
    }
}

