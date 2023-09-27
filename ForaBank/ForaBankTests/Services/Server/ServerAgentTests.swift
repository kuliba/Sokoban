//
//  ServerAgentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 21.12.2021.
//

import XCTest
@testable import ForaBank
@testable import ServerAgent

class ServerAgentTests: XCTestCase {
    
    let serverAgent = ServerAgent(
        baseURL: "abc",
        encoder: .init(),
        decoder: .init(),
        logError: { _ in },
        logMessage: { _ in },
        sendAction: { _ in }
    )
    let token = UUID().uuidString

    func testRequest_With_ServerCommand() throws {

        // given
        let command = ServerCommands.PaymentTemplateController.GetPaymentTemplateList(token: token, serial: nil)
        
        // when
        let request = try serverAgent.request(with: command)
        
        // then
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-XSRF-TOKEN"), token)
    }
}
