//
//  CategoryPickerSectionFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import XCTest

final class CategoryPickerSectionFlowReducerTests: CategoryPickerSectionFlowTests {
    
    // MARK: - dismiss
    
    func test_dismiss_shouldResetDestination() {
        
        assert(makeState(destination: .category(makeCategoryModel())), event: .dismiss) {
            
            $0.destination = nil
        }
    }
    
    func test_dismiss_shouldNotNotDeliverEffect() {
        
        assert(
            makeState(destination: .category(makeCategoryModel())),
            event: .dismiss,
            delivers: nil
        )
    }
    
    // MARK: - receive
    
    func test_receive_category_shouldSetDestinationToCategory() {
        
        let category = makeCategoryModel()
        
        assert(makeState(destination: nil), event: .receive(.category(category))) {
            
            $0.destination = .category(category)
        }
    }
    
    func test_receive_category_shouldNotDeliverEffect() {
        
        assert(
            makeState(destination: nil),
            event: .receive(.category(makeCategoryModel())),
            delivers: nil
        )
    }
    
    func test_receive_list_shouldSetDestinationToCategory() {
        
        let list = makeCategoryList()
        
        assert(makeState(destination: nil), event: .receive(.list(list))) {
            
            $0.destination = .list(list)
        }
    }
    
    func test_receive_list_shouldNotDeliverEffect() {
        
        assert(
            makeState(destination: nil),
            event: .receive(.list(makeCategoryList())),
            delivers: nil
        )
    }
    
    // MARK: - select
    
    func test_select_category_shouldResetDestination() {
        
        let category = makeCategory()
        
        assert(
            makeState(destination: .category(makeCategoryModel())),
            event: .select(.category(category))
        ) {
            $0.destination = nil
        }
    }
    
    func test_select_category_shouldDeliverEffect() {
        
        let category = makeCategory()
        
        assert(
            makeState(),
            event: .select(.category(category)),
            delivers: .showCategory(category)
        )
    }
    
    func test_select_list_shouldResetDestination_empty() {
        
        assert(
            makeState(destination: .category(makeCategoryModel())),
            event: .select(.list([]))
        ) {
            $0.destination = nil
        }
    }
    
    func test_select_list_shouldDeliverEffect_empty() {
        
        assert(
            makeState(),
            event: .select(.list([])),
            delivers: .showAll([])
        )
    }
    
    func test_select_list_shouldResetDestination_nonEmpty() {
        
        assert(
            makeState(destination: .category(makeCategoryModel())),
            event: .select(.list([makeCategory()]))
        ) {
            $0.destination = nil
        }
    }
    
    func test_select_list_shouldDeliverEffect_one() {
        
        let category = makeCategory()
        
        assert(
            makeState(),
            event: .select(.list([category])),
            delivers: .showAll([category])
        )
    }
    
    func test_select_list_shouldDeliverEffect_two() {
        
        let (category1, category2) = (makeCategory(), makeCategory())
        
        assert(
            makeState(),
            event: .select(.list([category1, category2])),
            delivers: .showAll([category1, category2])
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CategoryPickerSectionFlowReducer<Category, CategoryModel, CategoryList>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        destination: SUT.State.Destination? = nil
    ) -> SUT.State {
        
        return .init(destination: destination)
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(String(describing: expectedState)), but got \(String(describing: receivedState)) instead.",
            file: file, line: line
        )
        
        return receivedState
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
