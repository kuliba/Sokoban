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
            let tariffLink = data.tariffLink,
            let list = data.list?.compactMap({ Item($0) })
        else { return nil }
        
        self.init(
            conditionsLink: conditionsLink,
            tariffLink: tariffLink,
            list: list
        )
    }
}


private extension ResponseMapper.GetCardOrderFormData.Item {
    
    init?(_ data: ResponseMapper._Data._Product._Item) {
        
        guard
            let type = data.type,
            let typeText = data.typeText,
            let id = data.id,
            let title = data.title,
            let description = data.description,
            let design = data.design,
            let currency = data.currency.flatMap(Currency.init),
            let fee = data.fee.flatMap(Fee.init)
        else { return nil }
        
        self.init(
            type: type,
            typeText: typeText,
            id: id,
            title: title,
            description: description,
            design: design,
            currency: currency,
            fee: fee
        )
    }
}

private extension ResponseMapper.GetCardOrderFormData.Item.Currency {
    
    init?(_ data: ResponseMapper._Data._Product._Item._Currency) {
        
        guard let code = data.code,
              let symbol = data.symbol
        else { return nil }
        
        self.init(
            code: code,
            symbol: symbol
        )
    }
}

private extension ResponseMapper.GetCardOrderFormData.Item.Fee {
    
    init?(_ data: ResponseMapper._Data._Product._Item._Fee) {
        
        guard
            let maintenance = data.maintenance.flatMap(Maintenance.init),
            let open = data.open
        else { return nil }
        
        self.init(
            maintenance: maintenance,
            open: open
        )
    }
}

private extension ResponseMapper.GetCardOrderFormData.Item.Fee.Maintenance {
    
    init?(_ data: ResponseMapper._Data._Product._Item._Fee._Maintenance) {
        
        guard
            let period = data.period,
            let value = data.value
        else { return nil }
        
        self.init(
            period: period,
            value: value
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String?
        let products: [_Product]?
        
        struct _Product: Decodable {
            
            let conditionsLink: String?
            let tariffLink: String?
            let list: [_Item]?
            
            struct _Item: Decodable {
                
                let type: String?
                let typeText: String?
                let id: String?
                let title: String?
                let description: String?
                let design: String?
                let currency: _Currency?
                let fee: _Fee?
                
                struct _Currency: Decodable {
                    
                    let code: String?
                    let symbol: String?
                }
                
                struct _Fee: Decodable {
                    
                    let maintenance: _Maintenance?
                    let open: String?
                    
                    struct _Maintenance: Decodable {
                        
                        let period: String?
                        let value: Int?
                    }
                }
            }
        }
    }
}
