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
    ) -> Swift.Result<[ProductStatementData], MappingError> {
        
        let statusCode = response.statusCode
        
        switch statusCode {
        case statusCode200:
            return handle200(with: data)
            
        default:
            return errorByCode(statusCode)
        }
    }
    
    private static func handle200(with data: Data) -> Swift.Result<[ProductStatementData], MappingError> {
        
        do {
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601)
            
            let response = try decoder.decode(GetCardStatementForPeriodResponse.self, from: data)
            switch response.statusCode {
                
            default:
                guard let data = response.data
                else { return .failure(.mappingFailure(response.errorMessage ?? .defaultError))}
                return .success(data.map { .init(data: $0) })
            }
        } catch {
            return .failure(.mappingFailure(.defaultError))
        }
    }
    
    private static func errorByCode(
        _ code: Int
    ) -> Swift.Result<[ProductStatementData], MappingError> {
        
        .failure(.mappingFailure(HTTPURLResponse.localizedString(forStatusCode: code)))
    }
}

private let statusCode200 = 200

private extension ResponseMapper {
    
    typealias _Data = [_DTO]
}

private extension ResponseMapper {
    
    struct _DTO: Decodable, Equatable {
        
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

private extension ResponseMapper._DTO {
    
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
        
        case credit = "CREDIT"
        case debit = "DEBIT"
        case open = "OPEN"
        case demandDepositFromAccount = "DV"
    }
}

private extension ResponseMapper._DTO.OperationType {
    
    var value: ProductStatementData.OperationType {
        
        switch self {
        case .credit:
            return .credit
        case .debit:
            return .debit
        case .open:
            return .open
        case .demandDepositFromAccount:
            return .demandDepositFromAccount
        }
    }
}

public extension String {
    
    static let defaultError: Self = "Возникла техническая ошибка"
}

private struct GetCardStatementForPeriodResponse: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: ResponseMapper._Data?
}

private extension ProductStatementData {
    
    init(
        data: ResponseMapper._DTO
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
