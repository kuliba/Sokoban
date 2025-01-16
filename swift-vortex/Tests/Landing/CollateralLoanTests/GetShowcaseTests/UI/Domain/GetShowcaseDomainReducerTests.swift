//
//  GetShowcaseDomainReducerTests.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

@testable import CollateralLoanLandingGetShowcaseUI
import XCTest

final class GetShowcaseDomainReducerTests: XCTestCase {

    func test_reduce_when_load() {
        
        let sut = makeSUT()
        let (state, effect) = sut.reduce(.init(isLoading: false), .load)
        
        XCTAssertTrue(state.isLoading)
        XCTAssertEqual(effect, .load)
    }
    
    func test_reduce_when_loaded() {
        
        let sut = makeSUT()
        let (state, effect) = sut.reduce(
            .init(isLoading: false),
            .loaded(.failure(.init()))
        )
        
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(effect)
    }

    func test_reduce_when_productTap() {
        
        let sut = makeSUT()
        let (state, effect) = sut.reduce(
            .init(isLoading: true),
            .loaded(.failure(.init()))
        )
        
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(effect)
    }

    private typealias SUT = GetShowcaseDomain.Reducer
    
    private func makeSUT() -> SUT {
        SUT()
    }
}
