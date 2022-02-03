//
//  ServerCommandsPersonTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 02.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsPersontTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsPersontTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - GetClientInfo
    
    func testGetClientInfo_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetClientInfoGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.PersonController.GetClientInfo.Response(statusCode: .ok, errorMessage: "string", data: .init(address: "string", firstName: "Иван", lastName: "Иванов", patronymic: "Иванович", regNumber: "string", regSeries: "string"))
        
        // when
        let result = try decoder.decode(ServerCommands.PersonController.GetClientInfo.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
