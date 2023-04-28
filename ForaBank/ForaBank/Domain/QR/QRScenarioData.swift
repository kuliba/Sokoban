//
//  QRScenarioData.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation

struct QRScenarioData: Equatable {
    
    let scenario: Scenario
    let qrcId: String
    //FIXME: refactor to [any QRScenarioParameter] after switch to Xcode 14+
    let parameters: [AnyQRScenarioParameter]
    let required: [String]
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
        
        var parametersContainer = try container.nestedUnkeyedContainer(forKey: .parameters)
        var parameters = [AnyQRScenarioParameter]()
        
        while parametersContainer.isAtEnd == false {
            
            if let subscriber = try? parametersContainer.decode(QRScenarioParameterSubscriber.self) {
                
                parameters.append(.init(subscriber))
                
            } else if let productSelect = try? parametersContainer.decode(QRScenarioParameterProductSelect.self) {
                
                parameters.append(.init(productSelect))
                
            } else if let check = try? parametersContainer.decode(QRScenarioParameterCheck.self) {
                
                parameters.append(.init(check))
                
            } else {
                
                throw DecodingError.dataCorruptedError(in: parametersContainer, debugDescription: "Unknown parameter type")
            }
        }
        
        self.scenario = try container.decode(Scenario.self, forKey: .scenario)
        self.qrcId = try container.decode(String.self, forKey: .qrcId)
        self.parameters = parameters
        self.required = try container.decode([String].self, forKey: .required)
    }
}
