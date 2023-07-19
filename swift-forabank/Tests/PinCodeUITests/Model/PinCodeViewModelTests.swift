//
//  PinCodeViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

@testable import PinCodeUI

import XCTest
import Foundation

final class PinCodeViewModelTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let viewModel = makeSUT(
            title: "title",
            pincodeLength: 4
        )
                
        XCTAssertEqual(viewModel.title, "title")
        XCTAssertEqual(viewModel.pincodeLength, 4)
        XCTAssertEqual(viewModel.config, PinCodeView.Config.defaultConfig)
        XCTAssertNotNil(viewModel.dots)
        XCTAssertEqual(viewModel.state, .init(state: .empty, title: "title"))
    }
          
    //MARK: - test update dots
    
    func test_updateDots_setFillByValue() {
        
        let sut = makeSUT()
         
        let defaultDots = Array.defaultDotsValue
        
        XCTAssertEqual(sut.dots.count, defaultDots.count)
        
        // all dots isFilled = false
        for index in 0..<sut.dots.count {
            
            XCTAssertEqual(sut.dots[index].isFilled, defaultDots[index].isFilled)
        }
        
        // set two digits -> two dots isFilled = true, two dots isFilled = false
        sut.update(with: "12", pincodeLength: 4)
        
        let defaultDotsFilled = Array.dotsWithTwoFilledValue

        for index in 0..<sut.dots.count {
            
            XCTAssertEqual(sut.dots[index].isFilled, defaultDotsFilled[index].isFilled)
        }
    }
    
    //MARK: - test changeState
    
    func test_changeState_allState() {
        
        let sut = makeSUT()
                 
        XCTAssertEqual(sut.state, .init(state: .empty, title: "title"))
        
        sut.changeState(codeValue: "1")
        
        XCTAssertEqual(sut.state, .init(state: .firstSet(first: "1"), title: "title"))
    
        sut.changeState(codeValue: "12")
        
        XCTAssertEqual(sut.state, .init(state: .firstSet(first: "12"), title: "title"))

        sut.changeState(codeValue: "1234")
        
        XCTAssertEqual(sut.state, .init(state: .confirmSet(first: "1234", second: ""), title: "title"))
    
        sut.changeState(codeValue: "2")
        
        XCTAssertEqual(sut.state, .init(state: .confirmSet(first: "1234", second: "2"), title: "title"))

        sut.changeState(codeValue: "2341")
        
        XCTAssertEqual(sut.state, .init(state: .checkValue(first: "1234", second: "2341"), title: "title"))
        
        sut.changeState(codeValue: "234")
        
        XCTAssertEqual(sut.state, .init(state: .confirmSet(first: "1234", second: "234"), title: "title"))
    }
    
    //TODO: дописать тесты

    //MARK: - test needClearDots
    
    func test_needClearDots() {
        
        let sut = makeSUT()
        
    }

    //MARK: - test updateView
    
    func test_updateView() {
        
        let sut = makeSUT()
        
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
            config: .defaultConfig
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
