//
//  AnywayOperatorGroup.swift
//
//
//  Created by Дмитрий Савушкин on 14.02.2024.
//

import Foundation

struct OperatorGroup {
    
    let city: String?
    let code: String
    let isGroup: Bool
    let logotypeList: [LogotypeData]
    let name: String
    let operators: [OperatorData]
    let region: String?
    let synonymList: [String]
}

extension OperatorGroup {
    
    struct Operator {
        
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
    
    struct LogotypeData {
        
        let content: String?
        let contentType: String?
        let name: String?
        let svgImage: SVGImageData?
        
        var iconData: ImageData? {
            
            guard let svgImage = svgImage else {
                return nil
            }
            
            return ImageData(with: svgImage)
        }
    }
}

extension OperatorGroupData.OperatorData {
    
    var title: String { name }
    
    var description: String? { synonymList.first }
    
    var iconImageData: ImageData? {
        
        guard let logotypeData = logotypeList.first, let logotypeSVGImage = logotypeData.svgImage else {
            return nil
        }
        
        return ImageData(with: logotypeSVGImage)
    }
}
