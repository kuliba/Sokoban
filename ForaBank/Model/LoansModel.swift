//
//  Card.swift
//  ForaBank
//
//  Created by Sergey on 16/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

//it's class(not struct) because Card objects pass between controllers with state changes
//specific case: the card is blocked in the DepositsCardsListOnholdBlockViewController and on returning to the previous DepositsCardsListViewController its display should change
class Loan {
    let branchBrief: String?
    let ownerAgentBrief: String?
    let accountNumber: String?
    let customName: String?
    let userAnnual: Double?
    let number: String?
    let DateValue: Date?
    let principalDebt: Double?
    var blocked: Bool?
    let Amount: Int?
    let accountID: String?
    let availableBalance: Double?
    let id: String?
    let currencyCode: String?
    let balance: String?
    let branch: String?
    init( Amount: Int? = nil,  currencyCode: String? = nil, principalDebt: Double? = nil, userAnnual: Double? = nil, branchBrief: String? = nil, ownerAgentBrief: String? = nil, balance: String? = nil, accountNumber: String? = nil, accountID: String? = nil, customName: String? = nil, accountList: String? = nil, number: String? = nil, blocked: Bool? = nil, DateValue: Date? = nil, expirationDate: Date? = nil, availableBalance: Double? = nil, blockedMoney: Double? = nil, updatingDate: Date? = nil, tariff: String? = nil, id: String? = nil, branch: String? = nil, maskedNumber: String? = nil) {
        self.balance = balance
        self.DateValue = DateValue
    
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
        self.id = id
        self.branch = branch
        
        
        
    }
    
    
    
}

