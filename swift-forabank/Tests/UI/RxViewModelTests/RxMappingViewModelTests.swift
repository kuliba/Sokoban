//
//  RxMappingViewModelTests.swift
//
//
//  Created by Igor Malyarov on 14.01.2024.
//

@testable import RxViewModel
import XCTest

final class RxMappingViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialState() {
        
        let (sut, stateSpy) = makeSUT(
            initialState: [.init(value: 1)],
            stub: ([.init(value: 2)], nil)
        )
        
        XCTAssertNoDiff(stateSpy.values, [[1]])
        XCTAssertNoDiff(sut.models.map(\.value), ["1"])
    }
    
    func test_event_shouldDeliverStateChange() {
        
        let (sut, stateSpy) = makeSUT(
            initialState: [.init(value: 1)],
            stub: ([.init(value: 2), .init(value: 3)], nil)
        )
        
        sut.event(.changeValueTo("abc"))
        
        XCTAssertNoDiff(stateSpy.values, [[1], [2, 3]])
        XCTAssertNoDiff(sut.models.map(\.value), ["2", "3"])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxMappingViewModel<Model, Item, Event, Effect>
    private typealias StateSpy = ValueSpy<[Int]> // ValueSpy<[State]>
    private typealias ReduceSpy = ReducerSpy<[Item], Event, Effect>
    private typealias EffectHandleSpy = EffectHandlerSpy<Event, Effect>
    
    private func makeSUT(
        initialState: [Item] = [],
        stub: ([Item], Effect?)...,
        observe: @escaping (Item, Item) -> Void = { _,_ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy
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
            map: { .init(value: "\($0.value)") },
            scheduler: .immediate
        )
        let stateSpy = ValueSpy(sut.$state.map { $0.map(\.value) })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        
        return (sut, stateSpy)
    }
    
    private struct Item: Equatable, Identifiable {
        
        let value: Int
        
        var id: Int { value }
    }
    
    private struct Model: Equatable, Identifiable {
        
        let value: String
        
        var id: String { value }
    }
    
    private enum Event: Equatable {
        
        case changeValueTo(String)
        case resetValue
    }
    
    private enum Effect: Equatable {
        
        case load
    }
}
