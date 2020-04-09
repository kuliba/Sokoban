/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation

struct DatedCardTransactionsStatement {
    var changeOfBalanse: Double
//    let currency: String?
    let date: Date
    var transactions: [TransactionCardStatement]
    
    static func sortByDays(transactions: [TransactionCardStatement]?) -> [DatedCardTransactionsStatement]? {
        if let transactions = transactions,
            transactions.count > 0 {
            guard let dateForBlock = transactions[0].date else {
                print("first transaction in array without date! \(transactions[0])")
                return nil
            }
            var datedTransactions = [DatedCardTransactionsStatement]()
            
            var block = DatedCardTransactionsStatement(changeOfBalanse: 0, date: dateForBlock, transactions: [TransactionCardStatement]())
            for t in transactions {
//                print(t.operationDate as Any)
                guard let operationDate = t.date else {
                    print("transaction without date! \(t)")
                    continue
                }
                if Calendar.current.compare(block.date, to: operationDate, toGranularity: Calendar.Component.day) == .orderedSame {
//                    print("same")
                    if t.operationType?.compare("DEBIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame {
                        block.changeOfBalanse -= t.amount ?? 0
                    } else if t.operationType?.compare("CREDIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame {
                        block.changeOfBalanse += t.amount ?? 0
                    }
                    block.transactions.append(t)
                } else {
//                    print("other")
                    datedTransactions.append(block)
                    if let operationDate = t.date {
                        let bal = (t.operationType?.compare("DEBIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame) ? -(t.amount ?? 0) : (t.amount ?? 0)
                        block = DatedCardTransactionsStatement(changeOfBalanse: bal, date: operationDate, transactions: [t])
                    } else {
                        continue
                    }
                }
            }
            datedTransactions.append(block)
//            for d in datedTransactions {
//                print(d.date)
//                print(d.changeOfBalanse)
//                for t in d.transactions {
//                    print(t.operationDate as Any)
//                }
//            }
                return datedTransactions
        } else {
            return nil
        }
    }
}

struct TransactionCardStatement: Decodable {
    let date: Date?
    let operationType: String?
    let accountID: String?
    let accountNumber: String?
    let amount: Double?
    let comment: String?
    let documentID: String?
    
    enum CodingKeys: String, CodingKey {
        case date
        case operationType
        case accountID
        case accountNumber
        case amount
        case comment
        case documentID
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
//        if let time = (try? container.decodeIfPresent(TimeInterval.self, forKey: .operationDate)) as? Double {
//            self.operationDate = Date(timeIntervalSince1970: time/1000)
//        } else {
//            self.operationDate = nil
//        }
        self.operationType = decodeToString(fromContainer: container, key: .operationType)
        self.accountID = decodeToString(fromContainer: container, key: .accountID)
        self.accountNumber = decodeToString(fromContainer: container, key: .accountNumber)
        self.amount = decodeToDouble(fromContainer: container, key: .amount)
        self.comment = decodeToString(fromContainer: container, key: .comment)
        self.documentID = decodeToString(fromContainer: container, key: .documentID)
    }
}

//struct LoanPaymentSchedule: Decodable {
////    "actionType": "string",
////    "actionTypeBrief": "string",
////    "actionTypeCode": 0,
////    "paymentAmount": 0,
////    "totalAmount": 0
//    let actionType: String?
//    let actionTypeBrief: String?
//    let actionTypeCode: Int?
//    let paymentAmount: Int?
//    let totalAmount: Int?
//    
//    enum CodingKeys: String, CodingKey {
//        case actionType
//        case actionTypeBrief
//        case actionTypeCode
//        case paymentAmount
//        case totalAmount
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//    }
//}
