//
//  QRMapping.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.10.2022.
//

import Foundation

struct QRMapping: Equatable {
    
    let parameters: [QRParameter]
    let operators: [QROperator]
    let dateFormats = ["dd.MM.yyyy", "MMyyyy", "ddMMyyyy", "dd/MM/yyyy"]
}

//MARK: - Types

extension QRMapping {
    
    struct FailData: Encodable {
        
        let rawData: String
        let parsed: [ParsedData]
        let unknownKeys: [String]
        
        struct ParsedData: Encodable {
            
            let parameter: QRParameter.Kind
            let key: String
            let value: String
            let type: QRParameter.ValueType
        }
    }
}

//MARK: - Helpers

extension QRMapping {
    
    var allParameters: [QRParameter] {
        
        var result = [QRParameter]()
        result.append(contentsOf: parameters)
        result.append(contentsOf: operators.flatMap({ $0.parameters }))

        return result
    }
}

//MARK: - Codable

extension QRMapping: Codable {
  
    enum CodingKeys: String, CodingKey {

        case parameters = "general"
        case operators
    }
}
