//
//  ResponseMapper+mapGetSplashScreenTimePeriodsResponseTests.swift
//
//
//  Created by Nikolay Pochekuev on 18.02.2025.
//

import GetSplashScreenServices
import RemoteServices
import XCTest

final class ResponseMapper_mapGetSplashScreenTimePeriodsResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailure_onEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onInvalidData() {
        
        let invalidData: Data = .invalidData
        
        XCTAssertNoDiff(
            map(invalidData),
            .failure(.invalid(statusCode: 200, data: invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyJSON() {
        
        let emptyJSON: Data = .emptyJSON
        
        XCTAssertNoDiff(
            map(emptyJSON),
            .failure(.invalid(statusCode: 200, data: emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyDataResponse() {
        
        let emptyDataResponse: Data = .emptyDataResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onNullServerResponse() {
        
        let nullServerResponse: Data = .nullServerResponse
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerError_onServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
            )
        }
    }
    
    func test_map_shouldDeliverResponse_onValidData() throws {
        
        XCTAssertNoDiff(map(.validData), .success(.init(
            list: [
                .init(
                    timePeriod: "NIGHT",
                    startTime: "00:00",
                    endTime: "03:59"
                ),
                .init(
                    timePeriod: "EVENING",
                    startTime: "18:00",
                    endTime: "23:59"
                ),
                .init(
                    timePeriod: "DAY",
                    startTime: "12:00",
                    endTime: "17:59"
                ),
                .init(
                    timePeriod: "MORNING",
                    startTime: "04:00",
                    endTime: "11:59"
                )
            ],
            serial: "4bc2481fb8b6661e210b85462b954d05"
        )))
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetSplashScreenTimePeriodsResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetSplashScreenTimePeriodsResponse(data, httpURLResponse)
    }
}

private extension ResponseMapper.GetSplashScreenTimePeriodsResponse {
    
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validData: Data = String.validData.json
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
    
    static let validData = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "4bc2481fb8b6661e210b85462b954d05",
    "splashScreenTimePeriods": [
      {
        "timePeriod": "NIGHT",
        "startTime": "00:00",
        "endTime": "03:59"
      },
      {
        "timePeriod": "EVENING",
        "startTime": "18:00",
        "endTime": "23:59"
      },
      {
        "timePeriod": "DAY",
        "startTime": "12:00",
        "endTime": "17:59"
      },
      {
        "timePeriod": "MORNING",
        "startTime": "04:00",
        "endTime": "11:59"
      }
    ]
  }
}
"""
}
