/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation

struct DatedTransactionsStatement {
    var changeOfBalanse: Double
//    let currency: String?
    let date: Date
    var transactions: [TransactionStatement]
    
    static func sortByDays(transactions: [TransactionStatement]?) -> [DatedTransactionsStatement]? {
        if let transactions = transactions,
            transactions.count > 0 {
            guard let dateForBlock = transactions[0].operationDate else {
                print("first transaction in array without date! \(transactions[0])")
                return nil
            }
            var datedTransactions = [DatedTransactionsStatement]()
            
            var block = DatedTransactionsStatement(changeOfBalanse: 0, date: dateForBlock, transactions: [TransactionStatement]())
            for t in transactions {
//                print(t.operationDate as Any)
                guard let operationDate = t.operationDate else {
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
                    if let operationDate = t.operationDate {
                        let bal = (t.operationType?.compare("DEBIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame) ? -(t.amount ?? 0) : (t.amount ?? 0)
                        block = DatedTransactionsStatement(changeOfBalanse: bal, date: operationDate, transactions: [t])
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

struct TransactionStatement: Decodable {
    var operationDate: Date?
    var operationType: String?
    var accountID: String?
    var accountNumber: String?
    var amount: Double?
    var auditDate: String?
    var comment: String?
    var documentID: String?
    var clientCurrencyCode: String?
    enum CodingKeys: String, CodingKey {
        case operationDate
        case operationType
        case accountID
        case accountNumber
        case amount
        case comment
        case documentID
        case auditDate
        case clientCurrencyCode
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.operationDate = try container.decodeIfPresent(Date.self, forKey: .operationDate)
        self.auditDate = decodeToString(fromContainer: container, key: .auditDate)
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
        self.clientCurrencyCode =  decodeToString(fromContainer: container, key: .clientCurrencyCode)
//        self.auditDate = try container.decodeIfPresent(Date.self, forKey: .auditDate)
//        self.auditDate = auditDate
    }
}
struct AuditDateClass: Decodable {
    let day, eon, eonAndYear, fractionalSecond: Int?
    let hour, millisecond, minute, month: Int?
    let second, timezone: Int?
    let valid: Bool?
    let xmlschemaType: XmlschemaType?
    let year: Int?

    init(day: Int?, eon: Int?, eonAndYear: Int?, fractionalSecond: Int?, hour: Int?, millisecond: Int?, minute: Int?, month: Int?, second: Int?, timezone: Int?, valid: Bool?, xmlschemaType: XmlschemaType?, year: Int?) {
        self.day = day
        self.eon = eon
        self.eonAndYear = eonAndYear
        self.fractionalSecond = fractionalSecond
        self.hour = hour
        self.millisecond = millisecond
        self.minute = minute
        self.month = month
        self.second = second
        self.timezone = timezone
        self.valid = valid
        self.xmlschemaType = xmlschemaType
        self.year = year
    }
}

// XmlschemaType.swift

import Foundation

// MARK: - XmlschemaType
class XmlschemaType: Decodable{
    let localPart, namespaceURI, xmlschemaTypePrefix: String?

    init(localPart: String?, namespaceURI: String?, xmlschemaTypePrefix: String?) {
        self.localPart = localPart
        self.namespaceURI = namespaceURI
        self.xmlschemaTypePrefix = xmlschemaTypePrefix
    }
}
