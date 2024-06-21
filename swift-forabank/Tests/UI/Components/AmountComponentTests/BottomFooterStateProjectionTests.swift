//
//  BottomFooterStateProjectionTests.swift
//
//
//  Created by Igor Malyarov on 21.06.2024.
//

import AmountComponent
import XCTest

final class BottomFooterStateProjectionTests: XCTestCase {
    
    func test_shouldSetAmount() {
        
        let state = BottomFooterState(
            amount: 99,
            buttonState: .active,
            style: .amount
        )
        
        XCTAssertNoDiff(state.projection, .init(amount: 99, buttonTap: nil))
    }
    
    func test_shouldSetButtonTap() {
        
        let state = BottomFooterState(
            amount: 11,
            buttonState: .tapped,
            style: .button
        )
        
        XCTAssertNoDiff(state.projection, .init(amount: 11, buttonTap: .init()))
    }
}
