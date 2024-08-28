//
//  CardStatementFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation
import CardStatementAPI
import Tagged

extension Services {
    
    typealias CardStatementForPeriodPayload = CardStatementAPI.CardStatementForPeriodPayload
    
    static func makeCardStatementForPeriod(
        httpClient: HTTPClient,
        productId: ProductData.ID,
        period: Period,
        name: CardStatementForPeriodPayload.Name? = nil,
        statementFormat: CardStatementForPeriodPayload.StatementFormat? = nil,
        cardNumber: CardStatementForPeriodPayload.CardNumber? = nil
    ) async throws-> [ProductStatementData] {
        
        let payload = CardStatementForPeriodPayload.init(
            id: .init(productId),
            name: name,
            period: .init(start: period.start, end: period.end),
            statementFormat: statementFormat,
            cardNumber: cardNumber)
        let data = try await getCardStatementForPeriod(httpClient: httpClient).process(payload).get()
        
        return data.operationList.map({ .init(data: $0) })
    }
    
    private func getCardStatementForPeriod(
        httpClient: HTTPClient
    ) -> Services.GetCardStatementService {
        
        Services.getCardStatementForPeriod(
            httpClient: httpClient
        )
    }
}

extension CardStatementAPI.ProductStatementData.OperationType {
    
    var value: OperationType {
        
        switch self {
            
        case .credit:
            return .credit
        case .creditPlan:
            return .creditPlan
        case .creditFict:
            return .creditFict
        case .debit:
            return .debit
        case .debitPlan:
            return .debitPlan
        case .debitFict:
            return .debitFict
        case .open:
            return .open
        case .demandDepositFromAccount:
            return .demandDepositFromAccount
        }
    }
}

extension CardStatementAPI.ProductStatementData.Kind {
    
    var value: ProductStatementData.Kind {

        switch self {
        case .betweenTheir:
            return .betweenTheir
        case .contactAddressless:
            return .contactAddressless
        case .direct:
            return .direct
        case .externalEntity:
            return .externalEntity
        case .externalIndivudual:
            return .externalIndivudual
        case .housingAndCommunalService:
            return .housingAndCommunalService
        case .insideBank:
            return .insideBank
        case .insideOther:
            return .insideOther
        case .internet:
            return .internet
        case .mobile:
            return .mobile
        case .notFinance:
            return .notFinance
        case .otherBank:
            return .otherBank
        case .outsideCash:
            return .outsideCash
        case .outsideOther:
            return .outsideOther
        case .sfp:
            return .sfp
        case .transport:
            return .transport
        case .taxes:
            return .taxes
        case .c2b:
            return .c2b
        case .insideDeposit:
            return .insideDeposit
        case .sberQRPayment:
            return .sberQRPayment
        case .networkMarketing:
            return .networkMarketing
        case .digitalWallet:
            return .digitalWallet
        case .charity:
            return .charity
        case .socialAndGame:
            return .socialAndGame
        }
    }
}

extension CardStatementAPI.ProductStatementData.OperationEnvironment {
    
    var value: OperationEnvironment {
        
        switch self {
        case .inside:
            return .inside
        case .outside:
            return .outside
        }
    }
}


extension ProductStatementData {
    
    init(
        data: CardStatementAPI.ProductStatementData
    ) {
        let fastPayment: ProductStatementData.FastPayment? = data.fastPayment.map { .init(data: $0) }
        let svgImage: SVGImageData? = data.svgImage.map { .init(description: $0) }
        self = .init(mcc: data.MCC, accountId: data.accountID, accountNumber: data.accountNumber, amount: data.amount.doubleValue, cardTranNumber: data.cardTranNumber, city: data.city, comment: data.comment, country: data.country, currencyCodeNumeric: data.currencyCodeNumeric, date: data.date, deviceCode: data.deviceCode, documentAmount: data.documentAmount.doubleValue, documentId: data.documentID, fastPayment: fastPayment, groupName: data.groupName, isCancellation: data.isCancellation, md5hash: data.md5hash, merchantName: data.merchantName, merchantNameRus: data.merchantNameRus, opCode: data.opCode, operationId: data.operationId, operationType: data.operationType.value, paymentDetailType: data.paymentDetailType.value, svgImage: svgImage, terminalCode: data.terminalCode, tranDate: data.tranDate, type: data.type.value)
    }
}

extension ProductStatementData.FastPayment {
    init(
        data: CardStatementAPI.ProductStatementData.FastPayment
    ) {
        self = .init(
            documentComment: data.documentComment,
            foreignBankBIC: data.foreignBankBIC,
            foreignBankID: data.foreignBankID,
            foreignBankName: data.foreignBankName,
            foreignName: data.foreignName,
            foreignPhoneNumber: data.foreignPhoneNumber,
            opkcid: data.opkcid,
            operTypeFP: data.operTypeFP,
            tradeName: data.tradeName,
            guid: data.guid)
    }
}

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}
