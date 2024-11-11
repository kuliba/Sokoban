//
//  ResponseMapper+mapGetCardStatementResponse.swift
//
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

public extension ResponseMapper {
    
    static func mapGetCardStatementResponse(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Swift.Result<ProductStatementWithExtendedInfo, MappingError> {
        
        map(data, response, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> ProductStatementWithExtendedInfo {
        
        .init(
            summary: .init(data: data.summary),
            aggregated: data.aggregated.map({ $0.map({ .init(data: $0) }) }),
            operationList: data.operationList.map({ .init(data: $0 )})
        )
    }
}

private extension ResponseMapper {
    
    typealias _Data = _DTO
}

private extension ResponseMapper {
    
    struct _DTO: Decodable, Equatable {
        
        let summary: ProductStatementSummary
        let aggregated: [ProductStatementAggregated]?
        let operationList: [ProductStatementData]
        
        public struct ProductStatementSummary: Decodable, Equatable {
        
            let currencyCodeNumeric: String?
            let creditOperation: Bool?
            let debitOperation: Bool?
        }
        
        public struct ProductStatementAggregated: Decodable, Equatable {
            
            let groupByName: String?
            let baseColor: String?
            let debit: ProductStatementAmountAndPercent?
            let credit: ProductStatementAmountAndPercent?
        }
        
        public struct ProductStatementAmountAndPercent: Decodable, Equatable {
            
            let amount: Double?
            let amountPercent: Double?
        }
        
        struct ProductStatementData: Decodable, Equatable {
            
            let type: OperationEnvironment
            let accountID: Int?
            let operationType: OperationType
            let paymentDetailType: Kind
            let amount: Decimal?
            let documentAmount: Decimal?
            let comment: String
            let documentID: Int?
            let accountNumber: String
            let currencyCodeNumeric: Int
            let merchantName: String?
            let merchantNameRus: String?
            let groupName: String
            let md5hash: String
            let svgImage: String? // add svgKit
            let fastPayment: FastPayment?
            let terminalCode: String?
            let deviceCode: String?
            let country: String?
            let city: String?
            let operationId: String
            let isCancellation: Bool?
            let cardTranNumber: String?
            let opCode: Int?
            let date: Date
            let tranDate: Date?
            let MCC: Int?
        }
    }
}

private extension ResponseMapper._DTO.ProductStatementData {
    
    var amountValue: Decimal { amount ?? 0 }
    var documentAmountValue:  Decimal { documentAmount ?? 0 }
}

private extension ResponseMapper._DTO {
    
    struct FastPayment: Decodable, Equatable {
        
        let opkcid: String
        let foreignName: String
        let foreignPhoneNumber: String
        let foreignBankBIC: String
        let foreignBankID: String
        let foreignBankName: String
        let documentComment: String
        let operTypeFP: String
        let tradeName: String
        let guid: String
    }
}

private extension ResponseMapper._DTO {
    
    enum Kind: String, Decodable {
        
        case betweenTheir = "BETWEEN_THEIR"
        case contactAddressless = "CONTACT_ADDRESSLESS"
        case direct = "DIRECT"
        case externalEntity = "EXTERNAL_ENTITY"
        case externalIndivudual = "EXTERNAL_INDIVIDUAL"
        case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
        case insideBank = "INSIDE_BANK"
        case insideOther = "INSIDE_OTHER"
        case internet = "INTERNET"
        case mobile = "MOBILE"
        case notFinance = "NOT_FINANCE"
        case otherBank = "OTHER_BANK"
        case outsideCash = "OUTSIDE_CASH"
        case outsideOther = "OUTSIDE_OTHER"
        case sfp = "SFP"
        case transport = "TRANSPORT"
        case taxes = "TAX_AND_STATE_SERVICE"
        case c2b = "C2B_PAYMENT"
        case insideDeposit = "INSIDE_DEPOSIT"
        case sberQRPayment = "SBER_QR_PAYMENT"
        case networkMarketing = "NETWORK_MARKETING_SERVICE"
        case digitalWallet = "DIGITAL_WALLETS_SERVICE"
        case charity = "CHARITY_SERVICE"
        case socialAndGame = "SOCIAL_AND_GAMES_SERVICE"
        case education = "EDUCATION_SERVICE"
        case security = "SECURITY_SERVICE"
        case repayment = "REPAYMENT_LOANS_AND_ACCOUNTS_SERVICE"
    }
}

private extension ResponseMapper._DTO.Kind {
    
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
        case .education:
            return .education
        case .security:
            return .security
        case .repayment:
            return .repayment
        }
    }
}

private extension ResponseMapper._DTO {
    
