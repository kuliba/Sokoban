//
//  LoadablePickerContentComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 20.08.2024.
//

@testable import ForaBank
import PayHub
import XCTest

final class LoadablePickerContentComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - compose
    
    func test_compose_shouldSetEmptyPrefixOnEmptyPrefixEmptySuffix() {
        
        let content = compose(prefix: [])
        
        XCTAssertNoDiff(content.state.items, [])
    }
    
    func test_compose_shouldSetOneOnPrefixOfOneEmptySuffix() {
        
        let item = StateItem.placeholder(.init())
        let content = compose(prefix: [item])
        
        XCTAssertNoDiff(content.state.items, [item])
    }
    
    func test_compose_shouldSetTwoOnPrefixOfTwoEmptySuffix() {
        
        let (item1, item2) = (StateItem.placeholder(.init()), StateItem.placeholder(.init()))
        let content = compose(prefix: [item1, item2])
        
        XCTAssertNoDiff(content.state.items, [item1, item2])
    }
    
    func test_compose_shouldSetTwoOnPrefixOfOneSuffixOfOne() {
        
        let (item1, item2) = (StateItem.placeholder(.init()), StateItem.placeholder(.init()))
        let content = compose(prefix: [item1], suffix: [item2])
        
        XCTAssertNoDiff(content.state.items, [item1, item2])
    }
    
    func test_compose_shouldSetTwoOnEmptyPrefixSuffixOfTwo() {
        
        let (item1, item2) = (StateItem.placeholder(.init()), StateItem.placeholder(.init()))
        let content = compose(suffix: [item1, item2])
        
        XCTAssertNoDiff(content.state.items, [item1, item2])
    }
    
    func test_compose_shouldNotAddPlaceholdersOnZero() {
        
        let content = compose(placeholderCount: 0)
        
        content.event(.load)
        
        XCTAssertNoDiff(content.state.items, [])
    }
    
    func test_compose_shouldAddOnePlaceholderOnOne() {
        
        let content = compose(placeholderCount: 1)
        
        content.event(.load)
        
        XCTAssertNoDiff(content.state.items.count, 1)
    }
    
    func test_compose_shouldAddTwoPlaceholdersOnTwo() {
        
        let content = compose(placeholderCount: 2)
        
        content.event(.load)
        
        XCTAssertNoDiff(content.state.items.count, 2)
    }
    
    func test_compose_shouldAddPlaceholderToPrefix() {
        
        let (item1, item2) = (StateItem.element(.init(makeItem())), StateItem.element(.init(makeItem())))
        let content = compose(prefix: [item1, item2], placeholderCount: 1)
        
        content.event(.load)
        
        XCTAssertNoDiff(content.state.items.count, 3)
        XCTAssertNoDiff([item1, item2], content.state.items.prefix(2))
    }
    
    func test_compose_shouldAddPlaceholderInsteadOfSuffixToPrefixAndSuffix() {
        
        let (item1, item2) = (StateItem.element(.init(makeItem())), StateItem.element(.init(makeItem())))
        let content = compose(prefix: [item1], suffix: [item2], placeholderCount: 1)
        
        content.event(.load)
        
        XCTAssertNoDiff(content.state.items.count, 2)
        XCTAssertNotEqual([item1, item2], content.state.items)
    }
    
    func test_load_shouldCallLoad() {
        
        let (sut, spy) = makeSUT()
        let content = compose(sut)

        content.event(.load)
        
        XCTAssertEqual(spy.callCount, 1)
    }
    
    func test_load_shouldDeliverEmptyLoaded() {
        
        let (sut, spy) = makeSUT()
        let content = compose(sut)

        content.event(.load)
        spy.complete(with: [])
        
        XCTAssertEqual(content.state.items.count, 0)
    }
    
    func test_load_shouldDeliverOneLoaded() {
        
        let item = makeItem()
        let (sut, spy) = makeSUT()
        let content = compose(sut)

        content.event(.load)
        spy.complete(with: [item])
        
        XCTAssertEqual(content.state.items.count, 1)
        XCTAssertEqual(content.state.elements, [item])
    }
    
    func test_load_shouldDeliverTwoLoaded() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, spy) = makeSUT()
        let content = compose(sut)

        content.event(.load)
        spy.complete(with: [item1, item2])
        
        XCTAssertEqual(content.state.items.count, 2)
        XCTAssertEqual(content.state.elements, [item1, item2])
    }
    
    // MARK: - Helpers
    
    private typealias StateItem = LoadablePickerState<UUID, Item>.Item
    private typealias SUT = LoadablePickerContentComposer<Item>
    private typealias Content = LoadablePickerContent<Item>
    private typealias LoadSpy = Spy<Void, [Item], Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LoadSpy
    ) {
        let spy = LoadSpy()
        let sut = SUT(
            load: spy.process(completion:),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func compose(
        _ sut: SUT? = nil,
        prefix: [StateItem] = [],
        suffix: [StateItem] = [],
        placeholderCount: Int = .random(in: 1...100),
        file: StaticString = #file,
        line: UInt = #line
    ) -> Content {
        
        let sut = sut ?? makeSUT(file: file, line: line).sut
        return sut.compose(
            prefix: prefix,
            suffix: suffix,
            placeholderCount: placeholderCount
        )
    }
    
    private struct Item: Equatable {
        
        let value: String
    }
    
    private func makeItem(
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(value: value)
    }
}

// MARK: - DSL

private extension LoadablePickerState {
    
    var elements: [Element] {
        
        items.compactMap {
            
            guard case let .element(identified) = $0
            else { return nil }
            
            return identified.element
        }
    }
}
