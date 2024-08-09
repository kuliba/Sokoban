//
//  GetInfoRepeatPaymentDomain.swift
//
//
//  Created by Дмитрий Савушкин on 30.07.2024.
//

import Foundation

/// A namespace.
public enum GetInfoRepeatPaymentDomain {}

public extension GetInfoRepeatPaymentDomain {
    
    typealias Payload = GetInfoRepeatPayment
    typealias Result = Swift.Result<Payload, InfoPaymentError>
    typealias Completion = (Result) -> Void
    
    typealias Response = Swift.Result<(Data, HTTPURLResponse), Swift.Error>
    typealias ResponseCompletion = (Response) -> Void
    typealias PerformRequest = (URLRequest, @escaping ResponseCompletion) -> Void
    typealias MapResponse = (Data, HTTPURLResponse) -> Result
    
    enum InfoPaymentError: Error, Equatable {
        
        case connectivity
        case serverError(statusCode: Int, errorMessage: String)
    }
}

extension GetInfoRepeatPaymentDomain {
    
    public struct GetInfoRepeatPayment: Equatable {
        
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
        
        public struct Transfer: Equatable {
            
            let check: Bool
            let amount: Double
            let currencyAmount: String
            let payer: Payer
            let comment: String?
            let puref: String
            let additional: [Additional]
            let mcc: String?
            
            public init(
                check: Bool,
                amount: Double,
                currencyAmount: String,
                payer: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer.Payer,
                comment: String?,
                puref: String,
                additional: [Additional],
                mcc: String?
            ) {
                self.check = check
                self.amount = amount
                self.currencyAmount = currencyAmount
                self.payer = payer
                self.comment = comment
                self.puref = puref
                self.additional = additional
                self.mcc = mcc
            }
            
            public struct Additional: Equatable {
            
                let fieldname: String
                let fieldid: Int
                let fieldvalue: String
            }
            
            public struct Payer: Equatable {
                
                let cardId: Int?
                let cardNumber: String?
                let accountId: Int?
                let accountNumber: String?
                let phoneNumber: String?
                let inn: String?
                
                public init(
                    cardId: Int?,
                    cardNumber: String?,
                    accountId: Int?,
                    accountNumber: String?,
                    phoneNumber: String?,
                    inn: String?
                ) {
                    self.cardId = cardId
                    self.cardNumber = cardNumber
                    self.accountId = accountId
                    self.accountNumber = accountNumber
                    self.phoneNumber = phoneNumber
                    self.inn = inn
                }
            }
        }
        
        public struct ProductTemplate: Equatable {
            
            let id: Int?
            let numberMask: String?
            let customName: String?
            let currency: String?
            let type: ProductType?
            let smallDesign: String?
            let paymentSystemImage: String?
            
            enum ProductType: Equatable {
                
                case account
                case card
                case loan
                case deposit
            }
        }
    }
}
