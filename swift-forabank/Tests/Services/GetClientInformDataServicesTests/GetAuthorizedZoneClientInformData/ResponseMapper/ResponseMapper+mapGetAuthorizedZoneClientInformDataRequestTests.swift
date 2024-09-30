//
//  ResponseMapper+mapGetServiceCategoryListResponseTests.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 30.09.2024.
//

import GetClientInformDataServices
import RemoteServices
import XCTest

final class ResponseMapper_mapGetAuthorizedZoneClientInformDataRequestTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {
        
        let invalidData: Data = .invalidData
        
        XCTAssertNoDiff(
            map(invalidData),
            .failure(.invalid(statusCode: 200, data: invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        let emptyJSON: Data = .emptyJSON
        
        XCTAssertNoDiff(
            map(emptyJSON),
            .failure(.invalid(statusCode: 200, data: emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        let emptyDataResponse: Data = .emptyDataResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        let nullServerResponse: Data = .nullServerResponse
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerErrorOnServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.authorized, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .authorized))
            )
        }
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyList() {
        
        let emptyDataResponse: Data = .emptyListResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverResponseWithAuthorized() throws {
        
        try assert(.authorized, .authorized)
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetAuthorizedZoneClientInformDataResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetAuthorizedZoneClientInformDataResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ data: Data,
        _ response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let receivedResponse = try map(data).get()
        XCTAssertNoDiff(receivedResponse, response, file: file, line: line)
    }
}

private extension ResponseMapper.GetAuthorizedZoneClientInformDataResponse {
    
    static let authorized: Self = .init(
        list: [
            .init(
                category: "Техннические работы",
                title: "Перерыв на обед",
                svg_image: "svg",
                text: "С 01:00 по 03:00 11.11.2023 возможны технические работы. Задержки с переводами за границу"
            ),
            .init(
                category: "Информационные",
                title: "Приятного аппетита",
                svg_image: "svg",
                text: "Специальное предложение для тех кто любит поострей. Вклад в аргентинских песо - 300% годовых. Открыть https://link_click."
            )
        ],
        serial: "1bebd140bc2660211fbba306105479ae"
    )
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let authorized: Data = String.authorized.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
    static let emptyList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "categoryGroupList": []
  }
}
"""
    
    static let authorized = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "Техннические работы",
        "title": "Перерыв на обед",
        "svg_image": "svg",
        "text": "С 01:00 по 03:00 11.11.2023 возможны технические работы. Задержки с переводами за границу"
      },
      {
        "category": "Информационные",
        "title": "Приятного аппетита",
        "svg_image": "svg",
        "text": "Специальное предложение для тех кто любит поострей. Вклад в аргентинских песо - 300% годовых. Открыть https://link_click."
      }
    ]
  }
}
"""
}
