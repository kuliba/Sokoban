//
//  ResponseMapper+mapAnywayOperators.swift
//
//
//  Created by Дмитрий Савушкин on 14.02.2024.
//

import Foundation

public extension ResponseMapper {
    
    static func mapAnywayOperatorsListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<[OperatorGroup]?> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: AnywayOperatorGroup
    ) throws -> [OperatorGroup]? {
        
        data.operatorGroupList
    }
}

private extension ResponseMapper.AnywayOperatorGroup {
    
    var data: AnywayOperatorGroupData? {
        
        return .init(
    }
}

private extension ResponseMapper {
    
    struct AnywayOperatorGroupData: Decodable {
        
        let operatorGroupList: [OperatorGroupData]
        let serial: String
        
        struct OperatorGroupData: Decodable {
            
            let city: String?
            let code: String
            let isGroup: Bool
            let logotypeList: [LogotypeData]
            let name: String
            let operators: [OperatorData]
            let region: String?
            let synonymList: [String]
        }
    }
}

private extension OperatorGroupData {
    
    struct OperatorData: Decodable {
        
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

private extension OperatorGroupData.OperatorData {
    
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
