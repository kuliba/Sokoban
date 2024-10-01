//
//  CategoryPickerSectionBinderComposerTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import CombineSchedulers
import PayHub
import PayHubUI
import XCTest

final class CategoryPickerSectionBinderComposerTests: XCTestCase {
    
    // MARK: - prefix
    
    func test_shouldSetEmptyContentStatePrefixOnEmpty() {
        
        let (sut, _,_,_) = makeSUT(prefix: [])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[]])
    }
    
    func test_shouldSetContentStatePrefixWithOneElementOnOneElement() {
        
        let element = makeCategoryPickerItemElement()
        let (sut, _,_,_) = makeSUT(prefix: [element])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element]])
    }
    
    func test_shouldSetContentStatePrefixWithOnePlaceholderOnOnePlaceholder() {
        
        let placeholder = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_) = makeSUT(prefix: [placeholder])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[placeholder]])
    }
    
    func test_shouldSetContentStatePrefixWithTwoElementsOnTwoElements() {
        
        let element1 = makeCategoryPickerItemElement()
        let element2 = makeCategoryPickerItemElement()
        let (sut, _,_,_) = makeSUT(prefix: [element1, element2])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element1, element2]])
    }
    
    func test_shouldSetContentStatePrefixWithTwoPlaceholdersOnTwoPlaceholders() {
        
        let placeholder1 = makeCategoryPickerItemPlaceholder()
        let placeholder2 = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_) = makeSUT(prefix: [placeholder1, placeholder2])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[placeholder1, placeholder2]])
    }
    
    func test_shouldSetContentStatePrefixWithElementAndPlaceholderOnElementAndPlaceholder() {
        
        let element = makeCategoryPickerItemElement()
        let placeholder = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_) = makeSUT(prefix: [element, placeholder])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element, placeholder]])
    }
    
    // MARK: - suffix
    
    func test_shouldSetEmptyContentStateSuffixOnEmpty() {
        
        let (sut, _,_,_) = makeSUT(suffix: [])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[]])
    }
    
    func test_shouldSetContentStateSuffixWithOneElementOnOneElement() {
        
        let element = makeCategoryPickerItemElement()
        let (sut, _,_,_) = makeSUT(suffix: [element])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element]])
    }
    
    func test_shouldSetContentStateSuffixWithOnePlaceholderOnOnePlaceholder() {
        
        let placeholder = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_) = makeSUT(suffix: [placeholder])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[placeholder]])
    }
    
    func test_shouldSetContentStateSuffixWithTwoElementsOnTwoElements() {
        
        let element1 = makeCategoryPickerItemElement()
        let element2 = makeCategoryPickerItemElement()
        let (sut, _,_,_) = makeSUT(suffix: [element1, element2])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element1, element2]])
    }
    
    func test_shouldSetContentStateSuffixWithTwoPlaceholdersOnTwoPlaceholders() {
        
        let placeholder1 = makeCategoryPickerItemPlaceholder()
        let placeholder2 = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_) = makeSUT(suffix: [placeholder1, placeholder2])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[placeholder1, placeholder2]])
    }
    
    func test_shouldSetContentStateSuffixWithElementAndPlaceholderOnElementAndPlaceholder() {
        
        let element = makeCategoryPickerItemElement()
        let placeholder = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_) = makeSUT(suffix: [element, placeholder])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element, placeholder]])
    }
    
    // MARK: - flow
    
    func test_shouldNotChangeFlowNavigationOnContentDeselectEvent() {
        
        let (sut, _,_, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.list(.init())))
        sut.content.event(.select(nil))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .list(.init()), nil])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_showAll_empty() {
        
        let navigation = makeNavigation()
        let (sut, _, getNavigationSpy, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.list(.init())))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .list(.init())])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
        XCTAssertNoDiff(getNavigationSpy.payloads, [.list([])])
        
        getNavigationSpy.complete(with: navigation)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .list(.init())])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, navigation])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_showAll_nonEmpty() {
        
        let (category1, category2) = (makeCategory(), makeCategory())
        let navigation = makeNavigation()
        let (sut, _, getNavigationSpy, scheduler) = makeSUT(suffix: [
            .element(.init(.category(category1))),
            .element(.init(.category(category2))),
        ])
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.list(.init())))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .list(.init())])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
        XCTAssertNoDiff(getNavigationSpy.payloads, [.list([category1, category2])])
        
        getNavigationSpy.complete(with: navigation)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .list(.init())])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, navigation])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_category() {
        
        let category = makeCategory()
        let navigation = makeNavigation()
        let (sut, _, getNavigationSpy, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.category(category)))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .category(category)])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
        
        getNavigationSpy.complete(with: navigation)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .category(category)])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, navigation])
    }
        
    // MARK: - Helpers
    
    private typealias Domain = CategoryPickerSection<Category, Navigation>
    private typealias Composer = Domain.BinderComposer
    private typealias Content = Domain.ContentDomain.Content
    private typealias Flow = Domain.FlowDomain.Flow
    private typealias SUT = Binder<Content, Flow>
    private typealias LoadSpy = Spy<Void, [Composer.Item]>
    private typealias Select = CategoryPickerSectionItem<Category, [Category]>
    private typealias GetNavigationSpy = Spy<Select, Navigation>
    
    private func makeSUT(
        placeholderCount: Int = 6,
        prefix: [Composer.CategoryPickerItem] = [],
        suffix: [Composer.CategoryPickerItem] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        load: LoadSpy,
        getNavigationSpy: GetNavigationSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let load = LoadSpy()
        let getNavigationSpy = GetNavigationSpy()
        let scheduler = DispatchQueue.test
        let composer = Composer(
            load: load.process(completion:),
            microServices: .init(getNavigation: getNavigationSpy.process),
            placeholderCount: placeholderCount,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose(prefix: prefix, suffix: suffix)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(load, file: file, line: line)
        trackForMemoryLeaks(getNavigationSpy, file: file, line: line)
        
        return (sut, load, getNavigationSpy, scheduler)
    }
    
    struct Category: Equatable {
        
        let value: String
    }
    
    func makeCategory(
        _ value: String = anyMessage()
    ) -> Category {
        
        return .init(value: value)
    }
    
    struct Navigation: Equatable {
        
        let value: String
    }
    
    func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
    
    private func makeCategoryPickerItemElement(
    ) -> Composer.CategoryPickerItem {
        
        return .element(.init(.list(.init())))
    }
    
    private func makeCategoryPickerItemPlaceholder(
    ) -> Composer.CategoryPickerItem {
        
        return .placeholder(.init())
    }
}
