//
//  ValetKeychainAgentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 14.02.2022.
//

import XCTest
@testable import ForaBank
import Valet

class ValetKeychainAgentTests: XCTestCase {
    
    let keychainAgent = ValetKeychainAgent(valetName: "TestValet")

    func testValue_Store() throws {
        
        // given
        let pincode = "1234"
        
        // then
        XCTAssertNoThrow(try keychainAgent.store(pincode, type: .pincode))
    }
    
    func testValue_Load() throws {
        
        // given
        let pincode = "1234"
        
        // when
        try keychainAgent.store(pincode, type: .pincode)
        let result: String? = try keychainAgent.load(type: .pincode)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, pincode)
    }
    
    func testValue_Clear() throws {
        
        // given
        let pincode = "1234"
        
        // when
        try keychainAgent.store(pincode, type: .pincode)
        try keychainAgent.clear(type: .pincode)
        
        // then
        do {
            
            let _: String? = try keychainAgent.load(type: .pincode)
            XCTFail()
            
        } catch {
            
            XCTAssertEqual(error as! KeychainError, KeychainError.itemNotFound)
        }
    }
}
