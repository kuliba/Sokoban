//
//  MapGetPINConfirmationCodeResponseTests.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import CVVPINServices
import XCTest

final class MapGetPINConfirmationCodeResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidDataErrorOnInvalidData() {
        
        let invalidData = Data("invalid data".utf8)
        let codes = [199, 200, 201, 399, 400, 401, 404, 500]
        
        for code in codes {
            
            let result = map(
                invalidData,
                anyHTTPURLResponse(with: code)
            )
            
            assert(result, .failure(.invalidData(statusCode: code)))
        }
    }
    
    func test_map_shouldDeliverServerErrorOnNon200AndValidData() throws {
        
        let serverStatusCode = 7512
        let errorMessage = "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения"
        let validData = makeServerErrorData(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )
        let non200Codes = [199, 201, 399, 400, 401, 404, 500]
        
        for code in non200Codes {
            
            let result = map(
                validData,
                anyHTTPURLResponse(with: code)
            )
            
            assert(result, .failure(.server(
                statusCode: serverStatusCode,
                errorMessage: errorMessage
            )))
        }
    }
    
    func test_map_shouldDeliverSuccessOnResponse200AndValidData() throws {
        
        let eventId = UUID().uuidString
        let phone = UUID().uuidString
        let validData = try JSONSerialization.data(withJSONObject: [
            "eventId": eventId,
            "phone": phone
        ])
        let response200 = anyHTTPURLResponse(with: 200)
        
        let result = map(validData, response200)
        
        assert(result, .success(.init(
            eventID: eventId,
            phone: phone
        )))
    }
    
    // MARK: - Helpers
    
    private typealias GetPINConfirmationCodeResult = ResponseMapper.GetPINConfirmationCodeResult
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetPINConfirmationCodeResult {
        
        ResponseMapper.mapGetPINConfirmationCodeResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ received: GetPINConfirmationCodeResult,
        _ expected: GetPINConfirmationCodeResult,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch (received, expected) {
        case let (
            .failure(received),
            .failure(expected)
        ):
            XCTAssertEqual(received.view, expected.view, file: file, line: line)
            
        case let (
            .success(received),
            .success(expected)
        ):
            XCTAssertEqual(received, expected, file: file, line: line)
            
        default:
            XCTFail(
                "\nReceived \"\(received)\", but expected \(expected).",
                file: file, line: line
            )
        }
    }
}

private extension ResponseMapper.GetPINConfirmationCodeError {
    
    var view: View {
        
        switch self {
        case let .invalidData(statusCode):
            return .invalidData(statusCode: statusCode)
            
        case let .server(statusCode, errorMessage):
            return .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
    
    enum View: Equatable {
        
        case invalidData(statusCode: Int)
        case server(statusCode: Int, errorMessage: String)
    }
}
