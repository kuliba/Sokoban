//
//  Card.swift
//  ForaBank
//
//  Created by Sergey on 16/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

class Loan {
    let branchBrief: String?
    let ownerAgentBrief: String?
    let accountNumber: String?
    let customName: String?
    let userAnnual: Double?
    let number: String?
    let dateValue: String?
    let principalDebt: Double?
    var blocked: Bool?
    let Amount: Double?
    let accountID: String?
    let availableBalance: Double?
    let loanID: Int!
    var currencyCode: String?
    let branch: String?
    let currentInterestRate: Double?
    let dateEnd: String?
    let isClosed: Bool?
    let loanName: String?
    
    
    
    init(Amount: Double? = nil, currencyCode: String? = nil, principalDebt: Double? = nil, userAnnual: Double? = nil, branchBrief: String? = nil, ownerAgentBrief: String? = nil, accountNumber: String? = nil, accountID: String? = nil, customName: String? = nil, accountList: String? = nil, number: String? = nil, blocked: Bool? = nil, DateValue: String? = nil, expirationDate: Date? = nil, availableBalance: Double? = nil, blockedMoney: Double? = nil, updatingDate: Date? = nil, tariff: String? = nil, loanID: Int! = nil, branch: String? = nil, maskedNumber: String? = nil, currentInterestRate: Double? = nil, dateEnd: String? = nil, isClosed: Bool? = nil, loanName: String? = nil) {
        self.dateValue = DateValue

        self.userAnnual = userAnnual
        self.principalDebt = principalDebt
        self.branchBrief = branchBrief
        self.currencyCode = currencyCode
        self.ownerAgentBrief = ownerAgentBrief
        self.Amount = Amount
        self.accountNumber = accountNumber
        self.accountID = accountID
        self.customName = customName
        self.number = number
        self.blocked = blocked
        self.availableBalance = availableBalance
        self.loanID = loanID
        self.branch = branch
        self.currentInterestRate = currentInterestRate
        self.currencyCode = currencyCode
        self.dateEnd = dateEnd
        self.isClosed = isClosed
        self.loanName = loanName
    }

    func getProductAbout() -> Array<AboutItem> {
        guard let dateV = dateValue, let _ = userAnnual, let num = number, let principalD = principalDebt, let currentInterestRate = currentInterestRate, let dateEnd = dateEnd, let amount = Amount, let isClosed = isClosed else {
            return []
        }
        var status: String
        if isClosed == false {
            status = "Действует"
        } else{
            status = "Закрыт"
        }
        return [
                AboutItem(title: "Номер договора", value: num),
                AboutItem(title: "Договор действует с", value: dateV),
                AboutItem(title: "Договор действует по", value: dateEnd),
                 AboutItem(title: "Процентная ставка", value: "\(currentInterestRate)%"),
                AboutItem(title: "Валюта", value: String(currencyCode!)),
                AboutItem(title: "Сумма остатка", value: String(principalD)),
                AboutItem(title: "Сумма кредита", value: String(amount)),
                AboutItem(title: "Состояние", value: String(status))

                ]
    }
    
    // return [AboutItem(title: "Договор действует с", value: dateV),
    //                AboutItem(title: "Договор действует по", value: String(dateV)),
    //                AboutItem(title: "Номер договора", value: num),
    //                AboutItem(title: "Валюта", value: String(currencyCode)),
    //                AboutItem(title: "Сумма остатка", value: String(principalD)),
    //                AboutItem(title: "Сумма кредита", value: String(amount)),
    //                AboutItem(title: "Процентная ставка", value: String(currentInterestRate)),
    //                AboutItem(title: "Состояние", value: String(principalD))
    //
    //        ]
 

}

