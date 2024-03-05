//
//  ResponseMapper+mapGetProductDetailsResponse.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation
import Services

public extension ResponseMapper {
    
    static func mapGetProductDetailsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<ProductDetails> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _DTO
    ) throws -> ProductDetails {
        
        data.data
    }
}

private extension ResponseMapper._DTO {
    
    var data: ProductDetails {
                
        return .init(details: details.data)
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let details: _Details
        
        enum CodingKeys: String, CodingKey {
            case data
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            details = try container.decode(_Details.self, forKey: .data)
        }
    }
    
    enum _Details: Decodable {
        
        case accountDetails(_AccountDetails)
        case cardDetails(_CardDetails)
        case depositDetails(_DepositDetails)
        
        var data: Details {
            
            switch self {
                
            case let .accountDetails(details):
                return .accountDetails(details.data)
            case let .cardDetails(details):
                return .cardDetails(details.data)
            case let .depositDetails(details):
                return .depositDetails(details.data)
            }
        }
    }
    
    struct _AccountDetails: Decodable {
        
        let accountNumber: String
        let bic: String
        let corrAccount: String
        let inn: String
        let kpp: String
        let payeeName: String
        
        var data: AccountDetails {
            .init(
                accountNumber: accountNumber,
                bic: bic,
                corrAccount: corrAccount,
                inn: inn,
                kpp: kpp,
                payeeName: payeeName
            )
        }
    }
    
    struct _CardDetails: Decodable {
        
        let accountNumber: String
        let bic: String
        let cardNumber: String
        let corrAccount: String
        let expireDate: String
        let holderName: String
        let inn: String
        let kpp: String
        let maskCardNumber: String
        let payeeName: String
        
        var data: CardDetails {
            .init(
                accountNumber: accountNumber,
                bic: bic,
                cardNumber: cardNumber,
                corrAccount: corrAccount,
                expireDate: expireDate,
                holderName: holderName,
                inn: inn,
                kpp: kpp,
                maskCardNumber: maskCardNumber,
                payeeName: payeeName)
        }
    }
    
    struct _DepositDetails: Decodable {
        
        let accountNumber: String
        let bic: String
        let corrAccount: String
        let expireDate: String
        let inn: String
        let kpp: String
        let payeeName: String
        
        var data: DepositDetails {
            .init(
                accountNumber: accountNumber,
                bic: bic,
                corrAccount: corrAccount,
                expireDate: expireDate,
                inn: inn,
                kpp: kpp,
                payeeName: payeeName
            )
        }
    }
}
