//
//  PinCodeViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

@testable import PinCodeUI

import Combine
import XCTest

final class PinCodeViewModelTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let viewModel = makeSUT(
            title: "title",
            pincodeLength: 4
        )
                
        XCTAssertEqual(viewModel.title, "title")
        XCTAssertEqual(viewModel.pincodeLength, 4)
        XCTAssertNotNil(viewModel.dots)
        XCTAssertEqual(viewModel.state, .init(state: .empty, title: "title"))
    }
    
    //MARK: - test changeState
    
    func test_changeState_allState() {
        
        let sut = makeSUT()
                 
        XCTAssertEqual(sut.state, .init(state: .empty, title: "title"))
        
        sut.changeState(codeValue: "1")
        
        XCTAssertEqual(sut.state, .init(state: .firstSet(first: "1"), title: "title", code: "1"))
    
        sut.changeState(codeValue: "12")
        
        XCTAssertEqual(sut.state, .init(state: .firstSet(first: "12"), title: "title", code: "12"))

        sut.changeState(codeValue: "1234")
        
        XCTAssertEqual(sut.state, .init(state: .confirmSet(first: "1234", second: ""), title: "title", code: ""))
    
        sut.changeState(codeValue: "2")
        
        XCTAssertEqual(sut.state, .init(state: .confirmSet(first: "1234", second: "2"), title: "title", code: "2"))

        sut.changeState(codeValue: "2341")
        
        XCTAssertEqual(sut.state, .init(state: .checkValue(first: "1234", second: "2341"), title: "title", code: "2341"))
        
        sut.changeState(codeValue: "234")
        
        XCTAssertEqual(sut.state, .init(state: .confirmSet(first: "1234", second: "234"), title: "title", code: "234"))
    }
    
    //MARK: - test needClearDots
    
    func test_needClearDots() {
        
        let sut = makeSUT(pincodeLength: 1)
        
        XCTAssertEqual(sut.state, .init(state: .empty, title: "title"))
        
        XCTAssertFalse(sut.needClearDots)

        sut.changeState(codeValue: "1")
        
        XCTAssertTrue(sut.needClearDots)
    }

    //TODO: дописать тесты
    //MARK: - test updateView
    
    func test_updateView() {
        
        let sut = makeSUT()
        
    }
    
    //MARK: - test resetState
    
    func test_resetState() {
        
        let sut = makeSUT()
        
        XCTAssertEqual(sut.state, .init(state: .empty, title: "title"))
        
        sut.changeState(codeValue: "1")
        
        XCTAssertEqual(sut.state, .init(state: .firstSet(first: "1"), title: "title", code: "1"))

        sut.resetState()
        
        XCTAssertEqual(sut.state, .init(state: .empty, title: "title"))
    }

    //MARK: - test clearCodeAndUpdateState
    
    func test_clearCodeAndUpdateState_shouldSetCodeEmptyStateConfirm() {
        
        let sut = makeSUT(pincodeLength: 1)
        
        XCTAssertEqual(sut.state, .init(state: .empty, title: "title"))
        
        sut.changeState(codeValue: "1")
        
        XCTAssertEqual(sut.state, .init(state: .firstSet(first: "1"), title: "title", code: "1"))

        sut.changeState(codeValue: "1")

        sut.clearCodeAndUpdateState()
        
        XCTAssertEqual(sut.state, .init(state: .confirmSet(first: "1", second: ""), title: "title", code: ""))
    }

    //MARK: - Helpers
    
    private func makeSUT(
        title: String = "title",
        pincodeLength: Int = 4,
        file: StaticString = #file,
        line: UInt = #line
    ) -> PinCodeViewModel {
        
        let sut: PinCodeViewModel = .init(
            title: title,
            pincodeLength: pincodeLength,
            getPinConfirm: {_ in }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
            
        return (sut)
    }                       
}

private extension PinCodeViewModel.DotViewModel {
    
    static let defaultValue: Self = .init(isFilled: false)
    static let defaultFilledValue: Self = .init(isFilled: true)

}

private extension Array where Element == PinCodeViewModel.DotViewModel {
    
    static let defaultDotsValue: Self = [
        .defaultValue,
        .defaultValue,
        .defaultValue,
        .defaultValue
    ]
    
    static let dotsWithTwoFilledValue: Self = [
        .defaultFilledValue,
        .defaultFilledValue,
        .defaultValue,
        .defaultValue
    ]
}
