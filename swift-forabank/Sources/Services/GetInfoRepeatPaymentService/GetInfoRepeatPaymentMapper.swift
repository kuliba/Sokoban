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
    
    public struct DecodableGetInfoRepeatPaymentCode: Decodable {
        
        public let type: TransferType
        public let parameterList: [Transfer]
        public let productTemplate: ProductTemplate?
    
        public init(
            type: TransferType,
            parameterList: [Transfer],
            productTemplate: ProductTemplate?
        ) {
            self.type = type
            self.parameterList = parameterList
            self.productTemplate = productTemplate
        }
        
        public enum TransferType: String, Decodable {
            
            case betweenTheir = "BETWEEN_THEIR"
            case byPhone = "BY_PHONE"
            case contactAddressless = "CONTACT_ADDRESSLESS"
            case direct = "NEW_DIRECT"
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
        
        public struct Transfer: Decodable {
            
            public let check: Bool
            public let amount: Double?
            public let currencyAmount: String?
            public let payer: Payer?
            public let comment: String?
            public let puref: String?
            public let payeeInternal: PayeeInternal?
            public let payeeExternal: PayeeExternal?
            public let additional: [Additional]?
            public let mcc: String?

            public struct PayeeInternal: Decodable, Equatable {
                
                let accountId: Int?
                let accountNumber: String?
                let cardId: Int?
                let cardNumber: String?
                let phoneNumber: String?
                let productCustomName: String?
            }
            
            public struct PayeeExternal: Decodable, Equatable {
                
                public let inn: String?
                public let kpp: String?
                public let accountId: Int?
                public let accountNumber: String
                public let bankBIC: String?
                public let cardId: Int?
                public let cardNumber: String?
                public let compilerStatus: String?
                public let date: String?
                public let name: String
                public let tax: Tax?
                
                public struct Tax: Decodable, Equatable {
                    
                    public let bcc: String?
                    public let date: String?
                    public let documentNumber: String?
                    public let documentType: String?
                    public let oktmo: String?
                    public let period: String?
                    public let reason: String?
                    public let uin: String?
                }
                
                private enum CodingKeys : String, CodingKey {
                    case inn = "INN", kpp = "KPP", accountId, accountNumber, bankBIC, cardId, cardNumber, compilerStatus, date, name, tax
                }
            }
            
            public struct Additional: Decodable {
            
                public let fieldname: String
                public let fieldid: Int
                public let fieldvalue: String
            }
            
            public struct Payer: Decodable {
                
                public let cardId: Int
                public let cardNumber: String?
                public let accountId: Int?
                public let accountNumber: String?
                public let phoneNumber: String?
                public let INN: String?
            }
        }
        
        public struct ProductTemplate: Decodable {
            
            public let id: Int?
            public let numberMask: String?
            public let customName: String?
            public let currency: String?
            public let type: ProductType?
            public let smallDesign: String?
            public let paymentSystemImage: String?
            
            public enum ProductType: String, Decodable {
                
                case account = "ACCOUNT"
                case card = "CARD"
                case deposit = "DEPOSIT"
                case loan = "LOAN"
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
        }
    }
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    init(decodableGetInfoRepeatPaymentCode: GetInfoRepeatPaymentMapper.DecodableGetInfoRepeatPaymentCode) {
     
        self.type = decodableGetInfoRepeatPaymentCode.type.transferType
        self.parameterList = decodableGetInfoRepeatPaymentCode.parameterList.map({ .init(transfer: $0) })
        
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
