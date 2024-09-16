//
//  ResponseMapper+mapGetOperatorsListByParamOperatorOnlyTrueResponse.swift
//
//
//  Created by Igor Malyarov on 13.09.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    typealias StampedServicePaymentProviders = SerialStamped<String, ServicePaymentProvider>
    
    static func mapGetOperatorsListByParamOperatorOnlyTrueResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<StampedServicePaymentProviders> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        dto: _DTO
    ) throws -> StampedServicePaymentProviders {
        
        return .init(list: dto.providers, serial: dto.serial)
    }
}

private extension ResponseMapper._DTO {
    
    var providers: [ResponseMapper.ServicePaymentProvider] {
        
        operatorList.flatMap(\.providers)
    }
}

private extension ResponseMapper._DTO._List {
    
    var providers: [ResponseMapper.ServicePaymentProvider] {
        
        guard let operators = atributeList,
              let type = type
        else { return [] }
        
        return operators.compactMap { item in
            
            guard let id = item.customerId,
                  let inn = item.inn,
                  let name = item.juridicalName
            else { return nil }
            
            return .init(id: id, inn: inn, md5Hash: item.md5hash, name: name, type: type)
        }
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let operatorList: [_List]
        let serial: String
    }
}

private extension ResponseMapper._DTO {
    
    struct _List: Decodable {
        
        let type: String?
        let atributeList: [_OperatorDTO]?
    }
}

private extension ResponseMapper._DTO._List {
    
    struct _OperatorDTO: Decodable {
        
        let customerId: String?
        let inn: String?
        let juridicalName: String?
        let md5hash: String?
    }
}
