//
//  GetInfoRepeatPaymentMapperTests.swift
//
//
//  Created by Дмитрий Савушкин on 01.08.2024.
//

import GetInfoRepeatPaymentService
import XCTest

final class GetInfoRepeatPaymentMapperTests: XCTestCase {
    
    func test_map_shouldDeliverSessionCodeOnValidDataWithStatusCode200() throws {
        
        let (sessionCode, validData) = infoPayment()
        let response200 = anyHTTPURLResponse()
        
        let result = mapResponse(validData, response200)
        
        XCTAssertNoDiff(result, .success(sessionCode))
    }
    
    func test_map_shouldDeliverServerErrorOnResponseWithStatusCode500WithValidData() throws {
        
        let response = anyHTTPURLResponse(with: 400)
        let (serverError, validData) = serverError()
        
        let result = mapResponse(validData, response)
        
        XCTAssertNoDiff(
            result,
            .failure(.serverError(statusCode: serverError.statusCode, errorMessage: serverError.errorMessage))
        )
    }
    
    // MARK: - Helpers
    
    private let mapResponse = GetInfoRepeatPaymentMapper.mapResponse
    
    private func infoPayment(
        type: String = "TRANSPORT",
        parameterList: [GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer] = [
            .init(check: false, amount: 100.0, currencyAmount: "RUB", payer: .init(
                cardId: 10000184511,
                cardNumber: nil,
                accountId: nil,
                accountNumber: nil,
                phoneNumber: nil,
                inn: nil
            ))],
        productTemplate: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.ProductTemplate? = nil
    ) -> (
        infoPayment: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        data: Data
    ) {
        
        let json: [String: Any] = [
            "type": type,
            "parameterList": parameterList,
            "productTemplate": productTemplate
        ]
        
        let sessionCode = GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.dummy
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

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    static let dummy: Self = .init(
        type: "TRANSPORT",
        parameterList: [.init(check: false, amount: 100.0, currencyAmount: "RUB", payer: .init(
            cardId: 10000184511,
            cardNumber: nil,
            accountId: nil,
            accountNumber: nil,
            phoneNumber: nil,
            inn: nil
        ))],
        productTemplate: nil
    )
}
