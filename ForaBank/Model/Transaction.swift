/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

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
