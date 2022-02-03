//
//  ServerCommandsDaDataTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 03.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsDaDataTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsDaDataTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - GetPhoneInfo
    
    func testGetPhoneInfo_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetPhoneInfoGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.DaDataController.GetPhoneInfo.Response(statusCode: .ok, errorMessage: "string", data: [.init(city: "string", cityCode: "962", country: "Россия", countryCode: "7", extension: "string", md5hash: "576097d55947bf708c4f03e7f8134f26", number: "9899747", phone: "+7 962 989-97-47", provider: "ПАО \"Мобильные ТелеСистемы\"", puref: "iFora||4286", qc: 0, qcConflict: 0, region: "Москва и Московская область", source: "9629899747", svgImage: "string", timezone: "UTC+3", type: "Мобильный")])
        
        // when
        let result = try decoder.decode(ServerCommands.DaDataController.GetPhoneInfo.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetPhoneInfo_Response_DecodingMin() throws {

        // given
        let url = bundle.url(forResource: "GetPhoneInfoGenericMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let expected = ServerCommands.DaDataController.GetPhoneInfo.Response(statusCode: .ok, errorMessage: "string", data: [.init(city: nil, cityCode: "962", country: "Россия", countryCode: "7", extension: nil, md5hash: "576097d55947bf708c4f03e7f8134f26", number: "9899747", phone: "+7 962 989-97-47", provider: "ПАО \"Мобильные ТелеСистемы\"", puref: "iFora||4286", qc: 0, qcConflict: 0, region: "Москва и Московская область", source: "9629899747", svgImage: "string", timezone: "UTC+3", type: "Мобильный")])
        
        // when
        let result = try decoder.decode(ServerCommands.DaDataController.GetPhoneInfo.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
