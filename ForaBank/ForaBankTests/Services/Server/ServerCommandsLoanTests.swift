//
//  ServerCommandsLoanTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 07.04.2022.
//

import Foundation

import XCTest
@testable import ForaBank

class ServerCommandsLoanTests: XCTestCase {

    let bundle = Bundle(for: ServerCommandsLoanTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let formatter = DateFormatter.iso8601

    //MARK: - GetPersonsCredit
    
    func testGetPersonsCredit_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetPersonsCreditResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let datePayment = formatter.date(from: "2022-04-07T07:58:47.623Z")!
        let personCredit = PersonsCreditItem(original: .init(loandId: 10000184511, clientId: 0, currencyCode: "RUB", currencyNumber: 810, currencyId: 810, number: "КД-810", datePayment: datePayment, amountCredit: 56305.61, amountRepaid: 56305.61, amountPayment: 56305.61, overduePayment: 56305.61), customName: "Мой продукт")
        
        let expected = ServerCommands.LoanController.GetPersonsCredit.Response(statusCode: .ok, errorMessage: "string", data: personCredit)
        
        // when
        let result = try decoder.decode(ServerCommands.LoanController.GetPersonsCredit.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
