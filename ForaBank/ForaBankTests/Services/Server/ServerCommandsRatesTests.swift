//
//  ServerCommandsRatesTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 01.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsRatesTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsRatesTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let formatter = DateFormatter.utc

    //MARK: - GetExchangeCurrencyRates
    
    func testGetExchangeCurrencyRates_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetExchangeCurrencyRatesResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = formatter.date(from: "2022-02-01T16:16:46.021Z")!
        let expected = ServerCommands.RatesController.GetExchangeCurrencyRates.Response(statusCode: .ok, errorMessage: "string", data: .init(currencyCodeAlpha: "EUR", currencyCodeNumeric: "978", currencyID: 90001299, currencyName: "Евро", rateBuy: 85.9, rateBuyDate: date, rateSell: 87.3, rateSellDate: date, rateType: "КурсДБОФЛ", rateTypeID: 10000000002))
        
        // when
        let result = try decoder.decode(ServerCommands.RatesController.GetExchangeCurrencyRates.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
