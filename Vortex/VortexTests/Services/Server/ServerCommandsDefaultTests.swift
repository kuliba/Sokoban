//
//  ServerCommandsDefaultTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 01.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsDefaultTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsDefaultTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - Login
    
    func testLogin_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "LoginResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.Default.Login.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.Default.Login.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
