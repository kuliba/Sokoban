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
    
    typealias Payload = GetInfoRepeatPaymentCode
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
    
    public struct GetInfoRepeatPaymentCode: Equatable {
        
        public let type: String
        public let parameterList: [Transfer]
        public let productTemplate: ProductTemplate
    
        public init(
            type: String,
            parameterList: [Transfer],
            productTemplate: ProductTemplate
        ) {
            self.type = type
            self.parameterList = parameterList
            self.productTemplate = productTemplate
        }
        
        struct Transfer {
            
            let check: Bool
            let amount: Double
            let currencyAmount: String
            let payer: Payer
            
            struct Payer {
                
                let cardId: Int
                let cardNumber: String
                let accountId: Int
                let accountNumber: String
                let phoneNumber: String
                let inn: String
            }
        }
        
        struct ProductTemplate {
            
            let id: Int
            let numberMask: String
            let customName: String
            let currency: String
            let type: ProductType
            let smallDesign: String
            let paymentSystemImage: String
            
            enum ProductType {
                
                case account
                case card
                case loan
                case deposit
            }
        }
    }
}
