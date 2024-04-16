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
    ) -> MappingResult<[_OperatorGroup]?> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: AnywayOperatorGroupData
    ) throws -> [_OperatorGroup]? {
        
        data.operatorList.compactMap({ $0 }).first?.atributeList.map({
            _OperatorGroup(
                md5hash: $0.md5hash ?? "",
                title: $0.juridicalName ?? "",
                description: "ИНН \($0.inn ?? "")"
            ) })
    }
}

private extension ResponseMapper {
    
    struct AnywayOperatorGroupData: Decodable {
        
        let operatorList: [OperatorGroupData]
        let serial: String
        
        struct OperatorGroupData: Decodable {
            
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
