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
            let decodableGetInfoRepeat = try JSONDecoder().decode(DecodableGetInfoRepeatPaymentCode.self, from: data)
            
            return .success(decodableGetInfoRepeat)
        } catch {
            return .failure(.invalidData(statusCode: 200))
        }
    }
    
    private struct DecodableGetInfoRepeatPaymentCode: Decodable {
        
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
    
    private struct ServerError: Decodable {
        
        let statusCode: Int
        let errorMessage: String
    }
}
