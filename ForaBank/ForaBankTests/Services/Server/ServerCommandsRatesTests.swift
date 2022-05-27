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
    let formatter = DateFormatter.iso8601

    //MARK: - GetExchangeCurrencyRates
    
    func testGetExchangeCurrencyRates_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetExchangeCurrencyRatesResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000))
        let expected = ServerCommands.RatesController.GetExchangeCurrencyRates.Response(statusCode: .ok, errorMessage: "string", data: .init(currency: .eur, currencyCode: "978", currencyId: 90001299, currencyName: "Евро", rateBuy: 85.9, rateBuyDate: date, rateSell: 87.3, rateSellDate: date, rateType: "КурсДБОФЛ", rateTypeId: 10000000002))
        
        // when
        let result = try decoder.decode(ServerCommands.RatesController.GetExchangeCurrencyRates.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
