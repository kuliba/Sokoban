//
//  QrDataMapperTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 28.09.2023.
//

import XCTest
@testable import ForaBank

final class QrDataMapperTests: XCTestCase {
    
    func test_map_statusCode200_QRDataNotNil() throws {
        
        let qrData = try XCTUnwrap(map(statusCode: 200))
        
        XCTAssertNotNil(qrData)
    }
    
    func test_map_statusCodeNot200_FailureNotOk() throws {
        
        let qrData = try XCTUnwrap(map(statusCode: 400))
        
        let errorMessage = errorMessageByCode(400)
        
        XCTAssertNoDiff(qrData, .failure(.mapError(errorMessage)))
    }
    
    func test_map_statusCode200_dataNotValid_FailureMapError() throws {
        
        let qrData = try XCTUnwrap(map(statusCode: 200, data: Data("test".utf8)))
        
        XCTAssertNoDiff(qrData, .failure(.mapError(.defaultError)))
    }
    
    func test_map_statusCode200_errorNotNil_dataEmpty_FailureMapError() throws {
        
        let qrData = try XCTUnwrap(map(statusCode: 200, data: Data(String.error.utf8)))
        
        XCTAssertNoDiff(qrData, .failure(.mapError("404: Не найден запрос к серверу")))
    }
    
    func test_map_statusCode200_dataEmpty_FailureMapError() throws {
        
        let qrData = try XCTUnwrap(map(statusCode: 200, data: Data(String.emptySample.utf8)))
        
        XCTAssertNoDiff(qrData, .failure(.mapError(.defaultError)))
    }

    func test_map_statusCode200_dataCode102WithMessage_FailureMapError() throws {
        
        let qrData = try XCTUnwrap(map(statusCode: 200, data: Data(String.sampleCode102WithMessage.utf8)))
        
        XCTAssertNoDiff(qrData, .failure(.mapError("Ошибка 102")))
    }
    
    func test_map_statusCode200_dataCode102WithOutMessage_FailureMapErrorDefaultMessage() throws {
        
        let qrData = try XCTUnwrap(map(statusCode: 200, data: Data(String.sampleCode102WithOutMessage.utf8)))
        
        XCTAssertNoDiff(qrData, .failure(.mapError(.defaultError)))
    }
    
    func test_map_statusCode200_anyDataCodeWithOutMessage_FailureMapErrorDefaultMessage() throws {
        
        let qrData = try XCTUnwrap(map(statusCode: 200, data: Data(String.anyErrorWithOutMessage.utf8)))
        
        XCTAssertNoDiff(qrData, .failure(.mapError(.defaultError)))
    }

    func test_map_statusCode200_dataCode3122_Failure3122() throws {
        
        let qrData = try XCTUnwrap(map(statusCode: 200, data: Data(String.sampleCode3122.utf8)))
        
        XCTAssertNoDiff(qrData, .failure(.status3122))
    }
    
    func test_map_statusCode200_Success() throws {
        
        let qrData = try XCTUnwrap(map(data: Data(String.sample.utf8)))
        
        XCTAssertNoDiff(qrData.qrcId, "111")
        XCTAssertNoDiff(qrData.required, ["debit_account"])
        XCTAssertNoDiff(qrData.parameters, .parameters)
    }

    // MARK: - Helpers
    
    typealias Result = Swift.Result<QRScenarioData, QrDataMapper.MapperError>
    
    private func map(
        data: Data = Data(String.sample.utf8)
    ) throws -> QRScenarioData {
        
        let decodableLanding = QrDataMapper.map(
            data,
            anyHTTPURLResponse(200)
        )
        return try decodableLanding.get()
    }
    
    private func map(
        statusCode: Int,
        data: Data = Data(String.sample.utf8)
    ) -> Result {
        
        let decodableLanding = QrDataMapper.map(
            data,
            anyHTTPURLResponse(statusCode)
        )
        return decodableLanding
    }
    
    private func anyHTTPURLResponse(
        _ statusCode: Int = 200
    ) -> HTTPURLResponse {
        
        .init(
            url: URL(string: "https://www.forabank.ru/")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
    }
    
    private func errorMessageByCode(
        _ code: Int
    ) -> String {
        
        HTTPURLResponse.localizedString(forStatusCode: code)
    }
}

extension String {
    
    static let sample: Self = """
    {
        "statusCode": 0,
        "errorMessage": null,
        "data": {
            "qrcId": "111",
            "parameters": [{
                "type": "HEADER",
                "id": "title",
                "value": "Оплата по QR-коду"
            },
            {
                    "type": "INFO",
                    "id": "amount",
                    "value": "1 ₽",
                    "title": "Сумма",
                    "icon": {
                        "type": "LOCAL",
                        "value": "ic24IconMessage"
                    }
            }
            ],
            "required": ["debit_account"]
        }
    }
"""
    static let emptySample: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {}
    }
"""
    static let sampleCode102WithMessage: Self = """
    {
      "statusCode": 102,
      "errorMessage": "Ошибка 102",
      "data": null
    }
"""
    static let sampleCode102WithOutMessage: Self = """
    {
      "statusCode": 102,
      "errorMessage": null,
      "data": null
    }
"""
    static let sampleCode3122: Self = """
    {
      "statusCode": 3122,
      "errorMessage": "Ошибка 3122",
      "data": null
    }
"""
    static let anyErrorWithOutMessage: Self = """
    {
      "statusCode": 999,
      "errorMessage": nul,
      "data": null
    }
"""
    static let error: Self = """
{"statusCode":404,"errorMessage":"404: Не найден запрос к серверу","data":null}
"""
}

private extension Array where Element == AnyPaymentParameter {
    
    static let parameters: Self = [
        .init(PaymentParameterHeader(id: "title", value: "Оплата по QR-коду")),
        .init(PaymentParameterInfo(
            id: "amount",
            value: "1 ₽",
            title: "Сумма",
            icon:  PaymentParameterInfo.Icon(type: .local, value: "ic24IconMessage")))
    ]
}
