//
//  RequestFactory+stickerPayment.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.10.2023.
//

import Foundation

extension RequestFactory {
    
    static func stickerPaymentStep(
        _ serial: (String),
        type: StickerOrderType.RawValue
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("serial", serial),
            ("type", type)
        ]
        let endpoint = Services.Endpoint.getStickerPaymentRequest
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
    
    static func stickerCreatePayment(
        _ input: StickerPayment
    ) throws -> URLRequest {

        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createStickerPayment
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = input.json
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}

}
