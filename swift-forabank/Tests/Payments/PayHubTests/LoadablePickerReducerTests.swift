//
//  LoadablePickerReducerTests.swift
//
//
//  Created by Igor Malyarov on 19.08.2024.
//

import PayHub

struct LoadablePickerState<ID, Element>
where ID: Hashable {
    
    internal var prefix: [Item]
    internal var suffix: [Item]
    var selected: Element?
    
    init(
        prefix: [Item],
        suffix: [Item],
        selected: Element? = nil
    ) {
        self.prefix = prefix
        self.suffix = suffix
        self.selected = selected
    }
}

extension LoadablePickerState {
    
    var items: [Item] { prefix + suffix }
    
    enum Item {
        
        case element(Identified<ID, Element>)
        case placeholder(ID)
    }
}

extension LoadablePickerState.Item: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .element(element): return element.id
        case let .placeholder(id):  return id
        }
    }
}

extension LoadablePickerState: Equatable where ID: Equatable, Element: Equatable {}
extension LoadablePickerState.Item: Equatable where ID: Equatable, Element: Equatable {}

enum LoadablePickerEvent<Element> {
    
    case load
    case loaded([Element])
    case select(Element?)
}

extension LoadablePickerEvent: Equatable where Element: Equatable {}

enum LoadablePickerEffect: Equatable {
    
    case load
}

final class LoadablePickerReducer<ID, Element>
where ID: Hashable {
    
    private let makeID: MakeID
    private let makePlaceholders: MakePlaceholders
    
    public init(
        makeID: @escaping MakeID,
        makePlaceholders: @escaping MakePlaceholders
    ) {
        self.makeID = makeID
        self.makePlaceholders = makePlaceholders
    }
    
    public typealias MakeID = () -> ID
    public typealias MakePlaceholders = () -> [ID]
}

extension LoadablePickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            load(&state, &effect)
            
        case let .loaded(elements):
            handleLoaded(&state, &effect, with: elements)
            
        case let .select(element):
            state.selected = element
        }
        
        return (state, effect)
    }
}

extension LoadablePickerReducer {
    
    typealias State = LoadablePickerState<ID, Element>
    typealias Event = LoadablePickerEvent<Element>
    typealias Effect = LoadablePickerEffect
}

private extension LoadablePickerReducer {
    
    func load(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        state.suffix = makePlaceholders().map { .placeholder($0) }
        state.selected = nil
        effect = .load
    }
    
    func handleLoaded(
        _ state: inout State,
        _ effect: inout Effect?,
        with elements: [Element]
    ) {
        state.suffix = state.suffix
            .map(\.id)
            .assignIDs(elements, makeID)
            .map { State.Item.element($0) }
    }
}

// add EffectHandler with tests

import XCTest

final class LoadablePickerReducerTests: LoadablePickerTests {
    
    // MARK: - load
    
