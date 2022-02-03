//
//  OperatorGroupData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct OperatorGroupData: Codable, Equatable {
    
    let city: String?
    let code: String
    let isGroup: Bool
    let logotypeList: [LogotypeData]
    let name: String
    let operators: [OperatorData]
    let region: String?
    let synonymList: [String]
}

extension OperatorGroupData {
    
    struct OperatorData: Codable, Equatable {
        
        let city: String?
        let code: String
        let isGroup: Bool
        let logotypeList: [LogotypeData]
        let name: String
        let parameterList: [ParameterData]
        let parentCode: String
        let region: String?
        let synonymList: [String]
    }
    
    struct LogotypeData: Codable, Equatable {
        
        let content: String
        let contentType: String
        let name: String
        let svgImage: SVGImageData
    }
}
