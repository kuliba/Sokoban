//
//  SliderViewModelTests.swift
//
//
//  Created by Andryusina Nataly on 27.02.2024.
//

import XCTest
@testable import ActivateSlider
import SwiftUI

final class SliderViewModelTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetInitialValue() {
        
        let sut = makeSUT(
            offsetX: 5,
            maxOffsetX: 10,
            didSwitchOn: {}
        )
        
        XCTAssertNoDiff(sut.offsetX, 5)
    }
    
    // MARK: - reset
    
    func test_reset_shouldSetOffsetXToZero() {
        
        let sut = makeSUT(
            offsetX: 5
        )
        
        XCTAssertNoDiff(sut.offsetX, 5)
        
        sut.reset()
        
        XCTAssertNoDiff(sut.offsetX, 0)
    }
    
    // MARK: - dragOnChanged
    
    func test_dragOnChanged_translationWidthLessThanMaxOffset_shouldSetNewOffsetX() {
        
        let sut = makeSUT(
            offsetX: 0,
            maxOffsetX: 15
        )
        
        XCTAssertNoDiff(sut.offsetX, 0)
        
        sut.dragOnChanged(9)
        
        XCTAssertNoDiff(sut.offsetX, 9)
    }
    
    func test_dragOnChanged_translationWidthMoreThanMaxOffset_shouldSetOffsetXUnchange() {
        
        let sut = makeSUT(
            offsetX: 10,
            maxOffsetX: 15
        )
        
        XCTAssertNoDiff(sut.offsetX, 10)
        
        sut.dragOnChanged(16)
        
        XCTAssertNoDiff(sut.offsetX, 10)
    }

    // MARK: - dragOnEnded
    
    func test_dragOnEnded_offsetLessThanHalfMaxOffset_shouldSetOffsetXToZero() {
        
        let sut = makeSUT(
            offsetX: 5,
            maxOffsetX: 15
        )
        
        XCTAssertNoDiff(sut.offsetX, 5)
        
        sut.dragOnEnded()
        
        XCTAssertNoDiff(sut.offsetX, 0)
    }
    
    func test_dragOnEnded_offsetMoreThanHalfMaxOffset_shouldCallDidSwitchOn() {
        
        let exp = expectation(description: "wait for dragOnEnd")

        let sut = makeSUT(
            offsetX: 10,
            maxOffsetX: 15,
            didSwitchOn: {
                
                exp.fulfill()
            }
        )
        
        sut.dragOnEnded()

        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SliderViewModel
    
    private func makeSUT(
        offsetX: CGFloat = 0,
        maxOffsetX: CGFloat = 100,
        didSwitchOn: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT(
            offsetX: offsetX,
            maxOffsetX: maxOffsetX,
            didSwitchOn: didSwitchOn
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut)
    }
}
