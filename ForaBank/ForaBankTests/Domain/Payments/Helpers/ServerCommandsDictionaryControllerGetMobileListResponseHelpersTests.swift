//
//  ServerCommandsDictionaryControllerGetMobileListResponseHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.02.2023.
//

@testable import ForaBank
import XCTest

final class ServerCommandsDictionaryControllerGetMobileListResponseHelpersTests: XCTestCase {
    
    typealias MobileListResponse = ServerCommands.DictionaryController.GetMobileList.Response
    
    func test_dataFromBundle() throws {
        
        let response = try MobileListResponse.dataFromBundle()
        let purefs = response.data?.mobileList.map(\.puref)
        let shortNames = response.data?.mobileList.map(\.shortName)
        
        XCTAssertEqual(purefs, ["iFora||4285", "iFora||4286", "iFora||515A3", "iFora||5814", "iFora||5576", "iFora||6169"])
        XCTAssertEqual(shortNames, ["Билайн", "МТС", "Yota", "Мегафон", "ТЕЛЕ2", "Тинькофф Мобайл"])
    }
}

extension ServerCommands.DictionaryController.GetMobileList.Response {
    
    static func dataFromBundle() throws -> Self {
        
        typealias TestCase = ServerCommandsDictionaryControllerGetMobileListResponseHelpersTests
        
        return try TestCase.data(fromFilename: "GetMobileDataResponseServerGeneric")
    }
}
