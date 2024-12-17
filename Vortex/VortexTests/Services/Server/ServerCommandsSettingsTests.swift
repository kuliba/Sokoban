//
//  ServerCommandsSettingsTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 31.10.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsSettingsTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsSettingsTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - GetAtmList
    
    func testGetAppSettings_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAppSettingsResponseGeneric", withExtension: "json") else {
            XCTFail("testGetAppSettings_Response_Decoding : Missing file: GetAppSettingsResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.SettingsController.GetAppSettings.Response(statusCode: .ok, errorMessage: "string", data: .init(appSettings: .init(allowCloseDeposit: true)))
        
        // when
        let result = try decoder.decode(ServerCommands.SettingsController.GetAppSettings.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
