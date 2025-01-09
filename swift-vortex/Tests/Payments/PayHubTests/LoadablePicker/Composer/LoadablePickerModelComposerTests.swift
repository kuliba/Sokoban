//
//  LoadablePickerModelComposerTests.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

import PayHub
import XCTest

final class LoadablePickerModelComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, loadSpy, reloadSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertEqual(reloadSpy.callCount, 0)
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
        
        let (sut, loadSpy, _) = makeSUT()
        let content = compose(sut)
        
        content.event(.load)
        
        XCTAssertEqual(loadSpy.callCount, 1)
    }
    
    func test_load_shouldDeliverEmptyLoaded() {
        
        let (sut, loadSpy, _) = makeSUT()
        let content = compose(sut)
        
        content.event(.load)
        loadSpy.complete(with: [])
        
        XCTAssertEqual(content.state.items.count, 0)
    }
    
    func test_load_shouldDeliverOneLoaded() {
        
        let item = makeItem()
        let (sut, loadSpy, _) = makeSUT()
        let content = compose(sut)
        
        content.event(.load)
        loadSpy.complete(with: [item])
        
        XCTAssertEqual(content.state.items.count, 1)
        XCTAssertEqual(content.state.elements, [item])
    }
    
    func test_load_shouldDeliverTwoLoaded() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, loadSpy, _) = makeSUT()
        let content = compose(sut)
        
        content.event(.load)
        loadSpy.complete(with: [item1, item2])
        
        XCTAssertEqual(content.state.items.count, 2)
        XCTAssertEqual(content.state.elements, [item1, item2])
    }
    
    func test_reload_shouldCallReload() {
        
        let (sut, _, reloadSpy) = makeSUT()
        let content = compose(sut)
        
        content.event(.reload)
        
        XCTAssertEqual(reloadSpy.callCount, 1)
    }
    
    func test_reload_shouldDeliverEmptyLoaded() {
        
        let (sut, _, reloadSpy) = makeSUT()
        let content = compose(sut)
        
        content.event(.reload)
        reloadSpy.complete(with: [])
        
        XCTAssertEqual(content.state.items.count, 0)
    }
    
    func test_reload_shouldDeliverOneLoaded() {
        
        let item = makeItem()
        let (sut, _, reloadSpy) = makeSUT()
        let content = compose(sut)
        
        content.event(.reload)
        reloadSpy.complete(with: [item])
        
        XCTAssertEqual(content.state.items.count, 1)
        XCTAssertEqual(content.state.elements, [item])
    }
    
    func test_reload_shouldDeliverTwoLoaded() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, _, reloadSpy) = makeSUT()
        let content = compose(sut)
        
        content.event(.reload)
        reloadSpy.complete(with: [item1, item2])
        
        XCTAssertEqual(content.state.items.count, 2)
        XCTAssertEqual(content.state.elements, [item1, item2])
    }
    
    // MARK: - Helpers
    
    private typealias StateItem = LoadablePickerState<UUID, Item>.Item
    private typealias SUT = LoadablePickerModelComposer<UUID, Item>
    private typealias Model = LoadablePickerModel<UUID, Item>
    private typealias LoadSpy = Spy<Void, [Item]>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy,
        reloadSpy: LoadSpy
    ) {
        let loadSpy = LoadSpy()
        let reloadSpy = LoadSpy()
        let sut = SUT(
            load: loadSpy.process(completion:),
            reload: reloadSpy.process(completion:),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(reloadSpy, file: file, line: line)
        
        return (sut, loadSpy, reloadSpy)
    }
    
    private func compose(
        _ sut: SUT? = nil,
        prefix: [StateItem] = [],
        suffix: [StateItem] = [],
        placeholderCount: Int = .random(in: 1...100),
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
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
