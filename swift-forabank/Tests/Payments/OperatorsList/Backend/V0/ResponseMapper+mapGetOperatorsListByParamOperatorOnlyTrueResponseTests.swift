//
//  ResponseMapper+mapGetOperatorsListByParamOperatorOnlyTrueResponseTests.swift
//
//
//  Created by Igor Malyarov on 13.09.2024.
//

import RemoteServices

extension ResponseMapper {
    
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

struct ServicePaymentProvider: Equatable {
    
    let id: String
    let inn: String
    let md5Hash: String?
    let name: String
    let type: String
}

private extension ResponseMapper._DTO {
    
    var providers: [ServicePaymentProvider] {
        
        operatorList.flatMap(\.providers)
    }
}

private extension ResponseMapper._DTO._List {
    
    var providers: [ServicePaymentProvider] {
        
        guard let operators = atributeList,
              let type = type
        else { return [] }
        
        return operators.compactMap { (item) -> ServicePaymentProvider? in
            
            guard let id = item.customerId,
                  let inn = item.inn,
                  let name = item.juridicalName
            else { return nil }
            
            return ServicePaymentProvider(id: id, inn: inn, md5Hash: item.md5hash, name: name, type: type)
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

import OperatorsListBackendV0
import XCTest

final class ResponseMapper_mapGetOperatorsListByParamOperatorOnlyTrueResponseTests: XCTestCase {
    
    func test_fromFile() throws {
        
        let data = try data(from: "getOperatorsListByParam")
        let response = try Self.mapOK(data).get()
        
        XCTAssertNoDiff(response.serial, "e484a0fa6826200868cb821394efa1ef")
        XCTAssertNoDiff(response.list, [
            .init(
                id: "17651",
                inn: "3704561992",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ООО  ИЛЬИНСКОЕ ЖКХ",
                type: "housingAndCommunalService"
            ),
            .init(
                id: "21121",
                inn: "4217039402",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ООО МЕТАЛЛЭНЕРГОФИНАНС",
                type: "housingAndCommunalService"
            ),
            .init(
                id: "12604",
                inn: "1657251193",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ТОВАРИЩЕСТВО СОБСТВЕННИКОВ НЕДВИЖИМОСТИ ЧИСТОПОЛЬСКАЯ 61 А",
                type: "housingAndCommunalService"
            ),
            .init(
                id: "16399",
                inn: "7725412685",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ООО СЕРВИССТРОЙЭКСПЛУАТАЦИЯ",
                type: "housingAndCommunalService"
            ),
            .init(
                id: "5823",
                inn: "7729398632",
                md5Hash: "1efeda3c9130101d4d88113853b03bb5",
                name: "ТСЖ ОЛИМП",
                type: "housingAndCommunalService"
            )
        ])
    }
    
    // MARK: - Helpers
    
    private static let map = ResponseMapper.mapGetOperatorsListByParamOperatorOnlyTrueResponse
    
    private static let mapOK = { data in
        
        map(data, anyHTTPURLResponse())
    }
    
    private func data(
        from filename: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let filename = Bundle.module.url(forResource: filename, withExtension: "json")
        let url = try XCTUnwrap(filename, file: file, line: line)
        return try Data(contentsOf: url)
    }
}
