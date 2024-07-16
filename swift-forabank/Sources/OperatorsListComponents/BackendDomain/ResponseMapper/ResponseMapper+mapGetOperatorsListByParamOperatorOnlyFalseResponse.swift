//
//  ResponseMapper+mapGetOperatorsListByParamOperatorOnlyFalseResponse.swift
//
//
//  Created by Дмитрий Савушкин on 14.02.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetOperatorsListByParamOperatorOnlyFalseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<[SberUtilityService]> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    struct SberUtilityService: Equatable {
        
        public let name: String
        public let puref: String
    }
    
    private static func map(
        _ data: _DTO
    ) throws -> [SberUtilityService] {
        
        guard let services = data.operatorList.first?.atributeList.first?.serviceList
        else { return [] }
        
        return services.compactMap {
            
            guard let channel = $0.channel,
                  let `protocol` = $0.`protocol`,
                  let name = $0.descr
            else { return nil }
            
            return .init(name: name, puref: "\(channel)||\(`protocol`)")
        }
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let operatorList: [_OperatorDTO]
        let serial: String
        
        struct _OperatorDTO: Decodable {
            
            let atributeList: [_AttributeDTO]
            
            struct _AttributeDTO: Decodable {
                
                let serviceList: [_ServiceDTO]?
            }
            
            struct _ServiceDTO: Decodable {
                
                let channel: String?
                let `protocol`: String?
                let descr: String?
            }
        }
    }
}
