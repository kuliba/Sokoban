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
    let Amount: Int?
    let accountID: String?
    let availableBalance: Double?
    let loanID: Int!
    let currencyCode: String?
    let branch: String?
    init(Amount: Int? = nil, currencyCode: String? = nil, principalDebt: Double? = nil, userAnnual: Double? = nil, branchBrief: String? = nil, ownerAgentBrief: String? = nil, accountNumber: String? = nil, accountID: String? = nil, customName: String? = nil, accountList: String? = nil, number: String? = nil, blocked: Bool? = nil, DateValue: String? = nil, expirationDate: Date? = nil, availableBalance: Double? = nil, blockedMoney: Double? = nil, updatingDate: Date? = nil, tariff: String? = nil, loanID: Int! = nil, branch: String? = nil, maskedNumber: String? = nil) {
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

    }

    func getProductAbout() -> Array<AboutItem> {
        guard let dateV = dateValue, let userAnn = userAnnual, let num = number, let principalD = principalDebt else {
            return []
        }
        return [AboutItem(title: "Дата взятия кредита", value: dateV),
                AboutItem(title: "Ежемесячный платёж", value: String(userAnn)),
                AboutItem(title: "Номер", value: num),
                AboutItem(title: "Основной долг", value: String(principalD))]
    }
    func getLoansSchedule() -> Array<LaonSchedules> {
        return [LaonSchedules()]
         }

}

