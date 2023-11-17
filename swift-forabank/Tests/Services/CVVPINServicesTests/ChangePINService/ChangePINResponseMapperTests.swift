//
//  ChangePINResponseMapperTests.swift
//  
//
//  Created by Igor Malyarov on 04.10.2023.
//

import XCTest

enum ChangePINResponseMapper {}

extension ChangePINResponseMapper {
    
    typealias Result = Error?
    
    static func map(
        data: Data,
        response: HTTPURLResponse
    ) -> Result {
        
        let statusCode = response.statusCode
        
        switch (statusCode, data) {
        case (200, .init()):
            return nil
            
        case (406, _):
            do {
                let retry = try JSONDecoder().decode(NoRetry.self, from: data)
                return .weakPIN(statusCode: retry.statusCode, errorMessage: retry.errorMessage)
            } catch {
                return .unknown(statusCode: 500, data: data)
            }
            
        case (500, _):
            do {
                let retry = try JSONDecoder().decode(Retry.self, from: data)
                return .retry(statusCode: retry.statusCode, errorMessage: retry.errorMessage, retryAttempts: retry.retryAttempts)
            } catch {
                do {
                    let noRetry = try JSONDecoder().decode(NoRetry.self, from: data)
                    return .error(statusCode: noRetry.statusCode, errorMessage: noRetry.errorMessage)
                    
                } catch {
                    return .unknown(statusCode: 500, data: data)
                }
            }
            
        default:
            return .unknown(statusCode: statusCode, data: data)
        }
    }
    
    private struct Retry: Decodable {
        
        let statusCode: Int
        let errorMessage: String
        let retryAttempts: Int
    }
    
    private struct NoRetry: Decodable {
        
        let statusCode: Int
        let errorMessage: String
    }
    
    enum Error: Swift.Error, Equatable {
        
        case error(
            statusCode: Int,
            errorMessage: String
        )
        case retry(
            statusCode: Int,
            errorMessage: String,
            retryAttempts: Int
        )
        case unknown(statusCode: Int, data: Data)
        case weakPIN(
            statusCode: Int,
            errorMessage: String
        )
    }
}

final class ChangePINResponseMapperTests: XCTestCase {
    
    /*
     Пример успешного ответа:
     http-код состояния (HTTP status code): 200
     В случае успеха ответ имеет http status-code равный 200 и пустое тело
     */
    func test_map_shouldDeliverVoidOnOKStatusCode() {
        
        let response = anyHTTPURLResponse(with: statusCodeOK())
        
        XCTAssertNil(map(response: response))
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
    func test_map_shouldDeliverRetryOnStatusCode500WithRetry() {
        
        let result = map(
            data: makeRetryData(),
            response: anyHTTPURLResponse(with: 500)
        )
        
        XCTAssertEqual(
            result,
            .retry(
                statusCode: 7512,
                errorMessage: "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения",
                retryAttempts: 2
            )
        )
    }
    
    /*
     Пример ответа о финальной ошибке (нет retryAttempts):
     http-код состояния (HTTP status code): 500
     {
        "statusCode": 7506,
        "errorMessage": "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
     }
     */
    func test_map_shouldDeliverNoRetryErrorOnStatusCode500WithoutRetry() {
        
        let result = map(
            data: makeNoRetryData(),
            response: anyHTTPURLResponse(with: 500)
        )
        
        XCTAssertEqual(
            result,
            .error(
                statusCode: 7506,
                errorMessage: "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
            )
        )
    }
    
    /*
     Пример ответа о финальной ошибке в случае СЛАБОГО ПИНА (также как и при прочих финальных ошибках нет retryAttempts, но другой http-код ответа - не 406, а не 500):
     http-код состояния (HTTP status code): 406
     {
        "statusCode": 7506,
        "errorMessage": "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
     }
     */
    func test_map_shouldDeliverWeakPINErrorOnStatusCode406() {
        
        let result = map(
            data: makeNoRetryData(),
            response: anyHTTPURLResponse(with: 406)
        )
        
        XCTAssertEqual(
            result,
            .weakPIN(
                statusCode: 7506,
                errorMessage: "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
            )
        )
    }
    
    func test_shouldDeliverUnknownOnStatusCode200NonEmptyData() {
        
        let data = makeNoRetryData()
        let result = map(
            data: data,
            response: anyHTTPURLResponse(with: 111)
        )
        
        XCTAssertEqual(
            result,
            .unknown(statusCode: 111, data: data)
        )
    }
    
    func test_shouldDeliverUnknownOnStatusCode200BadData() {
        
        let data = Data("bad data".utf8)
        let result = map(
            data: data,
            response: anyHTTPURLResponse(with: 111)
        )
        
        XCTAssertEqual(
            result,
            .unknown(statusCode: 111, data: data)
        )
    }
    
    func test_shouldDeliverUnknownOnOtherStatusCodesEmptyData() {
        
        assertDeliverUnknown(
            forCodes: [111, 199, 201, 405, 407, 499, 501],
            data: .init()
        )
    }
    
    func test_shouldDeliverUnknownOnOtherStatusCodesNonEmptyData() {
        
        assertDeliverUnknown(
            forCodes: [111, 199, 201, 405, 407, 499, 501],
            data: makeNoRetryData()
        )
    }
    
    func test_shouldDeliverUnknownOnOtherStatusCodesBadData() {
        
        assertDeliverUnknown(
            forCodes: [111, 199, 201, 405, 407, 499, 501],
            data: Data("bad data".utf8)
        )
    }
    
    // MARK: - Helpers
    
    typealias Mapper = ChangePINResponseMapper
    
    private func map(
        data: Data = .init(),
        response: HTTPURLResponse
    ) -> Mapper.Result {
        
        Mapper.map(data: data, response: response)
    }
    
    private func statusCodeOK() -> Int { 200 }
    
    private func makeRetryData(
        statusCode: Int = 7512,
        errorMessage: String = "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения",
        retryAttempts: Int = 2
    ) -> Data {
        
        try! JSONSerialization.data(withJSONObject: [
            "statusCode": statusCode,
            "errorMessage": errorMessage,
            "retryAttempts": retryAttempts
        ] as [String: Any])
    }
    
    private func makeNoRetryData(
        statusCode: Int = 7506,
        errorMessage: String = "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
    ) -> Data {
        
        try! JSONSerialization.data(withJSONObject: [
            "statusCode": statusCode,
            "errorMessage": errorMessage
        ] as [String: Any])
    }
        
    private func assertDeliverUnknown(
        forCodes codes: [Int],
        data: Data
    ) {
        for code in codes {
            
            let result = map(
                data: data,
                response: anyHTTPURLResponse(with: code)
            )
            
            XCTAssertEqual(
                result,
                .unknown(statusCode: code, data: data)
            )
        }
    }
}
