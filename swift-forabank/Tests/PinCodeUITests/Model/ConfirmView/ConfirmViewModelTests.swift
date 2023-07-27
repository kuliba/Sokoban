//
//  ConfirmViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 25.07.2023.
//

@testable import PinCodeUI

import XCTest

final class ConfirmViewModelTests: XCTestCase {

    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT(
            maxDigits: 4,
            handler: { _, _ in }
        )
        
        XCTAssertEqual(sut.maxDigits, 4)
        XCTAssertFalse(sut.isDisabled)
        XCTAssertNotNil(sut.handler)
    }
    
    //MARK: - test submint
    
    func test_submint_pinEmpty_isDisableFalse() {
        
        let sut = makeSUT()
        
        sut.pin = ""
        
        XCTAssertFalse(sut.isDisabled)

        sut.submitPin()
        
        XCTAssertFalse(sut.isDisabled)
    }

    func test_submint_pinLessMaxDigits_isDisableFalse() {
        
        let sut = makeSUT(maxDigits: 6)
        
        sut.pin = "1234"
        
        XCTAssertFalse(sut.isDisabled)

        sut.submitPin()
        
        XCTAssertFalse(sut.isDisabled)
    }

    func test_submint_pinEqualMaxDigits_isDisableTrue() {
        
        let sut = makeSUT(maxDigits: 6)
        
        sut.pin = "123456"
        
        XCTAssertFalse(sut.isDisabled)

        sut.submitPin()
        
        XCTAssertTrue(sut.isDisabled)
    }

    func test_submint_pinOverMaxDigits_pinCutToMaxDigitsIsDisableTrue() {
        
        let sut = makeSUT(maxDigits: 6)
        
        sut.pin = "1234567"
        
        XCTAssertEqual(sut.pin, "1234567")
        XCTAssertFalse(sut.isDisabled)

        sut.submitPin()
        
        XCTAssertEqual(sut.pin, "123456")
        XCTAssertTrue(sut.isDisabled)
    }
    
    func test_submint_errorCode_shouldSetPinEmptyIsDisableFalse() {
        
        let sut = makeSUT(maxDigits: 6) { _, completionHandler in
            
            completionHandler(false)
        }
        
        sut.pin = "123456"
        
        XCTAssertEqual(sut.pin, "123456")
        XCTAssertFalse(sut.isDisabled)

        sut.submitPin()
        
        XCTAssertEqual(sut.pin, "")
        XCTAssertFalse(sut.isDisabled)
    }

    func test_submint_correctCode_shouldSetIsDisableTrue() {
        
        let sut = makeSUT(maxDigits: 6) { pin, completionHandler in
            
            XCTAssertEqual(pin, "123456")
            completionHandler(true)
        }
        
        sut.pin = "123456"
        
        XCTAssertEqual(sut.pin, "123456")
        XCTAssertFalse(sut.isDisabled)

        sut.submitPin()
        
        XCTAssertEqual(sut.pin, "123456")
        XCTAssertTrue(sut.isDisabled)
    }
    
    //MARK: - test getDigit
    
    func test_getDigit_indexOverPinLength_returnNil() {
        
        let sut = makeSUT(pin: "123")
                
        let digit = sut.getDigit(at: 4)
                
        XCTAssertNil(digit)
    }
    
    func test_getDigit_indexLessPinLength_returnStringDigit() {
        
        let sut = makeSUT(pin: "123")
                
        let digit = sut.getDigit(at: 1)
                
        XCTAssertEqual(digit, "2")
    }

    //MARK: - Helpers

    private func makeSUT(
        pin: String = "",
        maxDigits: Int = 6,
        handler: @escaping (String, @escaping (Bool) -> Void) -> Void = { _, _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfirmViewModel {
        
        let sut: ConfirmViewModel = .init(
            maxDigits: maxDigits,
            pin: pin,
            handler: handler
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
            
        return (sut)
    }
}
