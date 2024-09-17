//
//  RequestFactory+getCardStatementForPeriodTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 16.01.2024.
//

import XCTest
@testable import ForaBank
import CardStatementAPI

final class RequestFactory_getCardStatementForPeriodTests: XCTestCase {

    // MARK: - getCardStatementForPeriod
        
    func test_getCardStatementForPeriod_shouldSetRequestURL() throws {
        
        let (_, request) = try makeGetCardStatementForPeriod(period: .initialPeriod)
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v5/getCardStatementForPeriod"
        )
    }
    
    func test_makeGetScenarioQRRequest_shouldSetRequestMethodToPost() throws {
        
        let (_, request) = try makeGetCardStatementForPeriod(period: .initialPeriod)
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_makeGetScenarioQRRequest_shouldSetRequestBody() throws {
        
        let (payload, request) = try makeGetCardStatementForPeriod(
            productID: 1,
            name: "cardName",
            period: .initialPeriod,
            statementFormat: .csv,
            cardNumber: "1111"
        )

        let httpBody = try XCTUnwrap(request.httpBody)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601)

        let decodedRequest = try decoder.decode(DecodableRequest.self, from: httpBody)

        XCTAssertNoDiff(decodedRequest.id, payload.id.rawValue)
        XCTAssertNoDiff(decodedRequest.name, payload.name?.rawValue)
        XCTAssertNoDiff(decodedRequest.cardNumber, payload.cardNumber?.rawValue)
        XCTAssertNoDiff(decodedRequest.statementFormat, payload.statementFormat?.rawValue)
        XCTAssertNoDiff(decodedRequest.startDate, payload.period.start)
        XCTAssertNoDiff(decodedRequest.endDate, payload.period.end)
    }
    
    // MARK: - Helpers
    private typealias Payload = CardStatementAPI.CardStatementForPeriodPayload
    private func makeGetCardStatementForPeriod(
        productID: Payload.ProductID = 1,
        name: Payload.Name? = nil,
        period: Payload.Period,
        statementFormat: Payload.StatementFormat? = nil,
        cardNumber: Payload.CardNumber? = nil
    ) throws -> (
        payload: Payload,
        request: URLRequest
    ) {
        let payload = anyPayload(
            productID: productID,
            name: name,
            period: period,
            statementFormat: statementFormat,
            cardNumber: cardNumber
        )
        let request = try RequestFactory.getCardStatementForPeriod(payload: payload)
        
        return (payload, request)
    }
    
    private func anyPayload(
        productID: Payload.ProductID = 1,
        name: Payload.Name?,
        period: Payload.Period,
        statementFormat: Payload.StatementFormat?,
        cardNumber: Payload.CardNumber?
    ) -> Payload {
        
        .init(
            id: productID,
            name: name,
            period: period,
            statementFormat: statementFormat,
            cardNumber: cardNumber,
            operationType: nil,
            operationGroup: nil,
            includeAdditionalCards: nil
        )
    }
    
    private struct DecodableRequest: Decodable {
        
        let id: Int
        let name: String
        let statementFormat: String
        let cardNumber: String
        let startDate: Date
        let endDate: Date
    }
}

private extension CardStatementAPI.CardStatementForPeriodPayload.Period {
    
    static let initialPeriod: Self = {
        
        let calendar = Calendar.current

        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!

        return .init(start: startDate, end: endDate)
    }()
}
