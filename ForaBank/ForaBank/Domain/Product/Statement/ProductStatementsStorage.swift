//
//  ProductStatementsStorage.swift
//  ForaBank
//
//  Created by Max Gribov on 08.06.2022.
//

import Foundation

struct ProductStatementsStorage: Codable {

    let period: Period
    let statements: [ProductStatementData]
    let historyLimitDate: Date?
    var isHistoryComplete: Bool {
        
        guard let historyLimitDate = historyLimitDate else {
            return false
        }

        return historyLimitDate >= period.start
    }
    
    init(period: Period, statements: [ProductStatementData], historyLimitDate: Date? = nil) {
        
        self.period = period
        self.statements = statements
        self.historyLimitDate = historyLimitDate
    }
    
    init(with update: Update, historyLimitDate: Date?) {
        
        self.period = update.period
        let updateStatementsUnique = Set(update.statements)
        self.statements = updateStatementsUnique.sorted(by: { $0.date < $1.date })
        self.historyLimitDate = historyLimitDate
    }
}

//MARK: - Helpers

extension ProductStatementsStorage {
    
    func updated(with update: Update, historyLimitDate: Date?) -> ProductStatementsStorage {
        
        // period
        let updatedPeriod = period.including(update.period)
            
        // statements
        let updateStatementsIds = update.statements.map({ $0.id })
        var statementsUpdated = statements.filter({ updateStatementsIds.contains($0.id) == false })
        statementsUpdated.append(contentsOf: update.statements)
        let statementsSorted = statementsUpdated.sorted(by: { $0.dateValue < $1.dateValue })

        return ProductStatementsStorage(period: updatedPeriod, statements: statementsSorted, historyLimitDate: historyLimitDate)
    }
    
    func latestPeriod(days: Int, limitDate: Date) -> Period? {
        
        guard period.end < limitDate else {
            return nil
        }
        
        let startDate = period.end
        let endDate = min(period.end.advanced(by: TimeInterval.value(days: days)), limitDate)
        
        return Period(start: startDate, end: endDate)
    }
    
    func eldestPeriod(days: Int, limitDate: Date) -> Period? {
        
        guard period.start > limitDate else {
            return nil
        }
        
        let startDate = max(period.start.advanced(by: -TimeInterval.value(days: days)), limitDate)
        let endDate = period.start
        
        return Period(start: startDate, end: endDate)
    }
    
    static func historyLimitDate(for product: ProductData) -> Date? {
        
        product.openDate ?? Self.bankOpenDate
    }
    
    static let bankOpenDate: Date? = {
        
        let components = DateComponents(year: 1992, month: 5, day: 27)
        return Calendar.current.date(from: components)
        
    }()
}

//MARK: - Types

extension ProductStatementsStorage {
    
    struct Request: CustomDebugStringConvertible {

        let period: Period
        let direction: Period.Direction
        let limitDate: Date
        let operationType: [OperationType]?
        let operationGroup: [ProductStatementMerchantGroup]?
        
        var debugDescription: String {
            
            "request: \(period), \(direction), limitDate: \(limitDate)"
        }
    }
    
    struct Update {
        
        let period: Period
        let statements: [ProductStatementData]
        let direction: Period.Direction
        let limitDate: Date
    }
}
