//
//  ResponseMapper+mapGetProductDetailsResponse.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation
import RemoteServices

public typealias GetProductDetailsResponseMapper = RemoteServices.ResponseMapper

public typealias GetProductDetailsMappingError = RemoteServices.ResponseMapper.MappingError

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
        
        return details.data
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let details: _Details
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.singleValueContainer()
            
            if let cardValue = try? container.decode(_CardDetails.self) {
                
                self.details = .cardDetails(cardValue)
                return
            }
            if let depositValue = try? container.decode(_DepositDetails.self) {
                
                self.details = .depositDetails(depositValue)
                return
            }
            
            let value = try container.decode(_AccountDetails.self)
            
            self.details = .accountDetails(value)
        }
    }
    
    enum _Details: Decodable {
        
        case accountDetails(_AccountDetails)
        case cardDetails(_CardDetails)
        case depositDetails(_DepositDetails)
        
        var data: ProductDetails {
            
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
        
        let accountNumber: String?
        let bic: String?
        let cardNumber: String
        let corrAccount: String?
        let expireDate: String
        let holderName: String
        let inn: String?
        let kpp: String?
        let maskCardNumber: String
        let payeeName: String?
        let info: String?
        let md5hash: String?
        
        var data: CardDetails {
            .init(
                accountNumber: accountNumber ?? "",
                bic: bic ?? "",
                cardNumber: cardNumber,
                corrAccount: corrAccount ?? "",
                expireDate: expireDate,
                holderName: holderName,
                inn: inn ?? "",
                kpp: kpp ?? "",
                maskCardNumber: maskCardNumber,
                payeeName: payeeName ?? "",
                info: info ?? "",
                md5hash: md5hash ?? ""
            )
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
