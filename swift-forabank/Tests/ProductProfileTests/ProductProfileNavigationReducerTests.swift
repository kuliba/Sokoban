//
//  ProductProfileNavigationReducerTests.swift
//
//
//  Created by Andryusina Nataly on 15.02.2024.
//

@testable import ProductProfile
import XCTest
import UIPrimitives

final class ProductProfileNavigationReducerTests: XCTestCase {
    
    // MARK: test create
    
    func test_create_shouldModalNilEffectCreate() {
        
        let sut = makeSUT()
        
        let (state, effect) = sut.reduce(.init(), .create)
        
        XCTAssertNoDiff(state.modal, nil)
        XCTAssertNoDiff(effect, .create)
    }
    
    typealias SUT = ProductProfileNavigationReducer
    typealias State = SUT.State
    typealias Event = SUT.Event
    typealias Effect = SUT.Effect

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func productProfileState(
        _ modal: SUT.State.ProductProfileRoute? = nil,
        _ alert: AlertModelOf<ProductProfileNavigation.Event>? = nil
    ) -> SUT.State {
        
        .init(
            modal: modal,
            alert: alert
        )
    }
    
    private func reduce(
        _ sut: SUT,
        _ state: State,
        _ event: Event
    ) -> (state: State, effect: Effect?) {
        
        sut.reduce(state, event)
    }
}
