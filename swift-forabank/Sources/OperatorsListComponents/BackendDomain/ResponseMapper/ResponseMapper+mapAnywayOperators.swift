//
//  ResponseMapper+mapAnywayOperators.swift
//
//
//  Created by Дмитрий Савушкин on 14.02.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapAnywayOperatorsListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<[SberOperator]> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: AnywayOperatorGroupData
    ) -> [SberOperator] {
        
        guard let list = data.operatorList.first?.atributeList
        else { return [] }
        
        let operators = list.compactMap(SberOperator.init)
        
        return operators
    }
}

private extension SberOperator {
    
    init?(
        _ `operator`: ResponseMapper.AnywayOperatorGroupData.Operator.OperatorData
    ) {
        guard let id = `operator`.customerId,
              !id.isEmpty,
              let inn = `operator`.inn,
              !inn.isEmpty,
              let title = `operator`.juridicalName,
              !title.isEmpty
        else { return nil }
        
        self.init(id: id, inn: inn, md5Hash: `operator`.md5hash, title: title)
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
                let customerId: String?
                let inn: String?
            }
            
            enum Kind: Decodable {
                
                case housingAndCommunalService
            }
        }
    }
}
