//
//  QRScenarioData.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation

struct QRScenarioData: Equatable {
    
    let qrcId: String
    //FIXME: refactor to [any QRScenarioParameter] after switch to Xcode 14+
    let parameters: [AnyPaymentParameter]
    let required: [String]?
}

//MARK: - Types

extension QRScenarioData {
    
    enum Scenario: String, Decodable, Equatable, Unknownable {
        
        case c2b = "C2B"
        case subscription = "C2B_SUBSCRIPTION"
        case subscriptionWithPayment = "C2B_SUBSCRIPTION_WITH_PAYMENT"
        case unknown
    }
}

//MARK: - Decodable

extension QRScenarioData: Decodable {
    
    enum CodingKeys : String, CodingKey {
        
        case scenario, qrcId, parameters, required
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.qrcId = try container.decode(String.self, forKey: .qrcId)
        self.parameters = try AnyPaymentParameter.decode(container: try container.nestedUnkeyedContainer(forKey: .parameters))
        self.required = try container.decodeIfPresent([String].self, forKey: .required)
    }
}
