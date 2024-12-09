//
//  PaymentC2BResponseData.swift
//  Vortex
//
//  Created by Max Gribov on 24.03.2023.
//

import Foundation

struct PaymentC2BResponseData: Equatable {
    
    let parameters: [AnyPaymentParameter]
}

//MARK: - Decodable

extension PaymentC2BResponseData: Decodable {
    
    enum CodingKeys : String, CodingKey {
        
        case parameters
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.parameters = try AnyPaymentParameter.decode(container: try container.nestedUnkeyedContainer(forKey: .parameters))
    }
}
