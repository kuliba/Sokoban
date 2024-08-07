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
    typealias Result = Swift.Result<Payload, Error>
    typealias Completion = (Result) -> Void
    
    typealias Response = Swift.Result<(Data, HTTPURLResponse), Swift.Error>
    typealias ResponseCompletion = (Response) -> Void
    typealias PerformRequest = (URLRequest, @escaping ResponseCompletion) -> Void
    typealias MapResponse = (Data, HTTPURLResponse) -> Result
    
    enum Error: Swift.Error, Equatable {
        
        case connectivity
        case serverError(statusCode: Int, errorMessage: String)
    }
}

extension GetInfoRepeatPaymentDomain {
    
    public struct GetInfoRepeatPayment: Equatable {
        
        let type: String
        let parameterList: [Transfer]
        let productTemplate: ProductTemplate?
    
        public init(
            type: String,
            parameterList: [Transfer],
            productTemplate: ProductTemplate?
        ) {
            self.type = type
            self.parameterList = parameterList
            self.productTemplate = productTemplate
        }
        
        public struct Transfer: Equatable {
            
            let check: Bool
            let amount: Double
            let currencyAmount: String
            let payer: Payer
            
            public init(
                check: Bool,
                amount: Double,
                currencyAmount: String,
                payer: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer.Payer
            ) {
                self.check = check
                self.amount = amount
                self.currencyAmount = currencyAmount
                self.payer = payer
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
            
            let id: Int
            let numberMask: String
            let customName: String
            let currency: String
            let type: ProductType
            let smallDesign: String
            let paymentSystemImage: String
            
            enum ProductType: Equatable {
                
                case account
                case card
                case loan
                case deposit
            }
        }
    }
}
