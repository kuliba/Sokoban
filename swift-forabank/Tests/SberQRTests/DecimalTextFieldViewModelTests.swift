//
//  DecimalTextFieldViewModelTests.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import SberQR
import XCTest

final class DecimalTextFieldViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialValuesToZero() {
        
        let (_, textSpy, decimalSpy) = makeSUT()
        
        XCTAssertNoDiff(textSpy.values, ["0 ₽"])
        XCTAssertNoDiff(decimalSpy.values, [0])
    }
    
    func test_type_shouldChangeFormattedText() {
        
        let (sut, textSpy, decimalSpy) = makeSUT()
        
        sut.startEditing()
        sut.type("1", in: .init(location: 0, length: 0))
        
        XCTAssertNoDiff(textSpy.values, ["0 ₽", "0 ₽", "10 ₽"])
        XCTAssertNoDiff(decimalSpy.values, [0, 0, 10])
        
        sut.type("2", in: .init(location: 2, length: 0))
        
        XCTAssertNoDiff(textSpy.values, ["0 ₽", "0 ₽", "10 ₽", "102 ₽"])
        XCTAssertNoDiff(decimalSpy.values, [0, 0, 10, 102])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = DecimalTextFieldViewModel
    private typealias TextSpy = ValueSpy<String?>
    private typealias DecimalSpy = ValueSpy<Decimal>
    
    private func makeSUT(
        currencySymbol: String = "₽",
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        textSpy: TextSpy,
        decimalSpy: DecimalSpy
    ) {
        let locale = Locale(identifier: "en_US@currency=\(currencySymbol)")
        let sut = SUT.decimal(
            currencySymbol: currencySymbol,
            locale: locale,
            scheduler: .immediate
        )
        let textSpy = TextSpy(sut.$state.map(\.text))
        let decimalSpy = DecimalSpy(sut.$state.map(\.decimal))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(textSpy, file: file, line: line)
        trackForMemoryLeaks(decimalSpy, file: file, line: line)
        
        return (sut, textSpy, decimalSpy)
    }
}
