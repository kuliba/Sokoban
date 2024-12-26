//
//  GetShowcaseDomainStateTests.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

import XCTest
@testable import CollateralLoanLandingGetShowcaseUI

final class GetShowcaseDomainStateTests: XCTestCase {
    
    func test_getValidShowcase() {
        
        var state = GetShowcaseDomain.State()
        let stub = CollateralLoanLandingGetShowcaseData.stub
        state.result = .success(stub)
        
        XCTAssertNoDiff(stub, state.showcase)
    }
    
    func test_getNoShowcase() {
        
        var state = GetShowcaseDomain.State()
        state.result = .failure(.init())
        
        XCTAssertNil(state.showcase)
    }
}
