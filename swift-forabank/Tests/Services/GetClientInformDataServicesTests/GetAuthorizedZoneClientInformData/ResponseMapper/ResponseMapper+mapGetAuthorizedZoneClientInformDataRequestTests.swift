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
    
        XCTAssertNoDiff(
            map(.empty),
            .failure(.invalid(statusCode: 200, data: .empty))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {

        XCTAssertNoDiff(
            map(.invalidData),
            .failure(.invalid(statusCode: 200, data: .invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {

        XCTAssertNoDiff(
            map(.emptyJSON),
            .failure(.invalid(statusCode: 200, data: .emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {

        XCTAssertNoDiff(
            map(.emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: .emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {

        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: .nullServerResponse))
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

        XCTAssertNoDiff(
            map(.emptyListResponse),
            .failure(.invalid(statusCode: 200, data: .emptyListResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureWithNoSerial() {
       
        XCTAssertNoDiff(
            map(.nullSerialResponse),
            .failure(.invalid(statusCode: 200, data: .nullSerialResponse))
        )
    }

    func test_map_shouldDeliverInvalidFailureWithNoAuthorizedList() {
        
        XCTAssertNoDiff(
            map(.nullAuthorizedListResponse),
            .failure(.invalid(statusCode: 200, data: .nullAuthorizedListResponse))
        )
    }

    func test_map_withNilCategory_shouldOmitItem() throws {
        
        let mapped = try mapResult(.withNilCategory)
        
        XCTAssert(mapped.list.isEmpty)
    }

    func test_map_withNilTitle_shouldOmitItem() throws {
        
        let mapped = try mapResult(.withNilTitle)
        
        XCTAssert(mapped.list.isEmpty)
    }
    
    func test_map_withNilImage_shouldOmitItem() throws {
        
        let mapped = try mapResult(.withNilImage)
        
        XCTAssert(mapped.list.isEmpty)
    }

    func test_map_withNilText_shouldOmitItem() throws {
        
        let mapped = try mapResult(.withNilText)
        
        XCTAssert(mapped.list.isEmpty)
    }

    func test_map_withEmptyCategory_shouldDeliverValidCategory() throws {
        
        let mapped = try mapResult(.withEmptyCategory)
        
        XCTAssertNoDiff(mapped.list.first?.category, "")
    }

    func test_map_withEmptyTitle_shouldDeliverValidTitle() throws {
        
        let mapped = try mapResult(.withEmptyTitle)
        
        XCTAssertNoDiff(mapped.list.first?.title, "")
    }

    func test_map_withEmptyImage_shouldDeliverValidImage() throws {
        
        let mapped = try mapResult(.withEmptyImage)
        
        XCTAssertNoDiff(mapped.list.first?.svgImage, "")
    }
    
    func test_map_withEmptyText_shouldDeliverValidText() throws {
        
        let mapped = try mapResult(.withEmptyText)
        
        XCTAssertNoDiff(mapped.list.first?.text, "")
    }

    func test_map_shouldOmitItemWithNilCategory() throws {
        
        let mapped = try mapResult(.withNilCategoryInOne)
        
        XCTAssertNoDiff(mapped.list.first?.category, "CATEGORY")
    }
    
    func test_map_shouldOmitItemWithNilTitle() throws {
        
        let mapped = try mapResult(.withNilTitleInOne)
        
        XCTAssertNoDiff(mapped.list.first?.title, "TITLE")
    }
    
    func test_map_shouldOmitItemWithNilImage() throws {
        
        let mapped = try mapResult(.withNilImageInOne)
        
        XCTAssertNoDiff(mapped.list.first?.svgImage, "SVG")
    }
    
    func test_map_shouldOmitItemWithNilText() throws {
        
        let mapped = try mapResult(.withNilTextInOne)
        
        XCTAssertNoDiff(mapped.list.first?.text, "TEXT")
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
    
    private func mapResult(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) throws -> Response {

        try ResponseMapper.mapGetAuthorizedZoneClientInformDataResponse(data, httpURLResponse).get()
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
                svgImage: "svg",
                text: "С 01:00 по 03:00 11.11.2023 возможны технические работы. Задержки с переводами за границу"
            ),
            .init(
                category: "Информационные",
                title: "Приятного аппетита",
                svgImage: "svg",
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
    static let nullSerialResponse: Data = String.nullSerialResponse.json
    static let nullAuthorizedListResponse: Data = String.nullAuthorizedListResponse.json
    static let serverError: Data = String.serverError.json
    static let authorized: Data = String.authorized.json
    static let withNilCategory: Data = String.withNilCategory.json
    static let withNilTitle: Data = String.withNilTitle.json
    static let withNilImage: Data = String.withNilImage.json
    static let withNilText: Data = String.withNilText.json
    static let withEmptyCategory: Data = String.withEmptyCategory.json
    static let withEmptyTitle: Data = String.withEmptyTitle.json
    static let withEmptyImage: Data = String.withEmptyImage.json
    static let withEmptyText: Data = String.withEmptyText.json
    static let withNilCategoryInOne: Data = String.withNilCategoryInOne.json
    static let withNilTitleInOne: Data = String.withNilTitleInOne.json
    static let withNilImageInOne: Data = String.withNilImageInOne.json
    static let withNilTextInOne: Data = String.withNilTextInOne.json
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

    static let nullSerialResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": null,
        "authorized": []
    }
}
"""

    static let nullAuthorizedListResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "authorized": null
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
    
    static let withNilCategory = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": null,
        "title": "TITLE",
        "svg_image": "SVG",
        "text": "TEXT"
      }
    ]
  }
}
"""
    
    static let withNilTitle = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "CATEGORY",
        "title": null,
        "svg_image": "SVG",
        "text": "TEXT"
      }
    ]
  }
}
"""
    static let withNilImage = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": null,
        "text": "TEXT"
      }
    ]
  }
}
"""

    static let withNilText = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": "SVG",
        "text": null
      }
    ]
  }
}
"""
    
    static let withEmptyCategory = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "",
        "title": "TITLE",
        "svg_image": "SVG",
        "text": "TEXT"
      }
    ]
  }
}
"""

    static let withEmptyTitle = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "CATEGORY",
        "title": "",
        "svg_image": "SVG",
        "text": "TEXT"
      }
    ]
  }
}
"""
    
    static let withEmptyImage = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": "",
        "text": "TEXT"
      }
    ]
  }
}
"""
    
    static let withEmptyText = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": "SVG",
        "text": ""
      }
    ]
  }
}
"""
    
    static let withNilCategoryInOne = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": null,
        "title": "TITLE",
        "svg_image": "SVG",
        "text": "TEXT"
      },
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": "SVG",
        "text": "TEXT"
      }
    ]
  }
}
"""

    static let withNilTitleInOne = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "CATEGORY",
        "title": null,
        "svg_image": "SVG",
        "text": "TEXT"
      },
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": "SVG",
        "text": "TEXT"
      }
    ]
  }
}
"""
    
    static let withNilImageInOne = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": null,
        "text": "TEXT"
      },
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": "SVG",
        "text": "TEXT"
      }
    ]
  }
}
"""
    
    static let withNilTextInOne = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "authorized": [
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": "SVG",
        "text": null
      },
      {
        "category": "CATEGORY",
        "title": "TITLE",
        "svg_image": "SVG",
        "text": "TEXT"
      }
    ]
  }
}
"""
}