    func test_load_shouldSetSelectedToNil() {
        
        let state = makeState(prefix: [], selected: makeElement())
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [], suffix: [], selected: nil)
            XCTAssertNoDiff($0.items, [])
        }
    }
    
    func test_load_shouldPreserveEmptyPrefix_emptyPlaceholders() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .load) {
            
            $0 = self.makeState(prefix: [], suffix: [])
            XCTAssertNoDiff($0.items, [])
        }
    }
    
    func test_load_shouldDeliverEffectOnEmptyPrefix_emptyPlaceholders() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .load, delivers: .load)
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
    
    func test_load_shouldDeliverEffectOnEmptyPrefix_onePlaceholder() {
        
        let state = makeState(prefix: [])
        let id = makePlaceholderID()
        let sut = makeSUT(placeholderIDs: [id])
        
        assert(sut: sut, state, event: .load, delivers: .load)
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
    
    func test_load_shouldDeliverEffectOnEmptyPrefix_twoPlaceholders() {
        
        let state = makeState(prefix: [])
        let (id1, id2) = (makePlaceholderID(), makePlaceholderID())
        let sut = makeSUT(placeholderIDs: [id1, id2])
        
        assert(sut: sut, state, event: .load, delivers: .load)
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
    
    func test_load_shouldDeliverEffectOnPrefixOfOne_emptyPlaceholders() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .load, delivers: .load)
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
    
    func test_load_shouldDeliverEffectOnPrefixOfOne_onePlaceholder() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let id = makePlaceholderID()
        let sut = makeSUT(placeholderIDs: [id])
        
        assert(sut: sut, state, event: .load, delivers: .load)
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
    
    func test_load_shouldDeliverEffectOnPrefixOfOne_twoPlaceholders() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let (id1, id2) = (makePlaceholderID(), makePlaceholderID())
        let sut = makeSUT(placeholderIDs: [id1, id2])
        
        assert(sut: sut, state, event: .load, delivers: .load)
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
    
    func test_load_shouldDeliverEffectOnPrefixOfTwo_emptyPlaceholders() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .load, delivers: .load)
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
    
    func test_load_shouldDeliverEffectOnPrefixOfTwo_onePlaceholder() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let id = makePlaceholderID()
        let sut = makeSUT(placeholderIDs: [id])
        
        assert(sut: sut, state, event: .load, delivers: .load)
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
    
    func test_load_shouldDeliverEffectOnPrefixOfTwo_twoPlaceholders() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let (id1, id2) = (makePlaceholderID(), makePlaceholderID())
        let sut = makeSUT(placeholderIDs: [id1, id2])
        
        assert(sut: sut, state, event: .load, delivers: .load)
    }
    
    // MARK: - loaded
    
    func test_loaded_shouldSetEmptyOnEmptyWithEmptyPrefix() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([])) {
            
            $0 = self.makeState(prefix: [], suffix: [])
            XCTAssertNoDiff($0.items, [])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnEmptyWithEmptyPrefix() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([]), delivers: nil)
    }
    
    func test_loaded_shouldSetOneOnEmptyWithPrefixOfOne() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([])) {
            
            $0 = self.makeState(prefix: [item], suffix: [])
            XCTAssertNoDiff($0.items, [item])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnEmptyWithPrefixOfOne() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([]), delivers: nil)
    }
    
    func test_loaded_shouldSetTwoOnEmptyWithPrefixOfTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([])) {
            
            $0 = self.makeState(prefix: [item1, item2], suffix: [])
            XCTAssertNoDiff($0.items, [item1, item2])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnEmptyWithPrefixOfTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([]), delivers: nil)
    }
    
    func test_loaded_shouldSetOneOnOneWithEmptyPrefix() {
        
        let id = makePlaceholderID()
        let element = makeElement()
        let state = makeState(prefix: [])
        let sut = makeSUT(makeID: { id }, placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([element])) {
            
            $0 = self.makeState(prefix: [], suffix: [.element(.init(id: id, element: element))])
            XCTAssertNoDiff($0.items, [.element(.init(id: id, element: element))])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnOneWithEmptyPrefix() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldAddOneOnOneWithPrefixOfOne() {
        
        let id = makePlaceholderID()
        let element = makeElement()
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT(makeID: { id }, placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([element])) {
            
            $0 = self.makeState(prefix: [item], suffix: [.element(.init(id: id, element: element))])
            XCTAssertNoDiff($0.items, [item, .element(.init(id: id, element: element))])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnOneWithPrefixOfOne() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldAddOneOnOneWithPrefixOfTwo() {
        
        let id = makePlaceholderID()
        let element = makeElement()
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(makeID: { id }, placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([element])) {
            
            $0 = self.makeState(prefix: [item1, item2], suffix: [.element(.init(id: id, element: element))])
            XCTAssertNoDiff($0.items, [item1, item2, .element(.init(id: id, element: element))])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnOneWithPrefixOfTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldSetTwoOnTwoWithEmptyPrefix() {
        
        let id = makePlaceholderID()
        let (element1, element2) = (makeElement(), makeElement())
        let state = makeState(prefix: [])
        let sut = makeSUT(makeID: { id }, placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([element1, element2])) {
            
            $0 = self.makeState(prefix: [], suffix: [
                .element(.init(id: id, element: element1)),
                .element(.init(id: id, element: element2))
            ])
            XCTAssertNoDiff($0.items, [
                .element(.init(id: id, element: element1)),
                .element(.init(id: id, element: element2))
            ])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnTwoWithEmptyPrefix() {
        
        let state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([makeElement(), makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldAddTwoOnTwoWithPrefixOfOne() {
        
        let id = makePlaceholderID()
        let (element1, element2) = (makeElement(), makeElement())
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT(makeID: { id }, placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([element1, element2])) {
            
            $0 = self.makeState(prefix: [item], suffix: [
                .element(.init(id: id, element: element1)),
                .element(.init(id: id, element: element2))
            ])
            XCTAssertNoDiff($0.items, [
                item,
                .element(.init(id: id, element: element1)),
                .element(.init(id: id, element: element2))
            ])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnTwoWithPrefixOfOne() {
        
        let item = makeItem()
        let state = makeState(prefix: [item])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([makeElement(), makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldAddOneOnTwoWithPrefixOfTwo() {
        
        let id = makePlaceholderID()
        let (element1, element2) = (makeElement(), makeElement())
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(makeID: { id }, placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([element1, element2])) {
            
            $0 = self.makeState(prefix: [item1, item2], suffix: [
                .element(.init(id: id, element: element1)),
                .element(.init(id: id, element: element2))
            ])
            XCTAssertNoDiff($0.items, [
                item1,
                item2,
                .element(.init(id: id, element: element1)),
                .element(.init(id: id, element: element2))
            ])
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnTwoWithPrefixOfTwo() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let state = makeState(prefix: [item1, item2])
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .loaded([makeElement(), makeElement()]), delivers: nil)
    }
    
    func test_loaded_shouldReusePlaceholderID() {
        
        let element = makeElement()
        let id = makePlaceholderID()
        var state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: [id])
        
        (state, _) = sut.reduce(state, .load)
        assert(sut: sut, state, event: .loaded([element])) {
            
            $0 = self.makeState(prefix: [], suffix: [
                .element(.init(id: id, element: element))
            ])
        }
    }
    
    func test_loaded_shouldReusePlaceholderIDs() {
        
        let (element1, element2) = (makeElement(), makeElement())
        let (id1, id2) = (makePlaceholderID(), makePlaceholderID())
        var state = makeState(prefix: [])
        let sut = makeSUT(placeholderIDs: [id1, id2])
        
        (state, _) = sut.reduce(state, .load)
        assert(sut: sut, state, event: .loaded([element1, element2])) {
            
            $0 = self.makeState(prefix: [], suffix: [
                .element(.init(id: id1, element: element1)),
                .element(.init(id: id2, element: element2))
            ])
        }
    }
    
    // MARK: - select
    
    func test_select_shouldSetSelectedToNilOnNil() {
        
        let state = makeState(selected: makeElement())
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .select(nil)) {
            
            $0.selected = nil
        }
    }
    
    func test_select_shouldNotDeliverEffectOnSelectedNil() {
        
        let state = makeState(selected: makeElement())
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .select(nil), delivers: nil)
    }
    
    func test_select_shouldSetSelectedToSelected() {
        
        let element = makeElement()
        let state = makeState(selected: nil)
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .select(element)) {
            
            $0.selected = element
        }
    }
    
    func test_select_shouldNotDeliverEffectOnSelected() {
        
        let state = makeState(selected: nil)
        let sut = makeSUT(placeholderIDs: [])
        
        assert(sut: sut, state, event: .select(makeElement()), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Reducer
    
    private func makeSUT(
        makeID: @escaping () -> ID = UUID.init,
        placeholderIDs: [ID],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            makeID: makeID,
            makePlaceholders: { placeholderIDs }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        prefix: [SUT.State.Item] = [],
        suffix: [SUT.State.Item] = [],
        selected: Element? = nil
    ) -> SUT.State {
        
        return .init(prefix: prefix, suffix: suffix, selected: selected)
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
