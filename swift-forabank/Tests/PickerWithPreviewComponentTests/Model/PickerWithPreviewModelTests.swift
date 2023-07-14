//
//  PickerWithPreviewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest

final class PickerWithPreviewModelTests: XCTestCase {
    
    //MARK: - test set subscriptionType
    
    func test_init_shouldSetAll() {
        
        let model: PickerWithPreviewModel = .init(
            state: .monthly(
                .init(
                    selection: .oneWithHtml,
                    options: .allWithHtml)
            ),
            options: .all)
        
        XCTAssertEqual(model.state.subscriptionType, .monthly)
        XCTAssertEqual(model.state.subscriptionType.id, .monthly)
        XCTAssertEqual(model.options, .all)
    }
    
    //MARK: - test send for monthly state
    
    func test_sendYearly_shouldSetSubscriptionTypeToYearly() {
        
        let model = makeSUT(state: .monthlyOne)
        
        XCTAssertEqual(model.state.subscriptionType, .monthly)

        model.send(.selectSubscriptionType(.yearly))
        
        XCTAssertEqual(model.state.subscriptionType, .yearly)
    }
    
    func test_sendMonthly_shouldSetSubscriptionTypeToMonthly() {
        
        let model = makeSUT(state: .monthlyOne)
        
        XCTAssertEqual(model.state.subscriptionType, .monthly)

        model.send(.selectSubscriptionType(.monthly))
        
        XCTAssertEqual(model.state.subscriptionType, .monthly)
    }
    
    func test_sendYearlyAndMontly_shouldSetSubscriptionTypeToMontly() {
        
        let model = makeSUT(state: .monthlyOne)
        
        XCTAssertEqual(model.state.subscriptionType, .monthly)

        model.send(.selectSubscriptionType(.yearly))
        
        XCTAssertEqual(model.state.subscriptionType, .yearly)
        
        model.send(.selectSubscriptionType(.monthly))
        
        XCTAssertEqual(model.state.subscriptionType, .monthly)
    }

    func test_sendNewSelectionOption_shouldSetToNewSelectionOption() {
        
        let model = makeSUT(state: .monthlyOne)
        
        XCTAssertEqual(model.state.selectionOption, .oneWithHtml)

        model.send(.selectOption(.twoWithHtml))
        
        XCTAssertEqual(model.state.selectionOption, .twoWithHtml)
    }

    func test_sendInvalidSelectionOptionMontly_shouldRemainOldValue() {
        
        let model = makeSUT(state: .monthlyOne)
        
        XCTAssertEqual(model.state.selectionOption, .oneWithHtml)

        model.send(.selectOption(.fourWithHtml))
        
        XCTAssertEqual(model.state.selectionOption, .oneWithHtml)
    }
    
    //MARK: - test send for yearly state

    func test_yearly_sendMonthly_shouldSetSubscriptionTypeToMonthly() {
        
        let model = makeSUT(state: .yearlyOne)
        
        XCTAssertEqual(model.state.subscriptionType, .yearly)

        model.send(.selectSubscriptionType(.monthly))
        
        XCTAssertEqual(model.state.subscriptionType, .monthly)
    }
    
    func test_yearly_sendYearly_shouldRemainOldValue() {
        
        let model = makeSUT(state: .yearlyOne)
        
        XCTAssertEqual(model.state.subscriptionType, .yearly)

        model.send(.selectSubscriptionType(.yearly))
        
        XCTAssertEqual(model.state.subscriptionType, .yearly)
    }
    
    func test_yearly__sendNewSelectionOption_shouldSetToNewSelectionOption() {
        
        let model = makeSUT(state: .yearlyOne)
        
        XCTAssertEqual(model.state.selectionOption, .oneWithHtml)

        model.send(.selectOption(.twoWithHtml))
        
        XCTAssertEqual(model.state.selectionOption, .twoWithHtml)
    }

    func test_yearly_sendInvalidSelectionOptionYearly_shouldRemainOldValue() {
        
        let model = makeSUT(state: .yearlyOne)
        
        XCTAssertEqual(model.state.subscriptionType, .yearly)
        XCTAssertEqual(model.state.selectionOption, .oneWithHtml)
        
        model.send(.selectOption(.fourWithHtml))
        
        XCTAssertEqual(model.state.subscriptionType, .yearly)
        XCTAssertEqual(model.state.selectionOption, .oneWithHtml)
    }
    
    //MARK: - test send with empty options

    func test_sendInvalidSelectionOptionEmptyOptions_shouldRemainOldValue() {
        
        let model = makeSUTEmptyOptions()
        
        XCTAssertEqual(model.state.subscriptionType, .monthly)
        XCTAssertEqual(model.state.selectionOption, .oneWithHtml)

        model.send(.selectOption(.fourWithHtml))
        
        XCTAssertEqual(model.state.subscriptionType, .monthly)
        XCTAssertEqual(model.state.selectionOption, .oneWithHtml)
    }

    //MARK: - Helpers

    private func makeSUT(
        state: ComponentState,
        file: StaticString = #file,
        line: UInt = #line
    ) -> PickerWithPreviewModel {
        
        let sut: PickerWithPreviewModel = .init(
            state: state,
            options: .all)
        
        trackForMemoryLeaks(sut, file: file, line: line)
            
        return (sut)
    }

    private func makeSUTEmptyOptions(
        file: StaticString = #file,
        line: UInt = #line
    ) -> PickerWithPreviewModel {
        
        let sut: PickerWithPreviewModel = .init(
            state: .monthly(
                .init(
                    selection: .oneWithHtml,
                    options: [])
            ),
            options: .all)
        
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut)
    }
}
