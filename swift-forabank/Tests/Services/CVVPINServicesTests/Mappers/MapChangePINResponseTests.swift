//
//  MapChangePINResponseTests.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import CVVPINServices
import XCTest

final class MapChangePINResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidDataErrorOnInvalidData() {
        
        let invalidData = Data("invalid data".utf8)
        let codes = [199, 200, 201, 399, 400, 401, 404, 500]
        
        for code in codes {
            
            let result = map(
                invalidData,
                anyHTTPURLResponse(with: code)
            )
            
            assert(result, .failure(.invalidData(statusCode: code, data: invalidData)))
        }
    }
    
    func test_map_shouldDeliverServerErrorOnNon200Non$05AndValidData() throws {
        
        let serverStatusCode = 7512
        let errorMessage = "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения"
        let validData = makeServerErrorData(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )
        let non200Non406Non500Codes = [199, 201, 399, 400, 401, 404, 501]
        
        for code in non200Non406Non500Codes {
            
            let result = map(
                validData,
                anyHTTPURLResponse(with: code)
            )
            
            assert(result, .failure(.error(
                statusCode: serverStatusCode,
                errorMessage: errorMessage
            )))
        }
    }
    
    /*
     Пример ответа о финальной ошибке в случае СЛАБОГО ПИНА (также как и при прочих финальных ошибках нет retryAttempts, но другой http-код ответа - не 406, а не 500):
     http-код состояния (HTTP status code): 406
     {
        "statusCode": 7506,
        "errorMessage": "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
     }
     */
    func test_map_shouldDeliverWeakPINErrorOnResponse406AndValidData() throws {
        
        let serverStatusCode = 7506
        let errorMessage = "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
        let validData = makeServerErrorData(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )
        let response406 = anyHTTPURLResponse(with: 406)
        
        let result = map(validData, response406)
        
        assert(result, .failure(.weakPIN(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )))
    }
    
    /*
     Пример ответа о нефинальной ошибке:
     http-код состояния (HTTP status code): 500
     {
        "statusCode": 7512,
        "errorMessage": "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения",
        "retryAttempts": 2
     }
     */
    func test_map_shouldDeliverRetryErrorOnResponse500AndValidData() throws {
        
        let serverStatusCode = 7512
        let errorMessage = "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения"
        let validData = try JSONSerialization.data(withJSONObject: [
            "statusCode": serverStatusCode,
            "errorMessage": errorMessage,
            "retryAttempts": 2
        ] as [String: Any])
        let response500 = anyHTTPURLResponse(with: 500)
        
        let result = map(validData, response500)
        
        assert(result, .failure(.retry(
            statusCode: serverStatusCode,
            errorMessage: errorMessage,
            retryAttempts: 2
        )))
    }
    
    /*
     Пример ответа о финальной ошибке (нет retryAttempts):
     http-код состояния (HTTP status code): 500
     {
        "statusCode": 7506,
        "errorMessage": "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
     }
     */
    func test_map_shouldDeliverServerErrorOnResponse500AndInvalidData() throws {
        
        let serverStatusCode = 7512
        let errorMessage = "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения"
        let validData = makeServerErrorData(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )
        let response500 = anyHTTPURLResponse(with: 500)
        
        let result = map(validData, response500)
        
        assert(result, .failure(.error(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )))
    }
    
    func test_map_shouldDeliverInvalidDataErrorOnResponse200AndNonEmptyData() throws {
        
        let nonEmptyData = anyData()
        let response200 = anyHTTPURLResponse(with: 200)
        
        let result = map(nonEmptyData, response200)
        
        assert(result, .failure(.invalidData(statusCode: 200, data: nonEmptyData)))
        XCTAssertFalse(nonEmptyData.isEmpty)
    }
    
    /*
     Пример успешного ответа:
     http-код состояния (HTTP status code): 200
     В случае успеха ответ имеет http status-code равный 200 и пустое тело
     */
    func test_map_shouldDeliverSuccessOnResponse200AndValidData() throws {
        
        let data = Data()
        let response200 = anyHTTPURLResponse(with: 200)
        
        let result = map(data, response200)
        
        assert(result, .success(()))
        XCTAssertTrue(data.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias ChangePINResult = ResponseMapper.ChangePINResult
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ChangePINResult {
        
        ResponseMapper.mapChangePINResponse(data, httpURLResponse)
    }
    
    private func assert(
        _ received: ChangePINResult,
        _ expected: ChangePINResult,
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
            
        case (.success, .success):
            break
            
        default:
            XCTFail(
                "\nReceived \"\(received)\", but expected \(expected).",
                file: file, line: line
            )
        }
    }
}

private extension ResponseMapper.ChangePINMappingError {
    
    var view: View {
        
        switch self {
        case let .invalidData(statusCode, data):
            return .invalidData(statusCode: statusCode, data: data)
            
        case let .retry(statusCode, errorMessage, retryAttempts):
            return .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
            
        case let .error(statusCode, errorMessage):
            return .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case let .weakPIN(statusCode, errorMessage):
            return .weakPIN(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
    
    enum View: Equatable {
        
        case invalidData(statusCode: Int, data: Data)
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case weakPIN(statusCode: Int, errorMessage: String)
    }
}
