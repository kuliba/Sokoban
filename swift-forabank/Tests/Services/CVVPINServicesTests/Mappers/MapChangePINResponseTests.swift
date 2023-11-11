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
        
        for statusCode in codes {
            
            let result = map(
                invalidData,
                httpStatusCode: statusCode
            )
            
            assert(result, .failure(.invalidData(statusCode: statusCode, data: invalidData)))
        }
    }
    
    func test_map_shouldDeliverServerErrorOnNon200Non500AndValidData() throws {
        
        let serverStatusCode = 7512
        let errorMessage = "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения"
        let non200Non500Codes = [199, 201, 399, 400, 401, 404, 406, 501]
        
        for statusCode in non200Non500Codes {
            
            let result = map(
                httpStatusCode: statusCode,
                serverStatusCode: serverStatusCode,
                errorMessage: errorMessage
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
     
     Update 10.11.2023: Перечитала переписки с Суриным. В общем, 406 код- это как задумывалась, но не получилось, и отложилось до «рефакторинга».
     А схему он не актуализировал.
     Поэтому работаем с тем, что есть
     в реальности код 500 и {
     "statusCode": 7051,
     "errorMessage": "Возникла техническая ошибка 7051. Свяжитесь с поддержкой банка для уточнения"
     }
     */
    func test_map_shouldDeliverWeakPINErrorOnWeakPINHTTPStatusCodeAndWeakPINServerStatusCode() throws {
        
        let result = map(
            httpStatusCode: weakPINHTTPStatusCode(),
            serverStatusCode: weakPINServerStatusCode(),
            errorMessage: weakPINErrorMessage()
        )
        
        assert(result, .failure(.weakPIN(
            statusCode: weakPINServerStatusCode(),
            errorMessage: weakPINErrorMessage()
        )))
    }
    
    func test_map_shouldDeliverInvalidErrorOnWeakPINHTTPStatusCodeAndInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = map(
            invalidData,
            httpStatusCode: weakPINHTTPStatusCode()
        )
        
        assert(result, .failure(.invalidData(
            statusCode: weakPINHTTPStatusCode(),
            data: invalidData
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnWeakPINHTTPStatusCodeAndNonWeakPINServerStatusCode() throws {
        
        for serverStatusCode in [7000, 7001, 7015, 7050] {
            
            let errorMessage = "Возникла техническая ошибка \(serverStatusCode). Свяжитесь с поддержкой банка для уточнения"
            
            let result = map(
                httpStatusCode: weakPINHTTPStatusCode(),
                serverStatusCode: serverStatusCode,
                errorMessage: errorMessage
            )
            
            assert(result, .failure(.error(
                statusCode: serverStatusCode,
                errorMessage: errorMessage
            )))
            
            XCTAssertNotEqual(serverStatusCode, weakPINServerStatusCode())
        }
    }
    
    func test_map_shouldDeliverServerErrorOnNonWeakPINTTPStatusCodeNot500AndServerStatusCode7051AndValidData() throws {
        
        for httpStatusCode in [400, 401, 402, 406, 499, 501] {
            
            let result = map(
                httpStatusCode: httpStatusCode,
                serverStatusCode: weakPINServerStatusCode(),
                errorMessage: weakPINErrorMessage()
            )
            
            assert(result, .failure(.error(
                statusCode: weakPINServerStatusCode(),
                errorMessage: weakPINErrorMessage()
            )))
            
            XCTAssertNotEqual(httpStatusCode, weakPINHTTPStatusCode())
        }
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
        
        let httpStatusCode = 500
        let serverStatusCode = 7512
        let errorMessage = "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения"
        let validData = try JSONSerialization.data(withJSONObject: [
            "statusCode": serverStatusCode,
            "errorMessage": errorMessage,
            "retryAttempts": 2
        ] as [String: Any])
        
        let result = map(validData, httpStatusCode: httpStatusCode)
        
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
        
        let httpStatusCode = 500
        let serverStatusCode = 7506
        let errorMessage = "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
        let validData = makeServerErrorData(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )
        
        let result = map(validData, httpStatusCode: httpStatusCode)
        
        assert(result, .failure(.error(
            statusCode: serverStatusCode,
            errorMessage: errorMessage
        )))
    }
    
    func test_map_shouldDeliverInvalidDataErrorOnResponse200AndNonEmptyData() throws {
        
        let nonEmptyData = anyData()
        let httpStatusCode = 200
        
        let result = map(nonEmptyData, httpStatusCode: httpStatusCode)
        
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
        let httpStatusCode = 200
        
        let result = map(data, httpStatusCode: httpStatusCode)
        
        assert(result, .success(()))
        XCTAssertTrue(data.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias ChangePINResult = ResponseMapper.ChangePINResult
    
    private func map(
        _ data: Data,
        httpStatusCode: Int
    ) -> ChangePINResult {
        
        ResponseMapper.mapChangePINResponse(
            data,
            anyHTTPURLResponse(with: httpStatusCode)
        )
    }
    
    private func map(
        httpStatusCode: Int,
        serverStatusCode: Int,
        errorMessage: String
    ) -> ChangePINResult {
        
        ResponseMapper.mapChangePINResponse(
            makeServerErrorData(
                statusCode: serverStatusCode,
                errorMessage: errorMessage
            ),
            anyHTTPURLResponse(with: httpStatusCode)
        )
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
            XCTAssertNoDiff(received.view, expected.view, file: file, line: line)
            
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

private func weakPINHTTPStatusCode() -> Int { 500 }
private func weakPINServerStatusCode() -> Int { 7051 }
private func weakPINErrorMessage() -> String {
    
    "Возникла техническая ошибка 7051. Свяжитесь с поддержкой банка для уточнения"
}
