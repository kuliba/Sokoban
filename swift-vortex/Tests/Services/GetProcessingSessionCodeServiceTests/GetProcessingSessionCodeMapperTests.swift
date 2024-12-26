//
//  GetProcessingSessionCodeMapperTests.swift
//  
//
//  Created by Igor Malyarov on 31.07.2023.
//

import GetProcessingSessionCodeService
import XCTest

final class GetProcessingSessionCodeMapperTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidDataErrorOnResponseWithStatusCode200WithInvalidData() throws {
        
        let response200 = anyHTTPURLResponse(with: statusCode200)
        let invalidData = "invalid data".data(using: .utf8)!
        
        let result = mapResponse(invalidData, response200)
        
        XCTAssertNoDiff(
            result,
            .failure(.invalidData(statusCode: statusCode200))
        )
    }
    
    func test_map_shouldDeliverSessionCodeOnValidDataWithStatusCode200() throws {
        
        let (sessionCode, validData) = sessionCode()
        let response200 = anyHTTPURLResponse(with: statusCode200)
        
        let result = mapResponse(validData, response200)
        
        XCTAssertNoDiff(result, .success(sessionCode))
    }
    
    func test_map_shouldDeliverInvalidDataErrorOnResponseWithStatusCode500WithInvalidData() throws {
        
        let response500 = anyHTTPURLResponse(with: statusCode500)
        let invalidData = "invalid data".data(using: .utf8)!
        
        let result = mapResponse(invalidData, response500)
        
        XCTAssertNoDiff(
            result,
            .failure(.invalidData(statusCode: statusCode500))
        )
    }
    
    func test_map_shouldDeliverServerErrorOnResponseWithStatusCode500WithValidData() throws {
        
        let response = anyHTTPURLResponse(with: statusCode500)
        let (serverError, validData) = serverError()
        
        let result = mapResponse(validData, response)
        
        XCTAssertNoDiff(
            result,
            .failure(.serverError(statusCode: serverError.statusCode, errorMessage: serverError.errorMessage))
        )
    }
    
    func test_map_shouldDeliverUnknownStatusCodeErrorOnResponseWithNon200Non500StatusCode() throws {
        
        let non200Non500StatusCodes = [199, 201, 300, 499, 501]
        let anyData = Data()
        
        non200Non500StatusCodes.forEach { statusCode in
            
            let response = anyHTTPURLResponse(with: statusCode)
            
            let result = mapResponse(anyData, response)
            
            XCTAssertNoDiff(
                result,
                .failure(.unknownStatusCode(statusCode))
            )
            
        }
    }
    
    // MARK: - Helpers
    
    private let mapResponse = GetProcessingSessionCodeMapper.mapResponse
    private let statusCode200 = 200
    private let statusCode500 = 500
    
    private func sessionCode(
        code: String = "22345200-abe8-4f60-90c8-0d43c5f6c0f6",
        phone: String = "71234567890"
    ) -> (
        sessionCode: SessionCodeDomain.GetProcessingSessionCode,
        data: Data
    ) {
        
        let json: [String: Any] = [
            "code": code,
            "phone": phone
        ]
        
        let sessionCode = SessionCodeDomain.GetProcessingSessionCode(code: code, phone: phone)
        let data = try! JSONSerialization.data(withJSONObject: json)
        
        return (sessionCode, data)
    }
    
    private func serverError(
        statusCode: Int = 3100,
        errorMessage: String = "Возникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения"
    ) -> (
        serverError: (statusCode: Int, errorMessage: String),
        data: Data
    ) {
        
        let json: [String: Any] = [
            "statusCode": statusCode,
            "errorMessage": errorMessage
        ]
        
        let serverError = (statusCode, errorMessage)
        let data = try! JSONSerialization.data(withJSONObject: json)
        
        return (serverError, data)
    }
}
