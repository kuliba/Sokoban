//
//  SpentTests.swift
//  
//
//  Created by Andryusina Nataly on 24.06.2024.
//

@testable import LandingUIComponent
import XCTest
import SwiftUI

final class SpentTests: XCTestCase {
    
    // MARK: - test spentPercent
    
    func test_limitNil_shouldReturnNoSpent() {
        
        let sut = makeSUT(limit: nil)
        
        XCTAssertEqual(sut, .noSpent)
    }
    
    func test_limitCurrentValue0_shouldReturnNoSpent() {
        
        let sut = makeSUT(limit: makeLimit(currentValue: 0, value: 10.01))
        
        XCTAssertEqual(sut, .noSpent)
    }
    
    func test_limitCurrentValueEqualValue_shouldReturnSpentEverything() {
        
        let sut = makeSUT(limit: makeLimit(currentValue: 10.01, value: 10.01))
        
        XCTAssertEqual(sut, .spentEverything)
    }

    func test_spend95percent_shouldReturnSpent() {
        
        let sut = makeSUT(limit: makeLimit(currentValue: 95, value: 100))
        
        XCTAssertEqual(sut, .spent(584))
    }

    func test_spend_99_6percent_shouldReturnSpentWithMaxAngle() {
        
        let sut = makeSUT(limit: makeLimit(currentValue: 99.6, value: 100))
        
        XCTAssertEqual(sut, .spent(.maxAngle))
    }

    func test_spend_99_7percent_shouldReturnSpentWithMaxAngle() {
        
        let sut = makeSUT(limit: makeLimit(currentValue: 99.7, value: 100))
        
        XCTAssertEqual(sut, .spent(.maxAngle))
    }

    func test_spend_99_9percent_shouldReturnSpentWithMaxAngle() {
        
        let sut = makeSUT(limit: makeLimit(currentValue: 99.9, value: 100))
        
        XCTAssertEqual(sut, .spent(.maxAngle))
    }

    // MARK: - helper

    private func makeSUT(
        limit: LimitValues?,
        interval: CGFloat = 15,
        startAngle: CGFloat = 270
    ) -> Spent {
        
        return Spent.spentPercent(
            limit: limit,
            interval: interval,
            startAngle: startAngle
        )
    }
    
    private func makeLimit(
        currentValue: Decimal,
        value: Decimal
    ) -> LimitValues {
        
        .init(
            currency: "",
            currentValue: currentValue,
            name: "",
            value: value)
    }
}

private extension Double {
    
    static let interval: Self = 15
    static let startAngle: Self = 270

    static let maxAngle: Self = startAngle + 360 - 2 * interval - 1
}
