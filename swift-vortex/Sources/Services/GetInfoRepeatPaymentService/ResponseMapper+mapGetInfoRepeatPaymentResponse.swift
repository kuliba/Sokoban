//
//  ResponseMapper+mapGetInfoRepeatPaymentResponse.swift
//
//
//  Created by Andryusina Nataly on 19.12.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    typealias GetInfoRepeatPaymentResult = GetInfoRepeatPaymentDomain.GetInfoRepeatPayment
    
    static func mapGetInfoRepeatPaymentResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetInfoRepeatPaymentResult> {
        
        map(data, httpURLResponse, mapOrThrow: GetInfoRepeatPaymentResult.init(data:))
    }
}

private extension ResponseMapper.GetInfoRepeatPaymentResult {
    
    init(data: ResponseMapper._Data) {
        self.init(
            type: data.type ?? "",
            parameterList: data.parameterList.compactMap { .init($0) },
            productTemplate: data.productTemplate.map { .init($0) }, 
            paymentFlow: data.paymentFlow
        )
    }
}

private extension ResponseMapper.GetInfoRepeatPaymentResult.ProductTemplate {
    
    init(_ data: ResponseMapper._Data.ProductTemplate) {
       
        self.init(
            id: data.id,
            numberMask: data.numberMask,
            customName: data.customName,
            currency: data.currency,
            type: data.type?.type,
            smallDesign: data.smallDesign,
            paymentSystemImage: data.paymentSystemImage
        )
    }
}

private extension ResponseMapper._Data.ProductTemplate.ProductType {
    
    var type: ResponseMapper.GetInfoRepeatPaymentResult.ProductTemplate.ProductType {
        switch self {
        case .account:
            return .account
        case .card:
            return .card
        case .deposit:
            return .deposit
        case .loan:
            return .loan
        }
    }
}

private extension ResponseMapper.GetInfoRepeatPaymentResult.Transfer {
    
    init(_ data: ResponseMapper._Data.Transfer) {
        
        self.init(
            check: data.check,
            amount: data.amount,
            currencyAmount: data.currencyAmount,
            payer: data.payer.map { .init($0) },
            comment: data.comment,
            puref: data.puref,
            payeeInternal: data.payeeInternal.map { .init($0) },
            payeeExternal: data.payeeExternal.map { .init($0) },
            additional: data.additional.map { $0.map { .init($0) }},
            mcc: data.mcc)
    }
}

private extension ResponseMapper.GetInfoRepeatPaymentResult.Transfer.Payer {
    
    init(_ data: ResponseMapper._Data.Transfer.Payer) {
        
        self.init(
            cardId: data.cardId,
            cardNumber: data.cardNumber,
            accountId: data.accountId,
            accountNumber: data.accountNumber,
            phoneNumber: data.phoneNumber,
            inn: data.INN
        )
    }
}

private extension ResponseMapper.GetInfoRepeatPaymentResult.Transfer.PayeeInternal {
    
    init(_ data: ResponseMapper._Data.Transfer.PayeeInternal) {
        
        self.init(
            accountId: data.accountId,
            accountNumber: data.accountNumber,
            cardId: data.cardId,
            cardNumber: data.cardNumber,
            phoneNumber: data.phoneNumber,
            productCustomName: data.productCustomName
        )
    }
}

private extension ResponseMapper.GetInfoRepeatPaymentResult.Transfer.PayeeExternal {
    
    init(_ data: ResponseMapper._Data.Transfer.PayeeExternal) {
       
        self.init(
            inn: data.inn,
            kpp: data.kpp,
            accountId: data.accountId,
            accountNumber: data.accountNumber,
            bankBIC: data.bankBIC,
            cardId: data.cardId,
            cardNumber: data.cardNumber,
            compilerStatus: data.compilerStatus,
            date: data.date,
            name: data.name
        )
    }
}

private extension ResponseMapper.GetInfoRepeatPaymentResult.Transfer.Additional {
    
    init(_ data: ResponseMapper._Data.Transfer.Additional) {
       
        self.init(
            fieldname: data.fieldname,
            fieldid: data.fieldid,
            fieldvalue: data.fieldvalue
        )
    }
}

/*private extension ResponseMapper._Data.TransferType {
    
    var type: ResponseMapper.GetInfoRepeatPaymentResult.TransferType {
        
        switch self {
        case .betweenTheir:
            return .betweenTheir
        case .byPhone:
            return .byPhone
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
        case .internet:
            return .internet
        case .mobile:
            return .mobile
        case .otherBank:
            return .otherBank
        case .sfp:
            return .sfp
        case .taxes:
            return .taxes
        case .transport:
            return .transport
        case .addressingCash:
            return .addressingCash
        case .addressless:
            return .addressless
        case .charityService:
            return .charityService
        case .digitalWalletsService:
            return .digitalWalletsService
        case .educationService:
            return .educationService
        case .foreignCard:
            return .foreignCard
        case .networkMarketingService:
            return .networkMarketingService
        case .newDirect:
            return .newDirect
        case .newDirectAccount:
            return .newDirectAccount
        case .newDirectCard:
            return .newDirectCard
        case .repaymentLoansAndAccountsService:
            return .repaymentLoansAndAccountsService
        case .securityService:
            return .securityService
        case .socialAndGamesService:
            return .socialAndGamesService
        }
    }
}*/

private extension ResponseMapper {
        
    struct _Data: Decodable {
        
        let type: String?
        let parameterList: [Transfer]
        let productTemplate: ProductTemplate?
        let paymentFlow: String?
        
        struct Transfer: Decodable {
            
            let check: Bool
            let amount: Double?
            let currencyAmount: String?
            let payer: Payer?
            let comment: String?
            let puref: String?
            let payeeInternal: PayeeInternal?
            let payeeExternal: PayeeExternal?
            let additional: [Additional]?
            let mcc: String?
            
            struct PayeeInternal: Decodable, Equatable {
                
                let accountId: Int?
                let accountNumber: String?
                let cardId: Int?
                let cardNumber: String?
                let phoneNumber: String?
                let productCustomName: String?
            }
            
            struct PayeeExternal: Decodable, Equatable {
                
                let inn: String?
                let kpp: String?
                let accountId: Int?
                let accountNumber: String
                let bankBIC: String?
                let cardId: Int?
                let cardNumber: String?
                let compilerStatus: String?
                let date: String?
                let name: String
                let tax: Tax?
                
                struct Tax: Decodable, Equatable {
                    
                    let bcc: String?
                    let date: String?
                    let documentNumber: String?
                    let documentType: String?
                    let oktmo: String?
                    let period: String?
                    let reason: String?
                    let uin: String?
                }
                
                private enum CodingKeys : String, CodingKey {
                    case inn = "INN", kpp = "KPP", accountId, accountNumber, bankBIC, cardId, cardNumber, compilerStatus, date, name, tax
                }
            }
            
            struct Additional: Decodable {
                
                let fieldname: String
                let fieldid: Int
                let fieldvalue: String
            }
            
            struct Payer: Decodable {
                
                let cardId: Int?
                let cardNumber: String?
                let accountId: Int?
                let accountNumber: String?
                let phoneNumber: String?
                let INN: String?
            }
        }
        
        struct ProductTemplate: Decodable {
            
            let id: Int?
            let numberMask: String?
            let customName: String?
            let currency: String?
            let type: ProductType?
            let smallDesign: String?
            let paymentSystemImage: String?
            
            enum ProductType: String, Decodable {
                
                case account = "ACCOUNT"
                case card = "CARD"
                case deposit = "DEPOSIT"
                case loan = "LOAN"
            }
        }
    }
}
