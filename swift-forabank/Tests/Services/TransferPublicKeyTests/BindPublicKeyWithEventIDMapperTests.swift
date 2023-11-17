//
//  BindPublicKeyWithEventIDMapperTests.swift
//
//
//  Created by Igor Malyarov on 04.08.2023.
//

import TransferPublicKey
import XCTest

final class BindPublicKeyWithEventIDMapperTests: XCTestCase {
    
    func test_map_shouldNotDeliverErrorOnResponse200() throws {
        
        let response = anyHTTPURLResponse(with: 200)
        let data = try XCTUnwrap("any data".data(using: .utf8))
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, nil)
    }
    
    func test_map_shouldDeliverAPIErrorOnNon200Non400Non500ResponseWithValidData() throws {
        
        let (model, data) = try apiError(1111, "some API error", retryAttempts: 2)
        let statusCodes = [199, 201, 399, 401, 499, 501]
        
        statusCodes.forEach { statusCode in
            
            let response = anyHTTPURLResponse(with: statusCode)
            let error = map(data, response)
            
            XCTAssertNoDiff(error, .apiError(model))
        }
    }
    
    func test_map_shouldDeliverAPIErrorWithRetryOnNon200Non400Non500ResponseWithValidDataWithRetry() throws {
        
        let data = try XCTUnwrap("any data".data(using: .utf8))
        let statusCodes = [199, 201, 399, 401, 499, 501]
        
        statusCodes.forEach { statusCode in
            
            let response = anyHTTPURLResponse(with: statusCode)
            let error = map(data, response)
            
            XCTAssertNoDiff(error, .unknownStatusCode(statusCode))
        }
    }
    
    func test_map_shouldDeliverUnknownStatusCodeErrorOnNon200Non400Non500ResponseWithInvalidData() throws {
        
        let invalidData = try XCTUnwrap("any data".data(using: .utf8))
        let statusCodes = [199, 201, 399, 401, 499, 501]
        
        statusCodes.forEach { statusCode in
            
            let response = anyHTTPURLResponse(with: statusCode)
            let error = map(invalidData, response)
            
            XCTAssertNoDiff(error, .unknownStatusCode(statusCode))
        }
    }
    
    func test_map_shouldDeliverInvalidDataErrorOnResponse400WithInvalidData() throws {
        
        let response = anyHTTPURLResponse(with: 400)
        let data = try XCTUnwrap("invalid data".data(using: .utf8))
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, .invalidData(statusCode: 400))
    }
    
    func test_map_shouldDeliverAPIErrorOnResponse400WithValidData() throws {
        
        let response = anyHTTPURLResponse(with: 400)
        let (model, data) = try apiError(7503, "data must not be empty")
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, .apiError(model))
    }
    
    func test_map_shouldDeliverAPIErrorWithRetryOnResponse400WithValidDataWithRetry() throws {
        
        let response = anyHTTPURLResponse(with: 400)
        let (model, data) = try apiError(7503, "data must not be empty", retryAttempts: 2)
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, .apiError(model))
    }
    
    func test_map_shouldDeliverInvalidDataErrorOnResponse422WithInvalidData() throws {
        
        let response = anyHTTPURLResponse(with: 422)
        let data = try XCTUnwrap("invalid data".data(using: .utf8))
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, .invalidData(statusCode: 422))
    }
    
    func test_map_shouldDeliverAPIErrorOnResponse422WithValidData() throws {
        
        let response = anyHTTPURLResponse(with: 422)
        let (model, data) = try apiError(7503, "Возникла техническая ошибка 7503. Свяжитесь с поддержкой банка для уточнения")
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, .apiError(model))
    }
    
    func test_map_shouldDeliverAPIErrorWithRetryOnResponse422WithValidDataWithRetry() throws {
        
        let response = anyHTTPURLResponse(with: 422)
        let (model, data) = try apiError(7503, "data must not be empty", retryAttempts: 2)
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, .apiError(model))
    }
    
    func test_map_shouldDeliverInvalidDataErrorOnResponse500WithInvalidData() throws {
        
        let response = anyHTTPURLResponse(with: 500)
        let data = try XCTUnwrap("invalid data".data(using: .utf8))
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, .invalidData(statusCode: 500))
    }
    
    func test_map_shouldDeliverAPIErrorOnResponse500WithValidData() throws {
        
        let response = anyHTTPURLResponse(with: 500)
        let (model, data) = try apiError(7503, "Возникла техническая ошибка 7503. Свяжитесь с поддержкой банка для уточнения")
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, .apiError(model))
    }
    
    func test_map_shouldDeliverAPIErrorWithRetryOnResponse500WithValidDataWithRetry() throws {
        
        let response = anyHTTPURLResponse(with: 500)
        let (model, data) = try apiError(7503, "data must not be empty", retryAttempts: 2)
        
        let error = map(data, response)
        
        XCTAssertNoDiff(error, .apiError(model))
    }
    
    // MARK: - Helpers
    
    private let map = BindPublicKeyWithEventIDMapper.map
    
    typealias APIError = BindPublicKeyWithEventIDMapper.APIError
    
    private func apiError(
        _ statusCode: Int,
        _ errorMessage: String,
        retryAttempts: Int? = nil
    ) throws -> (
        model: APIError,
        json: Data
    ) {
        let model = APIError(
            statusCode: statusCode,
            errorMessage: errorMessage,
            retryAttempts: retryAttempts
        )
        
        let json = try JSONSerialization.data(withJSONObject: [
            "statusCode": statusCode,
            "errorMessage": errorMessage,
            "retryAttempts": retryAttempts as Any
        ] as [String: Any])
        
        return (model, json)
    }
}
