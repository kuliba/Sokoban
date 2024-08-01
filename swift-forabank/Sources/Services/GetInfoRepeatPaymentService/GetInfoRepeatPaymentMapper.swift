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
            
            return .success(.init(decodableGetInfoRepeatPaymentCode: decodableGetInfoRepeat))
        } catch let error {
            return .failure(.serverError(statusCode: httpURLResponse.statusCode, errorMessage: error.localizedDescription))
        }
    }
    
    struct DecodableGetInfoRepeatPaymentCode: Decodable {
        
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
        
        struct Transfer: Decodable {
            
            let check: Bool
            let amount: Double
            let currencyAmount: String
            let payer: Payer
            
            struct Payer: Decodable {
                
                let cardId: Int
                let cardNumber: String
                let accountId: Int
                let accountNumber: String
                let phoneNumber: String
                let inn: String
            }
        }
        
        struct ProductTemplate: Decodable {
            
            let id: Int
            let numberMask: String
            let customName: String
            let currency: String
            let type: ProductType
            let smallDesign: String
            let paymentSystemImage: String
            
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

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPaymentCode {
    
    init(decodableGetInfoRepeatPaymentCode: GetInfoRepeatPaymentMapper.DecodableGetInfoRepeatPaymentCode) {
     
        self.type = decodableGetInfoRepeatPaymentCode.type
        self.parameterList = decodableGetInfoRepeatPaymentCode.parameterList.map({
            .init(check: $0.check, amount: $0.amount, currencyAmount: $0.currencyAmount, payer: .init(
                cardId: $0.payer.cardId,
                cardNumber: $0.payer.cardNumber,
                accountId: $0.payer.accountId,
                accountNumber: $0.payer.accountNumber,
                phoneNumber: $0.payer.phoneNumber,
                inn: $0.payer.inn
            ))
        })
        
        self.productTemplate = .init(
            id: decodableGetInfoRepeatPaymentCode.productTemplate.id,
            numberMask: decodableGetInfoRepeatPaymentCode.productTemplate.numberMask,
            customName: decodableGetInfoRepeatPaymentCode.productTemplate.customName,
            currency: decodableGetInfoRepeatPaymentCode.productTemplate.currency,
            type: .init(productType: decodableGetInfoRepeatPaymentCode.productTemplate.type),
            smallDesign: decodableGetInfoRepeatPaymentCode.productTemplate.smallDesign,
            paymentSystemImage: decodableGetInfoRepeatPaymentCode.productTemplate.paymentSystemImage
        )
    }
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPaymentCode.ProductTemplate.ProductType {

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
