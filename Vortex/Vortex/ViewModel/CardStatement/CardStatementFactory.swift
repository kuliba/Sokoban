//
//  CardStatementFactory.swift
//  Vortex
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
        cardNumber: CardStatementForPeriodPayload.CardNumber? = nil,
        operationType: String? = nil,
        operationGroup: [String]? = nil,
        includeAdditionalCards: Bool? = nil
    ) async throws-> [ProductStatementData] {
        
        let payload = CardStatementForPeriodPayload(
            id: .init(productId),
            name: name,
            period: .init(start: period.start, end: period.end),
            statementFormat: statementFormat,
            cardNumber: cardNumber,
            operationType: operationType,
            operationGroup: operationGroup,
            includeAdditionalCards: includeAdditionalCards
        )
        let data = try await getCardStatementForPeriod(httpClient: httpClient).process(payload).get()
        
        return data.map { .init(data: $0) }
    }
    
    private func getCardStatementForPeriod(
        httpClient: HTTPClient
    ) -> Services.GetCardStatementService {
        
        Services.getCardStatementForPeriod(httpClient: httpClient)
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

extension CardStatementAPI.ProductStatementData.OperationEnvironment {
    
    var value: OperationEnvironment {
        
        switch self {
        case .inside: return .inside
        case .outside: return .outside
        }
    }
}


extension ProductStatementData {
    
    init(
        data: CardStatementAPI.ProductStatementData
    ) {
        let fastPayment: ProductStatementData.FastPayment? = data.fastPayment.map { .init(data: $0) }
        let svgImage: SVGImageData? = data.svgImage.map { .init(description: $0) }
        
        self = .init(
            mcc: data.MCC,
            accountId: data.accountID,
            accountNumber: data.accountNumber,
            amount: data.amount.doubleValue,
            cardTranNumber: data.cardTranNumber,
            city: data.city,
            comment: data.comment,
            country: data.country,
            currencyCodeNumeric: data.currencyCodeNumeric,
            date: data.date,
            deviceCode: data.deviceCode,
            documentAmount: data.documentAmount.doubleValue,
            documentId: data.documentID,
            fastPayment: fastPayment,
            groupName: data.groupName,
            isCancellation: data.isCancellation,
            md5hash: data.md5hash,
            merchantName: data.merchantName,
            merchantNameRus: data.merchantNameRus,
            opCode: data.opCode,
            operationId: data.operationId,
            operationType: data.operationType.value,
            paymentDetailType: data.paymentDetailType,
            svgImage: svgImage,
            terminalCode: data.terminalCode,
            tranDate: data.tranDate,
            type: data.type.value,
            // V3
            discount: data.discount,
            transAmm: data.transAmm,
            discountExpiry: data.discountExpiry,
            dateN: data.dateN,
            paymentTerm: data.paymentTerm,
            legalAct: data.legalAct,
            supplierBillID: data.supplierBillId,
            realPayerFIO: data.realPayerFIO,
            realPayerINN: data.realPayerINN,
            realPayerKPP: data.realPayerKPP,
            upno: data.upno
        )
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
            guid: data.guid
        )
    }
}

extension Decimal {
    
    var doubleValue: Double {
        
        return NSDecimalNumber(decimal:self).doubleValue
    }
}
