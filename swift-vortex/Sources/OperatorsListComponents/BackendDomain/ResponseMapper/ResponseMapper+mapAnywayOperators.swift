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
        
        let operators = data.sberOperators
        print("network", "sberOperators count", operators.count)
        
        return operators
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

private extension ResponseMapper.AnywayOperatorGroupData {
    
    var sberOperators: [SberOperator] {
        
        operatorList.flatMap(\.sberOperators)
    }
}

private extension ResponseMapper.AnywayOperatorGroupData.Operator {
    
    var sberOperators: [SberOperator] {
        
        atributeList.compactMap { $0.sberOperator(type: type) }
    }
}

private extension ResponseMapper.AnywayOperatorGroupData.Operator.OperatorData {
    
    func sberOperator(
        type: String
    ) -> SberOperator? {
        
        guard let id = customerId,
              !id.isEmpty,
              let inn = inn,
              !inn.isEmpty,
              let title = juridicalName,
              !title.isEmpty
        else { return nil }
        
        return .init(
            id: id,
            inn: inn,
            md5Hash: md5hash,
            title: title,
            type: type
        )
    }
}
