//
//  DaDataPhoneDataHelpersTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 22.02.2023.
//

@testable import ForaBank
import XCTest

final class DaDataPhoneDataHelpersTests: XCTestCase {
    
    func test_iVortex4285() {
        
        let data = DaDataPhoneData.iVortex4285
        
        XCTAssertEqual(data.puref, "iVortex||4285")
        XCTAssertEqual(data.number, "9999999")
    }
    
    func test_iVortex4286() {
        
        let data = DaDataPhoneData.iVortex4286
        
        XCTAssertEqual(data.puref, "iVortex||4286")
        XCTAssertEqual(data.number, "1619658")
    }
}
