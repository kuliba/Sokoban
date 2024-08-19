//
//  SomeReducerTests.swift
//
//
//  Created by Igor Malyarov on 19.08.2024.
//

private struct Identified<ID, Element>: Identifiable
where ID: Hashable {
    
    let id: ID
    let element: Element
}

extension Identified: Equatable where Element: Equatable {}

private struct SomeState<ID, Element>
where ID: Hashable {
    
    internal var prefix: [Item]
    internal var suffix: [Item]
    
    init(prefix: [Item], suffix: [Item]) {
        
        self.prefix = prefix
        self.suffix = suffix
    }
}

extension SomeState {
    
    var items: [Item] { prefix + suffix }
    
    enum Item {
        
        case element(Identified<ID, Element>)
        case placeholder(ID)
    }
}

extension SomeState: Equatable where ID: Equatable, Element: Equatable {}
extension SomeState.Item: Equatable where ID: Equatable, Element: Equatable {}

enum SomeEvent: Equatable {
    
    case load
}

enum SomeEffect: Equatable {}

private final class SomeReducer<ID, Element>
where ID: Hashable {
    
    private let makePlaceholders: MakePlaceholders
    
    public init(
        makePlaceholders: @escaping MakePlaceholders
    ) {
        self.makePlaceholders = makePlaceholders
    }
    
    public typealias MakePlaceholders = () -> [ID]
}

extension SomeReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            load(&state, &effect)
        }
        
        return (state, effect)
    }
}

extension SomeReducer {
    
    typealias State = SomeState<ID, Element>
    typealias Event = SomeEvent
    typealias Effect = SomeEffect
}

private extension SomeReducer {
    
    func load(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        state.suffix = makePlaceholders().map { .placeholder($0) }
    }
}

import XCTest

final class SomeReducerTests: XCTestCase {
    
    // MARK: - load
    
    func test_load_shouldPreserveEmptyPrefix_emptyPlaceholders() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [], suffix: [])
            XCTAssertNoDiff($0.items, [])
        }
    }
    
    func test_load_shouldPreserveEmptyPrefix_onePlaceholder() {
        
        let state = makeState(prefix: [])
        let id = makePlaceholderID()
        let sut = makeSUT(placeholderIDs: [id])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [], suffix: [.placeholder(id)])
            XCTAssertNoDiff($0.items, [.placeholder(id)])
        }
    }
    
    func test_load_shouldPreserveEmptyPrefix_twoPlaceholders() {
        
        let state = makeState(prefix: [])
        let (id1, id2) = (makePlaceholderID(), makePlaceholderID())
        let sut = makeSUT(placeholderIDs: [id1, id2])

        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [], suffix: [.placeholder(id1), .placeholder(id2)])
            XCTAssertNoDiff($0.items, [.placeholder(id1), .placeholder(id2)])
        }
    }
    
    func test_load_shouldPreservePrefixOfOne_emptyPlaceholders() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [item], suffix: [])
            XCTAssertNoDiff($0.items, [item])
        }
    }
    
    func test_load_shouldPreservePrefixOfOne_onePlaceholder() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let id = makePlaceholderID()
        let sut = makeSUT(placeholderIDs: [id])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [item], suffix: [.placeholder(id)])
            XCTAssertNoDiff($0.items, [item, .placeholder(id)])
        }
    }
    
    func test_load_shouldPreservePrefixOfOne_twoPlaceholders() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let (id1, id2) = (makePlaceholderID(), makePlaceholderID())
        let sut = makeSUT(placeholderIDs: [id1, id2])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [item], suffix: [.placeholder(id1), .placeholder(id2)])
            XCTAssertNoDiff($0.items, [item, .placeholder(id1), .placeholder(id2)])
        }
    }
    
    func test_load_shouldPreservePrefixOfTwo_emptyPlaceholders() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [item1, item2], suffix: [])
            XCTAssertNoDiff($0.items, [item1, item2])
        }
    }
    
    func test_load_shouldPreservePrefixOfTwo_onePlaceholder() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let id = makePlaceholderID()
        let sut = makeSUT(placeholderIDs: [id])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [item1, item2], suffix: [.placeholder(id)])
            XCTAssertNoDiff($0.items, [item1, item2, .placeholder(id)])
        }
    }
    
    func test_load_shouldPreservePrefixOfTwo_twoPlaceholders() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let (id1, id2) = (makePlaceholderID(), makePlaceholderID())
        let sut = makeSUT(placeholderIDs: [id1, id2])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [item1, item2], suffix: [.placeholder(id1), .placeholder(id2)])
            XCTAssertNoDiff($0.items, [item1, item2, .placeholder(id1), .placeholder(id2)])
        }
    }
    
    // MARK: - Helpers
    
    private typealias ID = UUID
    private typealias SUT = SomeReducer<ID, Element>
    
    private func makeSUT(
        placeholderIDs: [ID],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(makePlaceholders: { placeholderIDs })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        prefix: [SUT.State.Item] = [],
        suffix: [SUT.State.Item] = []
    ) -> SUT.State {
        
        return .init(prefix: prefix, suffix: suffix)
    }
    
    private func makeItem(
        id: ID = .init(),
        _ element: Element? = nil
    ) -> SUT.State.Item {
        
        return .element(.init(id: id, element: element ?? makeElement()))
    }
    
    private func makePlaceholderID() -> ID {
        
        return .init()
    }
    
    private struct Element: Equatable {
        
        let value: String
    }
    
    private func makeElement(
        _ value: String = anyMessage()
    ) -> Element {
        
        return .init(value: value)
    }
    
    @discardableResult
    private func assert(
        sut: SUT,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
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
        sut: SUT,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
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
