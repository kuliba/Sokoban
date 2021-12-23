//
//  ServerAgentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 21.12.2021.
//

import XCTest
@testable import ForaBank

class ServerAgentTests: XCTestCase {
    
    let serverAgent = ServerAgent(context: .init(for: .test))
    let token = UUID().uuidString

    func testRequest_With_ServerCommand() throws {

        // given
        let command = ServerCommands.PaymentTemplateController.GetPaymentTemplateList(token: token)
        
        // when
        let request = try serverAgent.request(with: command)
        
        // then
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-XSRF-TOKEN"), token)
    }
}
