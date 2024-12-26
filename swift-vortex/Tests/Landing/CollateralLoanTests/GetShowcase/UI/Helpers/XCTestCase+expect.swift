//
//  XCTestCase+expect.swift
//  
//
//  Created by Valentin Ozerov on 26.12.2024.
//

import RxViewModel
import XCTest
@testable import CollateralLoanLandingGetShowcaseUI

extension XCTestCase {
    
    func expect(
        _ sut: GetShowcaseDomain.EffectHandler,
        with effect: GetShowcaseDomain.Effect,
        toDeliver expectedEvent: GetShowcaseDomain.Event,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) { receivedEvent in
            
            XCTAssertNoDiff(
                receivedEvent,
                expectedEvent,
                "\nExpected \(expectedEvent), but got \(receivedEvent) instead.",
                file: file, line: line
            )
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
