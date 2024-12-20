//
//  SelectingReducerTests.swift
//  
//
//  Created by Andryusina Nataly on 11.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest

final class SelectingReducerTests: XCTestCase {
    
    //MARK: - init
    
    func test_init_shouldSetOptions() {
        
        let model = makeSUT()
        
        XCTAssertEqual(model.options, .all)
    }
    
    //MARK: - test reduce
    
    func test_sendNewOption_shouldChangeOptionToNew() {
        
        let model = makeSUT()
        let action = ComponentAction.selectOption(.twoWithHtml)
        let state: ComponentState = .monthlyOne
        
        XCTAssertEqual(model.reduce(state, action: action).selectionOption, .twoWithHtml)
    }
    
    func test_sendNewSubscriptionType_shouldChangeSubscriptionTypeToNew() {
        
        let model = makeSUT()
        let action = ComponentAction.selectSubscriptionType(.yearly)
        let state: ComponentState = .monthlyOne
        
        XCTAssertEqual(model.reduce(state, action: action).subscriptionType, .yearly)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SelectingReducer {
        
        let sut: SelectingReducer = .init(
            options: .all
        )
        
        return (sut)
    }
}
