//
//  RequestFactory+stickerPayment.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.10.2023.
//

import Foundation

extension RequestFactory {
    
    static func getStickerDictionary(
        _ type: GetJsonAbroadType
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("serial", "1"),
            ("type", type.rawValue)
        ]
        let endpoint = Services.Endpoint.getStickerPaymentRequest
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
    
    static func createCommissionProductTransfer(
        _ input: StickerPayment
    ) throws -> URLRequest {

        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.createCommissionProductTransfer
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = input.json
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return request
    }
    
    static func makeTransfer(
        _ verificationCode: String
    ) throws -> URLRequest {

        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.makeTransfer
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["verificationCode": verificationCode] as [String: Any])
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return request
    }
}

extension RequestFactory {

    enum GetJsonAbroadType: String {
        
        case stickerOrderForm
        case stickerOrderDeliveryOffice
        case stickerOrderDeliveryCourier
    }
    
    struct StickerPayment {
        
        let currencyAmount: String
        let amount: Double
        let check: Bool
        let payer: Payer
        let productToOrderInfo: Order
        
        struct Payer {
            
            let cardId: String
        }
        
        struct Order {
            
            let type: String
            let deliverToOffice: Bool
            let officeId: String
        }
    }
}

private extension RequestFactory.StickerPayment {
    
    var json: Data? {
        
        try? JSONSerialization.data(withJSONObject: [
            "currencyAmount": currencyAmount,
            "amount": amount,
            "check": check,
            "payer": [
                
                "cardId": payer.cardId
            ],
            "productToOrderInfo": [
                
                "type": productToOrderInfo.type,
                "deliverToOffice": productToOrderInfo.deliverToOffice,
                "officeId": productToOrderInfo.officeId
            ] as [String : Any]
        ] as [String: Any])
    }
}
