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
            maxOffsetX: 10
        )
        
        XCTAssertNoDiff(sut.offsetX, 5)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SliderViewModel
    
    private func makeSUT(
        offsetX: CGFloat = 0,
        maxOffsetX: CGFloat = 100,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT(
            offsetX: offsetX,
            maxOffsetX: maxOffsetX
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut)
    }
}
