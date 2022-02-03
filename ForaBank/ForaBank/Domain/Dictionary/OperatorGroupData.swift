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
    let logotypeList: [LogotypeDataItem]
    let name: String
    let operators: [OperatorData]
    let region: String?
    let synonymList: [String]
 
    //FIXME: rename to LogotypeData after refactoring
    struct LogotypeDataItem: Codable, Equatable {
        
        let content: String
        let contentType: String
        let name: String
        let svgImage: SVGImageData
    }
    
    struct OperatorData: Codable, Equatable {
        
        let city: String?
        let code: String
        let isGroup: Bool
        let logotypeList: [LogotypeDataItem]
        let name: String
        let parameterList: [ParameterData]
        let parentCode: String
        let region: String?
        let synonymList: [String]
    }
}
