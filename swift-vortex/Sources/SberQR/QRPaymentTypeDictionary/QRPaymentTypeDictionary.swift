//
//  QRPaymentTypeDictionary.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

public struct QRPaymentTypeDictionary {
    
    let serial: String
    private let dict: Dictionary<String, String>
    
    init(
        serial: String,
        dict: Dictionary<String, String>
    ) {
        self.serial = serial
        self.dict = dict
    }
}
 
public extension QRPaymentTypeDictionary {
    
    func isSberQR(_ key: String) -> Bool {
        
        dict[key, default: ""] == "SBERQR"
    }
    
    func isSberQR(_ url: URL) -> Bool {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let key = components.host
        else { return false }
        
        return isSberQR(key)
    }
}

public extension ResponseMapper {
    
    static func mapQRPaymentTypeJSON(data: Data) throws -> QRPaymentTypeDictionary {
        
        #warning("happy path only")
        let response = try JSONDecoder().decode(Response.self, from: data)
        
        return response.qrPaymentTypeDictionary
    }
    
    private struct Response: Decodable {
        
        let statusCode: Int
        let data: _Data
        
        struct _Data: Decodable {
            
            let serial: String
            let list: [Pair]
            
            struct Pair: Decodable {
                
                let content: String
                let paymentType: String
            }
        }
        
        var qrPaymentTypeDictionary: QRPaymentTypeDictionary {
            
            let pairs = data.list.map { ($0.content, $0.paymentType) }
            let dict = Dictionary(uniqueKeysWithValues: pairs)
            
            return .init(
                serial: data.serial,
                dict: dict
            )
        }
    }
}

