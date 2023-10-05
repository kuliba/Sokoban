//
//  RequestFactory+stickerPayment.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.10.2023.
//

import Foundation

extension RequestFactory {
    
    static func stickerPaymentRequest(
        _ serial: (String)
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("serial", serial),
            ("type", "abroadSticker")
        ]
        let endpoint = Services.Endpoint.getStickerPaymentRequest
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
}
