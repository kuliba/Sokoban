//
//  GetInfoRepeatPaymentMapper.swift
//
//
//  Created by Дмитрий Савушкин on 30.07.2024.
//

import Foundation

public enum GetInfoRepeatPaymentMapper {
    
    public typealias Result = GetInfoRepeatPaymentDomain.Result
    
    public static func mapResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> Result {
        
        do {
            let decodableGetInfoRepeat = try JSONDecoder().decode(Response.self, from: data)
            
            if let data = decodableGetInfoRepeat.data {

                return .success(.init(decodableGetInfoRepeatPaymentCode: data))
            } else {
                return .failure(.serverError(statusCode: httpURLResponse.statusCode, errorMessage: "Invalid json"))
            }
            
        } catch let error {
            return .failure(.serverError(statusCode: httpURLResponse.statusCode, errorMessage: error.localizedDescription))
        }
    }

    private struct Response: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: DecodableGetInfoRepeatPaymentCode?
    }
    
    struct DecodableGetInfoRepeatPaymentCode: Decodable {
        
        public let type: TransferType
        public let parameterList: [Transfer]
        public let productTemplate: ProductTemplate?
    
        public init(
            type: TransferType,
            parameterList: [Transfer],
            productTemplate: ProductTemplate
        ) {
            self.type = type
            self.parameterList = parameterList
            self.productTemplate = productTemplate
        }
        
        enum TransferType: String, Decodable {
            
            case betweenTheir = "BETWEEN_THEIR"
            case contactAddressless = "CONTACT_ADDRESSLESS"
            case direct = "DIRECT"
            case externalEntity = "EXTERNAL_ENTITY"
            case externalIndivudual = "EXTERNAL_INDIVIDUAL"
            case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
            case insideBank = "INSIDE_BANK"
            case internet = "INTERNET"
            case mobile = "MOBILE"
            case otherBank = "OTHER_BANK"
            case sfp = "SFP"
            case transport = "TRANSPORT"
            case taxes = "TAX_AND_STATE_SERVICE"
        }
        
        struct Transfer: Decodable {
            
            let check: Bool
            let amount: Double
            let currencyAmount: String
            let payer: Payer
            let comment: String?
            let puref: String
            let additional: [Additional]
            let mcc: String?

            struct Additional: Decodable {
            
                let fieldname: String
                let fieldid: Int
                let fieldvalue: String
            }
            
            struct Payer: Decodable {
                
                let cardId: Int
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
            
            enum ProductType: Decodable {
                
                case account
                case card
                case loan
                case deposit
            }
        }
    }
    
    private struct ServerError: Decodable {
        
        let statusCode: Int
        let errorMessage: String
    }
}

private extension GetInfoRepeatPaymentMapper.DecodableGetInfoRepeatPaymentCode.TransferType {
    
    var transferType: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.TransferType {
        
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
        }
    }
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    init(decodableGetInfoRepeatPaymentCode: GetInfoRepeatPaymentMapper.DecodableGetInfoRepeatPaymentCode) {
     
        self.type = decodableGetInfoRepeatPaymentCode.type.transferType
        self.parameterList = decodableGetInfoRepeatPaymentCode.parameterList.map({
            .init(
                check: $0.check,
                amount: $0.amount,
                currencyAmount: $0.currencyAmount,
                payer: .init(
                    cardId: $0.payer.cardId,
                    cardNumber: $0.payer.cardNumber,
                    accountId: $0.payer.accountId,
                    accountNumber: $0.payer.accountNumber,
                    phoneNumber: $0.payer.phoneNumber,
                    inn: $0.payer.INN
                ),
                comment: $0.comment,
                puref: $0.puref,
                additional: $0.additional.map({ .init(fieldname: $0.fieldname, fieldid: $0.fieldid, fieldvalue: $0.fieldvalue)}),
                mcc: $0.mcc
            )
        })
        
        self.productTemplate = .init(
            id: decodableGetInfoRepeatPaymentCode.productTemplate?.id,
            numberMask: decodableGetInfoRepeatPaymentCode.productTemplate?.numberMask,
            customName: decodableGetInfoRepeatPaymentCode.productTemplate?.customName,
            currency: decodableGetInfoRepeatPaymentCode.productTemplate?.currency,
            type: .init(productType: decodableGetInfoRepeatPaymentCode.productTemplate?.type ?? .card),
            smallDesign: decodableGetInfoRepeatPaymentCode.productTemplate?.smallDesign,
            paymentSystemImage: decodableGetInfoRepeatPaymentCode.productTemplate?.paymentSystemImage
        )
    }
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.ProductTemplate.ProductType {

    init(productType: GetInfoRepeatPaymentMapper.DecodableGetInfoRepeatPaymentCode.ProductTemplate.ProductType) {
        
        switch productType {
        case .account:
            self = .account
        case .card:
            self = .card
        case .deposit:
            self = .deposit
        case .loan:
            self = .loan
        }
    }
}
