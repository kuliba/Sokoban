//
//  RequestFactory+getCardStatementForPeriodTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 16.01.2024.
//

import XCTest
@testable import ForaBank

// TODO: дописать тесты

final class RequestFactory_getCardStatementForPeriodTests: XCTestCase {

    // MARK: - getCardStatementForPeriod
        
    func test_getCardStatementForPeriod_shouldSetRequestURL() throws {
        
        let (_, request) = try makeGetCardStatementForPeriod(period: .initialPeriod)
        
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/rest/v4/getCardStatementForPeriod"
        )
    }
    
    func test_makeGetScenarioQRRequest_shouldSetRequestMethodToPost() throws {
        
        let (_, request) = try makeGetCardStatementForPeriod(period: .initialPeriod)
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
        
    // MARK: - Helpers
    
    private func makeGetCardStatementForPeriod(
        productID: CardStatementForPeriodDomain.Payload.ProductID = 1,
        name: CardStatementForPeriodDomain.Payload.Name? = nil,
        period: Period,
        statementFormat: StatementFormat? = nil,
        cardNumber: CardStatementForPeriodDomain.Payload.CardNumber? = nil
    ) throws -> (
        payload: CardStatementForPeriodDomain.Payload,
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
        productID: CardStatementForPeriodDomain.Payload.ProductID = 1,
        name: CardStatementForPeriodDomain.Payload.Name?,
        period: Period,
        statementFormat: StatementFormat?,
        cardNumber: CardStatementForPeriodDomain.Payload.CardNumber?
    ) -> CardStatementForPeriodDomain.Payload {
        
        .init(
            id: productID,
            name: name,
            period: period,
            statementFormat: statementFormat,
            cardNumber: cardNumber)
    }
}

private extension Period {
    
    static let initialPeriod: Self = {
        
        let calendar = Calendar.current

        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!

        return Period(start: startDate, end: endDate)
    }()
}
