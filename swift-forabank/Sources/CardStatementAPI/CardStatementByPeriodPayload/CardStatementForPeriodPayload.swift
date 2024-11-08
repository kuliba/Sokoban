//
//  CardStatementForPeriodPayload.swift
//  
//
//  Created by Andryusina Nataly on 23.01.2024.
//

import Foundation
import Tagged

public struct CardStatementForPeriodPayload: Equatable {
    
    public let id: ProductID
    public let name: Name?
    public let period: Period
    public let statementFormat: StatementFormat?
    public let cardNumber: CardNumber?
    public let operationType: String?
    public let operationGroup: [String]?
    public let includeAdditionalCards: Bool?
    
    public typealias ProductID = Tagged<_ProductID, Int>
    public enum _ProductID {}
    
    public typealias Name = Tagged<_Name, String>
    public enum _Name {}
    
    public typealias CardNumber = Tagged<_CardNumber, String>
    public enum _CardNumber {}
    
    public init(
        id: ProductID,
        name: Name?,
        period: Period,
        statementFormat: StatementFormat?,
        cardNumber: CardNumber?,
        operationType: String?,
        operationGroup: [String]?,
        includeAdditionalCards: Bool?
    ) {
        self.id = id
        self.name = name
        self.period = period
        self.statementFormat = statementFormat
        self.cardNumber = cardNumber
        self.operationType = operationType
        self.operationGroup = operationGroup
        self.includeAdditionalCards = includeAdditionalCards
    }
}

extension CardStatementForPeriodPayload {

    public enum OperationGroup: String, Identifiable, Equatable {
     
        case internalOperations = "Перевод внутри банка"
        case services = "Услуги"
        case others = "Прочие операции"
        case beauty = "Красота"
        case education = "Образование"
        case hobby = "Хобби и развлечения"
        case stateServices = "Оплата услуг/Налоги и госуслуги"
        case transport = "Транспорт"
        case communicationInternetTV = "Оплата услуг/Связь, интернет, ТВ"
        case aviaTickets = "Авиа билеты"
        case health = "Здоровье"
        case houseRenovation = "Дом, ремонт"
        case variousGoods = "Различные товары"
        case supermarket = "Супермаркет"
        case trainTickets = "Ж/д билеты"
        case restaurantsAndCafes = "Рестораны и кафе"
        case multimedia = "Мультимедиа"
        case restAndTravel = "Отдых и путешествия"
        case clothesAnAccessories = "Одежда и аксессуары"
        
        public var id: String { self.rawValue }
    }
}

extension CardStatementForPeriodPayload {

    public enum OperationType: String, Equatable {
        
        case credit = "CREDIT"
        case creditPlan = "CREDIT_PLAN"
        case creditFict = "CREDIT_FICT"
        
        case debit = "DEBIT"
        case debitPlan = "DEBIT_PLAN"
        case debitFict = "DEBIT_FICT"
        
        public var id: String { self.rawValue }
    }
}

extension CardStatementForPeriodPayload {
    
    public struct Period: Equatable {
        
        public let start: Date
        public let end: Date
        
        public init(start: Date, end: Date) {
            self.start = start
            self.end = end
        }
    }
}

extension CardStatementForPeriodPayload {
    
    public enum StatementFormat: String {
        
        case csv = "CSV"
        case pdf = "PDF"
    }
}

public extension CardStatementForPeriodPayload {
    
    var httpBody: Data {
      
        get throws {
            
            let formatter = DateFormatterISO8601()
            
            let startDateFormattedString = formatter.string(from: period.start)
            let endDateFormattedString = formatter.string(from: period.end)
            
            var parameters: [String: Any] = [
                "id": id.rawValue,
                "startDate": startDateFormattedString,
                "endDate": endDateFormattedString
            ]
            
            let name: [String: String]? = name.map { ["name": $0.rawValue] }
            if let name { parameters = parameters.mergeOnto(target: name) }
            
            let statementFormat: [String: String]? = statementFormat.map { ["statementFormat": $0.rawValue] }
            if let statementFormat { parameters = parameters.mergeOnto(target: statementFormat) }
            
            let cardNumber: [String: String]? = cardNumber.map { ["cardNumber": $0.rawValue] }
            if let cardNumber { parameters = parameters.mergeOnto(target: cardNumber) }
            
            return try JSONSerialization.data(
                withJSONObject: parameters as [String: Any]
            )
        }
    }
}

private extension Dictionary where Value: Any {
    func mergeOnto(target: [Key: Value]?) -> [Key: Value] {
        guard let target = target else { return self }
        return self.merging(target) { current, _ in current }
    }
}
