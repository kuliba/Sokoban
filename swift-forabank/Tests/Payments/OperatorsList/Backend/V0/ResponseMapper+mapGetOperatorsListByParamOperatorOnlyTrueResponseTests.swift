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
    
    func test_map_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = "invalid data".data(using: .utf8)!
        
        let result = Self.mapOK(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithOkHTTPURLResponseStatusCode() throws {
        
        let okResponse = anyHTTPURLResponse(statusCode: 200)
        let result = Self.map(jsonWithServerError(), okResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Серверная ошибка при выполнении запроса"
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = Self.map(jsonWithServerError(), nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Серверная ошибка при выполнении запроса"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = Data()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = Self.map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCodeWithBadData() throws {
        
        let badData = Data(jsonStringWithBadData.utf8)
        let statusCode = 400
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = Self.map(badData, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: badData
        )))
    }
    
    func test_map_should_deliverEmptyListOnMissingType() throws {
        
        let json = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "e484a0fa6826200868cb821394efa1ef",
        "operatorList": [
            {
                "type": null,
                "atributeList": []
            }
        ]
    }
}
"""
        let validData = Data(json.utf8)
        let result = Self.mapOK(validData)
        
        assert(result, equals: .success(.init(
            list: [],
            serial: "e484a0fa6826200868cb821394efa1ef"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnOkHTTPURLResponseStatusCodeWithValidData() throws {
        
        let validData = Data(jsonStringWithEmpty.utf8)
        let result = Self.mapOK(validData)
        
        assert(result, equals: .failure(.invalid(statusCode: 200, data: validData)))
    }
    
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
