//
//  ResponseMapper+mapGetSavingLandingRequestTests.swift
//
//
//  Created by Andryusina Nataly on 22.11.2024.
//

import SavingsServices
import RemoteServices
import XCTest

final class ResponseMapper_mapGetSavingLandingRequestTests: XCTestCase {
    
    func test_map_shouldDeliverValidOnValidProducts() {
        
        XCTAssertNoDiff(
            map(.validWithAllCases),
            .success(.init(list: [.validWithAllCases], serial: "36")))
    }
    
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
                map(.validWithAllCases, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validWithAllCases))
            )
        }
    }
    
    func test_map_shouldDeliverValidOnEmptyProducts() {
        
        XCTAssertNoDiff(
            map(.emptyProductsResponse),
            .success(.init(list: [], serial: "1"))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureWithNoSerial() {
        
        XCTAssertNoDiff(
            map(.nullSerialResponse),
            .failure(.invalid(statusCode: 200, data: .nullSerialResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureWithNoProducts() {
        
        XCTAssertNoDiff(
            map(.nullProductsResponse),
            .failure(.invalid(statusCode: 200, data: .nullProductsResponse))
        )
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetSavingLandingResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetSavingLandingResponse(data, httpURLResponse)
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyProductsResponse: Data = String.emptyProductsResponse.json
    static let invalidData: Data = String.invalidData.json
    static let nullProductsResponse: Data = String.nullProductsResponse.json
    static let nullSerialResponse: Data = String.nullSerialResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validWithAllCases: Data = String.validWithAllCases.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "products": "junk" }
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
    
    static let emptyProductsResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1",
        "products": []
    }
}
"""
    
    static let nullSerialResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": null,
        "products": []
    }
}
"""
    
    static let nullProductsResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "products": null
    }
}
"""
    
    static let validWithAllCases = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "36",
    "products": [
      {
        "theme": "theme1",
        "name": "name1",
        "marketing": {
          "labelTag": "labelTag1",
          "image": "imageLink1",
          "params": [
            "param1",
            "param2",
            "param3"
          ]
        },
        "advantages": [
          {
            "icon": "md5hash1",
            "title": "title1",
            "subTitle": ""
          },
          {
            "icon": "md5hash2",
            "title": "title2",
            "subTitle": "subtitle2"
          },
          {
            "icon": "md5hash3",
            "title": "title3",
            "subTitle": null
          }
        ],
        "basicConditions": [
          {
            "icon": "md5hash11",
            "title": "title11"
          },
          {
            "icon": "md5hash12",
            "title": null
          },
          {
            "icon": null,
            "title": "title13"
          },
        ],
        "frequentlyAskedQuestions": [
          {
            "question": "question1",
            "answer": "answer1"
          },
          {
            "question": null,
            "answer": "answer2"
          },
          {
            "question": "question3",
            "answer": null
          },
        ]
      }
    ]
  }
}
"""
}

private extension ResponseMapper.GetSavingLandingData {
    
    static let validWithAllCases: Self = .init(
        theme: "theme1",
        name: "name1",
        marketing: .init(
            labelTag: "labelTag1",
            imageLink: "imageLink1",
            params: .params),
        advantages: .advantages,
        basicConditions: .basicConditions,
        questions: .questions)
}

private extension Array where Element == String {
    
    static let params: Self = ["param1", "param2", "param3"]
}

private extension Array where Element == ResponseMapper.GetSavingLandingData.Advantage {
    
    static let advantages: Self = [
        .init(iconMd5hash: "md5hash1", title: "title1", subtitle: ""),
        .init(iconMd5hash: "md5hash2", title: "title2", subtitle: "subtitle2"),
        .init(iconMd5hash: "md5hash3", title: "title3", subtitle: ""),
    ]
}

private extension Array where Element == ResponseMapper.GetSavingLandingData.BasicCondition {
    
    static let basicConditions: Self = [
        .init(iconMd5hash: "md5hash11", title: "title11"),
        .init(iconMd5hash: "md5hash12", title: ""),
        .init(iconMd5hash: "", title: "title13"),
    ]
}

private extension Array where Element == ResponseMapper.GetSavingLandingData.Question {
    
    static let questions: Self = [
        .init(question: "question1", answer: "answer1"),
        .init(question: "", answer: "answer2"),
        .init(question: "question3", answer: ""),
    ]
}