    enum OperationEnvironment: String, Decodable {
        
        case inside = "INSIDE"
        case outside = "OUTSIDE"
    }
}

private extension ResponseMapper._DTO.OperationEnvironment {
    
    var value: ProductStatementData.OperationEnvironment {
        
        switch self {
        case .inside:
            return .inside
        case .outside:
            return .outside
        }
    }
}

private extension ResponseMapper._DTO {
    
    enum OperationType: String, Decodable {
        
        case credit = "CREDIT" // пополнение - со знаком плюс
        case creditPlan = "CREDIT_PLAN" // пополнение (значок с часами - В обработке) - со знаком плюс
        case creditFict = "CREDIT_FICT" // пополнение (значок с красным крестиком - Отказ) - со знаком плюс
        
        /// debiting money from an account
        case debit = "DEBIT" // списание - со знаком минус
        case debitPlan = "DEBIT_PLAN" // списание (значок с часами - В обработке) - со знаком минус
        case debitFict = "DEBIT_FICT" // списание (значок с красным крестиком - Отказ) - со знаком минус
        
        case open = "OPEN"
        
        case demandDepositFromAccount = "DV" // not finance operation transfer account into demand deposit
    }
}

private extension ResponseMapper._DTO.OperationType {
    
    var value: ProductStatementData.OperationType {
        
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

public extension String {
    
    static let defaultErrorMessage: Self = "Возникла техническая ошибка"
}

private struct GetCardStatementForPeriodResponse: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: ResponseMapper._Data?
}

private extension ProductStatementWithExtendedInfo.ProductStatementAggregated {

    init(data: ResponseMapper._DTO.ProductStatementAggregated?) {
        self.init(
            groupByName: data?.groupByName,
            baseColor: data?.baseColor,
            debit: data?.debit.map({ .init(amount: $0.amount, amountPercent: $0.amountPercent) }),
            credit: data?.credit.map({ .init(amount: $0.amount, amountPercent: $0.amountPercent) })
        )
    }
}

private extension ProductStatementWithExtendedInfo.ProductStatementSummary {

    init(data: ResponseMapper._DTO.ProductStatementSummary?) {
        
        self.init(
            currencyCodeNumeric: data?.currencyCodeNumeric,
            creditOperation: data?.creditOperation,
            debitOperation: data?.debitOperation
        )
    }
}

private extension ProductStatementData {
    
    init(
        data: ResponseMapper._DTO.ProductStatementData
    ) {
        
        let fastPayment: ProductStatementData.FastPayment? = data.fastPayment.map {
            .init(data: $0)
        }
        
        self = .init(
            type: data.type.value,
            accountID: data.accountID,
            operationType: data.operationType.value,
            paymentDetailType: data.paymentDetailType.value,
            amount: data.amountValue,
            documentAmount: data.documentAmountValue,
            comment: data.comment,
            documentID: data.documentID,
            accountNumber: data.accountNumber,
            currencyCodeNumeric: data.currencyCodeNumeric,
            merchantName: data.merchantName,
            merchantNameRus: data.merchantNameRus,
            groupName: data.groupName,
            md5hash: data.md5hash,
            svgImage: data.svgImage,
            fastPayment: fastPayment,
            terminalCode: data.terminalCode,
            deviceCode: data.deviceCode,
            country: data.country,
            city: data.city,
            operationId: data.operationId,
            isCancellation: data.isCancellation,
            cardTranNumber: data.cardTranNumber,
            opCode: data.opCode,
            date: data.date,
            tranDate: data.tranDate,
            MCC: data.MCC)
    }
}

private extension ProductStatementData.FastPayment {
    
    init(
        data: ResponseMapper._DTO.FastPayment
    ) {
        self = .init(
            opkcid: data.opkcid,
            foreignName: data.foreignName,
            foreignPhoneNumber: data.foreignPhoneNumber,
            foreignBankBIC: data.foreignBankBIC,
            foreignBankID: data.foreignBankID,
            foreignBankName: data.foreignBankName,
            documentComment: data.documentComment,
            operTypeFP: data.operTypeFP,
            tradeName: data.tradeName,
            guid: data.guid)
    }
}
