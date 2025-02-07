//
//  ResponseMapper+mapGetCardOrderFormResponse.swift
//
//
//  Created by Дмитрий Савушкин on 11.12.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetCardOrderFormResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetCardOrderFormDataResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetCardOrderFormDataResponse.init)
    }
}

private extension ResponseMapper.GetCardOrderFormDataResponse {
    
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

private extension ResponseMapper.GetCardOrderFormData {
    
    init?(_ data: ResponseMapper._Data._Product) {
        
        guard
            let conditionsLink = data.conditionsLink,
            let currency = data.currency,
            let description = data.description,
            let design = data.design,
            let fee = data.fee,
            let hint = data.hint,
            let income = data.income,
            let productId = data.id,
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
            income: income,
            productId: productId,
            tariffLink: tariffLink,
            title: title
        )
    }
}

private extension ResponseMapper.GetCardOrderFormData.Currency {
    
    init(_ data: ResponseMapper._Data._Currency) {
        
        self.init(
            code: data.code ?? 0,
            symbol: data.symbol ?? ""
        )
    }
}

private extension ResponseMapper.GetCardOrderFormData.Fee {
    
    init(_ data: ResponseMapper._Data._Fee) {
        
        self.init(
            maintenance: .init(
                data.maintenance ?? .init(
                    period: nil,
                    value: nil
                )
            ),
            open: data.open ?? 0
        )
    }
}

private extension ResponseMapper.GetCardOrderFormData.Maintenance {
    
    init(_ data: ResponseMapper._Data._Maintenance) {
        
        self.init(period: data.period ?? "", value: data.value ?? 0)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String?
        let products: [_Product]?
        
        struct _Product: Decodable {
            
            let conditionsLink: String?
            let currency: _Currency?
            let description: String?
            let design: String?
            let fee: _Fee?
            let id: Int?
            let income: String?
            let tariffLink: String?
            let title: String?
           let hint: String?
        }
        
        struct _Currency: Decodable {
            
            let code: Int?
            let symbol: String?
        }
        
        struct _Fee: Decodable {
            
            let maintenance: _Maintenance?
            let open: Int?
        }
        
        struct _Maintenance: Decodable {
            
            let period: String?
            let value: Int?
        }
    }
}
