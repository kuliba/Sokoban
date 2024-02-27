//
//  SliderViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 27.02.2024.
//

import XCTest
@testable import ActivateSlider

final class SliderViewModelTests: XCTestCase {

    // MARK: - Helpers
    
    private typealias SUT = SliderViewModel

    private func makeSUT(
        maxOffsetX: CGFloat = 100,
        didSwitchOn: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT(
            maxOffsetX: maxOffsetX,
            didSwitchOn: didSwitchOn
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut)
    }
}
