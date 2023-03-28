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
    
    struct OperatorData: Codable, Equatable, Hashable {
        
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
    
    var id: Int {
        
        return hashValue
    }
}

extension OperatorGroupData.OperatorData {
    
    static func == (lhs: OperatorGroupData.OperatorData, rhs: OperatorGroupData.OperatorData) -> Bool {
        
        lhs.name == rhs.name && lhs.city == rhs.city && lhs.code == rhs.code && lhs.isGroup == rhs.isGroup && lhs.parentCode == rhs.parentCode && lhs.region == rhs.region
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(name)
        hasher.combine(city)
        hasher.combine(code)
        hasher.combine(isGroup)
        hasher.combine(parentCode)
        hasher.combine(region)
    }
}
