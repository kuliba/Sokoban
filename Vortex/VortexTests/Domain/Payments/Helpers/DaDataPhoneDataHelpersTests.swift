//
//  DaDataPhoneDataHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.02.2023.
//

@testable import ForaBank
import XCTest

final class DaDataPhoneDataHelpersTests: XCTestCase {
    
    func test_iFora4285() {
        
        let data = DaDataPhoneData.iFora4285
        
        XCTAssertEqual(data.puref, "iFora||4285")
        XCTAssertEqual(data.number, "9999999")
    }
    
    func test_iFora4286() {
        
        let data = DaDataPhoneData.iFora4286
        
        XCTAssertEqual(data.puref, "iFora||4286")
        XCTAssertEqual(data.number, "1619658")
    }
}
