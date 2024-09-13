//
//  ResponseMapper+mapGetOperatorsListByParamOperatorOnlyTrueResponseTests.swift
//
//
//  Created by Igor Malyarov on 13.09.2024.
//

import OperatorsListBackendV0
import RemoteServices
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
