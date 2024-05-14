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
    ) -> MappingResult<[SberOperator]> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: AnywayOperatorGroupData
    ) throws -> [SberOperator] {
        
        guard let list = data.operatorList.first?.atributeList
        else { return [] }
        
        return list.compactMap {
            
            guard let title = $0.juridicalName else { return nil }
            
            return .init(icon: $0.md5hash, inn: $0.inn, title: title)
        }
    }
}

private extension ResponseMapper {
    
    struct AnywayOperatorGroupData: Decodable {
        
        let operatorList: [Operator]
        let serial: String
        
        struct Operator: Decodable {
            
            let type: String
            let atributeList: [OperatorData]
            
            struct OperatorData: Decodable {
            
                let md5hash: String?
                let juridicalName: String?
                let customerId: String
                let serviceList: [String?]
                let inn: String?
            }
            
            enum Kind: Decodable {
                
                case housingAndCommunalService
            }
        }
    }
}
