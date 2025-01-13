//
//  File.swift
//  
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

public extension CreateSberQRPaymentPayload {
    
    var json: Data {
        
        get throws {
            
            var parameters: [[String: String]] = [[
                "id": "QRLink",
                "value": qrLink.absoluteString
            ],[
                "id": productID,
                "value": "\(idValue)"
            ]]
            
            let amount: [[String: String]]? = amount.map { [[
                "id": "payment_amount",
                "value": "\($0.amount)"
            ],[
                "id": "currency",
                "value": $0.currency.rawValue
            ]] }
            if let amount { parameters.append(contentsOf: amount) }
            
            return try JSONSerialization.data(withJSONObject: [
                "parameters": parameters
            ] as [String: [[String: String]]])
        }
    }
    
    private var productID: String {
        
        switch product {
        case .card:
            return "cardId"
            
        case .account:
            return "accountId"
        }
    }
    
    private var idValue: Int {
        
        switch product {
        case let .card(cardID):
            return cardID.rawValue
            
        case let .account(accountID):
            return accountID.rawValue
        }
    }
}
