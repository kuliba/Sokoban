//
//  RxModelsMappingViewModelTests.swift
//
//
//  Created by Igor Malyarov on 14.01.2024.
//

import RxViewModel
import XCTest

final class RxModelsMappingViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialState() {
        
        let (_, spy) = makeSUT(
            initialState: [.init(id: "a", value: 1)],
            stub: ([], nil)
        )
        
        XCTAssertNoDiff(spy.values, [[.init(id: "a", value: 1)]])
    }
    
    func test_event_shouldAppendNew() {
        
        let (sut, spy) = makeSUT(
            initialState: [.init(id: "a", value: 1)],
            stub: ([.init(id: "a", value: 1), .init(id: "b", value: 3)], nil)
        )
        
        sut.event(.changeValueTo("abc"))
        
        XCTAssertNoDiff(spy.values, [
            [.init(id: "a", value: 1)],
            [.init(id: "a", value: 1), .init(id: "b", value: 3)]
        ])
    }
    
    func test_event_shouldNotChangeStateForExistingID() {
        
        let (sut, spy) = makeSUT(
            initialState: [.init(id: "a", value: 1)],
            stub: ([.init(id: "a", value: 2)], nil)
        )
        
        sut.event(.changeValueTo("abc"))
        
        XCTAssertNoDiff(spy.values, [
            [.init(id: "a", value: 1)],
            [.init(id: "a", value: 1)]
        ])
    }
    
    func test_event_shouldPreserveIdentityOfExisting() throws {
        
        let (sut, _) = makeSUT(
            initialState: [.init(id: "a", value: 1)],
            stub: ([.init(id: "a", value: 2), .init(id: "b", value: 3)], nil)
        )
        let first = try XCTUnwrap(sut.state.first)
        
        sut.event(.changeValueTo("abc"))
        
        XCTAssertTrue(sut.state.first?.model === first.model)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxModelsMappingViewModel<ItemModel, Item, Event, Effect>
    private typealias Spy = ValueSpy<[Item]>
    private typealias ReduceSpy = ReducerSpy<[Item], Event, Effect>
    private typealias EffectHandleSpy = EffectHandlerSpy<Event, Effect>
    
    private func makeSUT(
        initialState: [Item] = [],
        stub: ([Item], Effect?)...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let reducer = ReduceSpy(stub: stub)
        let effectHandler = EffectHandleSpy()
        let observable = SUT.ObservableViewModel(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        let sut = SUT(
            observable: observable,
            map: { .init(model: .init(item: $0)) },
            scheduler: .immediate
        )
        let spy = ValueSpy(sut.$state.map { $0.map(\.model.item) })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private struct Item: Equatable, Identifiable {
        
        let id: String
        let value: Int
    }
    
    private final class Model: ObservableObject {
        
        var item: Item
        
        init(item: Item) { self.item = item }
    }
    
    private struct ItemModel {
        
        let model: Model
        
        var id: Item.ID { model.item.id }
    }
    
    private enum Event: Equatable {
        
        case changeValueTo(String)
        case resetValue
    }
    
    private enum Effect: Equatable {
        
        case load
    }
}
