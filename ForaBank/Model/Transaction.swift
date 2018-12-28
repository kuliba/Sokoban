//
//  Transaction.swift
//  ForaBank
//
//  Created by Sergey on 26/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import Foundation

struct DatedTransactions {
    let changeOfBalanse: Double?
    let currency: String?
    let dateFrom: Date?
    let dateTo: Date?
    let transactions: [Transaction]
}

struct Transaction {
    let date: Date?
    let amount: Double?
    let currency: String?
    let counterpartName: String?
    let counterpartImageURL: String?
    let details: String?
    let bonuses: Int?
}
