//
//  ServerCommandsDictionaryControllerGetMobileListResponseHelpersTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 22.02.2023.
//

@testable import Vortex
import XCTest

final class ServerCommandsDictionaryControllerGetMobileListResponseHelpersTests: XCTestCase {
    
    typealias MobileListResponse = ServerCommands.DictionaryController.GetMobileList.Response
    
    func test_dataFromBundle() throws {
        
        let response = try MobileListResponse.dataFromBundle()
        let purefs = response.data?.mobileList.map(\.puref)
        let shortNames = response.data?.mobileList.map(\.shortName)
        
        XCTAssertEqual(purefs, ["iVortex||4285", "iVortex||4286", "iVortex||515A3", "iVortex||5814", "iVortex||5576", "iVortex||6169"])
        XCTAssertEqual(shortNames, ["Билайн", "МТС", "Yota", "Мегафон", "ТЕЛЕ2", "Тинькофф Мобайл"])
    }
}

extension ServerCommands.DictionaryController.GetMobileList.Response {
    
    static func dataFromBundle() throws -> Self {
        
        typealias TestCase = ServerCommandsDictionaryControllerGetMobileListResponseHelpersTests
        
        return try TestCase.data(fromFilename: "GetMobileDataResponseServerGeneric")
    }
}
