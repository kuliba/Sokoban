//
//  ResponseMapper+mapGetOpenAccountFormResponse.swift
//
//
//  Created by Andryusina Nataly on 22.11.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetOpenAccountFormResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetOpenAccountFormResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetOpenAccountFormResponse.init)
    }
}

private extension ResponseMapper.GetOpenAccountFormResponse {
    
    init(_ data: ResponseMapper._Data) throws {
        
        guard let serial = data.serial, let products = data.products
        else {
            throw ResponseFailure()
        }
        
        self.init(
            list: products.compactMap { .init($0) },
            serial: serial
        )
    }
    
    struct ResponseFailure: Error {}
}

private extension ResponseMapper.GetOpenAccountFormData {
    
    init?(_ data: ResponseMapper._Data._Product) {
        
        guard let conditionsLink = data.conditionsLink,
              let currency = data.currency,
              let description = data.description,
              let design = data.design,
              let fee = data.fee,
              let hint = data.hint,
              let productId = data.id,
              let income = data.income,
              let tariffLink = data.tariffLink,
              let title = data.title
        else { return nil }
        
        self.init(
            conditionsLink: conditionsLink,
            currency: .init(currency),
            description: description,
            design: design,
            fee: .init(fee),
            hint: hint,
            productId: productId,
            income: income,
            tariffLink: tariffLink,
            title: title)
    }
}

private extension ResponseMapper.GetOpenAccountFormData.Currency {
    
    init(_ data: ResponseMapper._Data._Currency) {
        
        self.init(code: data.code ?? 0, symbol: data.symbol ?? "")
    }
}

private extension ResponseMapper.GetOpenAccountFormData.Fee {
    
    init(_ data: ResponseMapper._Data._Fee) {
        
        self.init(openAndMaintenance: data.openAndMaintenance ?? 0, subscription: .init(data.subscription ?? .init(period: nil, value: nil)))
    }
}

private extension ResponseMapper.GetOpenAccountFormData.Subscription {
    
    init(_ data: ResponseMapper._Data._Subscription) {
        
        self.init(period: data.period ?? "", value: data.value ?? 0)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String?
        let products: [_Product]?
        
        struct _Product: Decodable {
            
            let hint: String?
            let id: Int?
            let title: String?
            let description: String?
            let design: String?
            let currency: _Currency?
            let fee: _Fee?
            let income: String?
            let conditionsLink: String?
            let tariffLink: String?
        }
        
        struct _Currency: Decodable {
            
            let code: Int?
            let symbol: String?
        }
        
        struct _Fee: Decodable {
            
            let openAndMaintenance: Int?
            let subscription: _Subscription?
        }
        
        struct _Subscription: Decodable {
            
            let period: String?
            let value: Int?
        }
    }
}
