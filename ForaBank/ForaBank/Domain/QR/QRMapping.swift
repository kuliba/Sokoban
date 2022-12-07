//
//  QRMapping.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.10.2022.
//

import Foundation

struct QRMapping: Codable, Equatable {
    
    let parameters: [QRParameter]
    let operators: [QROperator]    
}

extension QRMapping {
    
    var allParameters: [QRParameter] {
        
        var param = parameters
        
        operators.forEach { qrParameter in
            
            param.append(contentsOf: qrParameter.parameters)
        }

        return parameters
    }
    
    enum CodingKeys: String, CodingKey {

        case parameters = "general"
        case operators
    }
}

extension QRMapping {
    
    struct FailData {
        
        let rawData: String
        let parsed: [String: String]
        let unknownKeys: [String]
    }
}
