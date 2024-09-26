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
        
        let (sut, _,_,_, _) = makeSUT(prefix: [])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[]])
    }
    
    func test_shouldSetContentStatePrefixWithOneElementOnOneElement() {
        
        let element = makeCategoryPickerItemElement()
        let (sut, _,_,_, _) = makeSUT(prefix: [element])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element]])
    }
    
    func test_shouldSetContentStatePrefixWithOnePlaceholderOnOnePlaceholder() {
        
        let placeholder = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_, _) = makeSUT(prefix: [placeholder])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[placeholder]])
    }
    
    func test_shouldSetContentStatePrefixWithTwoElementsOnTwoElements() {
        
        let element1 = makeCategoryPickerItemElement()
        let element2 = makeCategoryPickerItemElement()
        let (sut, _,_,_, _) = makeSUT(prefix: [element1, element2])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element1, element2]])
    }
    
    func test_shouldSetContentStatePrefixWithTwoPlaceholdersOnTwoPlaceholders() {
        
        let placeholder1 = makeCategoryPickerItemPlaceholder()
        let placeholder2 = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_, _) = makeSUT(prefix: [placeholder1, placeholder2])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[placeholder1, placeholder2]])
    }
    
    func test_shouldSetContentStatePrefixWithElementAndPlaceholderOnElementAndPlaceholder() {
        
        let element = makeCategoryPickerItemElement()
        let placeholder = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_, _) = makeSUT(prefix: [element, placeholder])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element, placeholder]])
    }
    
    // MARK: - suffix
    
    func test_shouldSetEmptyContentStateSuffixOnEmpty() {
        
        let (sut, _,_,_, _) = makeSUT(suffix: [])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[]])
    }
    
    func test_shouldSetContentStateSuffixWithOneElementOnOneElement() {
        
        let element = makeCategoryPickerItemElement()
        let (sut, _,_,_, _) = makeSUT(suffix: [element])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element]])
    }
    
    func test_shouldSetContentStateSuffixWithOnePlaceholderOnOnePlaceholder() {
        
        let placeholder = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_, _) = makeSUT(suffix: [placeholder])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[placeholder]])
    }
    
    func test_shouldSetContentStateSuffixWithTwoElementsOnTwoElements() {
        
        let element1 = makeCategoryPickerItemElement()
        let element2 = makeCategoryPickerItemElement()
        let (sut, _,_,_, _) = makeSUT(suffix: [element1, element2])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element1, element2]])
    }
    
    func test_shouldSetContentStateSuffixWithTwoPlaceholdersOnTwoPlaceholders() {
        
        let placeholder1 = makeCategoryPickerItemPlaceholder()
        let placeholder2 = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_, _) = makeSUT(suffix: [placeholder1, placeholder2])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[placeholder1, placeholder2]])
    }
    
    func test_shouldSetContentStateSuffixWithElementAndPlaceholderOnElementAndPlaceholder() {
        
        let element = makeCategoryPickerItemElement()
        let placeholder = makeCategoryPickerItemPlaceholder()
        let (sut, _,_,_, _) = makeSUT(suffix: [element, placeholder])
        let contentSpy = ValueSpy(sut.content.$state.map(\.items))
        
        XCTAssertNoDiff(contentSpy.values, [[element, placeholder]])
    }
    
    // MARK: - flow
    
    func test_shouldNotChangeFlowNavigationOnContentDeselectEvent() {
        
        let (sut, _,_,_, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.showAll))
        sut.content.event(.select(nil))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll, nil])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_showAll_empty() {
        
        let list = makeCategoryList()
        let (sut, _, showAll, _, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.showAll))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
        XCTAssertNoDiff(showAll.payloads, [[]])
        
        showAll.complete(with: list)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .destination(.list(list))])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_showAll_nonEmpty() {
        
        let (category1, category2) = (makeCategory(), makeCategory())
        let list = makeCategoryList()
        let (sut, _, showAll, _, scheduler) = makeSUT(suffix: [
            .element(.init(.category(category1))),
            .element(.init(.category(category2))),
        ])
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.showAll))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
        XCTAssertNoDiff(showAll.payloads, [[category1, category2]])
        
        showAll.complete(with: list)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .destination(.list(list))])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_category() {
        
        let category = makeCategory()
        let model = makeSelectedCategory()
        let (sut, _,_, showCategory, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.category(category)))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .category(category)])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
        
        showCategory.complete(with: .success(model))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .category(category)])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .destination(.category(model))])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_failure() {
        
        let category = makeCategory()
        let failure = makeFailure()
        let (sut, _,_, showCategory, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.category(category)))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .category(category)])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
        
        showCategory.complete(with: .failure(failure))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .category(category)])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .failure(failure)])
    }
    
    func test_shouldResetContentSelectionOnFlowDismissEvent() {
        
        let list = makeCategoryList()
        let (sut, _, showAll, _, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        
        sut.content.event(.select(.showAll))
        scheduler.advance()
        
        showAll.complete(with: list)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .destination(.list(list))])
        
        sut.flow.event(.dismiss)
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll, nil])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .destination(.list(list)), nil])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = CategoryPickerSectionBinderComposer<Category, SelectedCategory, CategoryList, Failure>
    private typealias Content = Composer.Content
    private typealias Flow = Composer.Flow
    private typealias SUT = Binder<Content, Flow>
    private typealias LoadSpy = Spy<Void, [Composer.Item]>
    private typealias ShowAllSpy = Spy<[Category], CategoryList>
    private typealias ShowCategorySpy = Spy<Category, Result<SelectedCategory, Failure>>
    
    private func makeSUT(
        placeholderCount: Int = 6,
        prefix: [Composer.CategoryPickerItem] = [],
        suffix: [Composer.CategoryPickerItem] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        load: LoadSpy,
        showAll: ShowAllSpy,
        showCategory: ShowCategorySpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let load = LoadSpy()
        let showAll = ShowAllSpy()
        let showCategory = ShowCategorySpy()
        let scheduler = DispatchQueue.test
        let composer = Composer(
            load: load.process(completion:),
            microServices: .init(
                showAll: showAll.process,
                showCategory: showCategory.process
            ),
            placeholderCount: placeholderCount,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose(prefix: prefix, suffix: suffix)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(load, file: file, line: line)
        trackForMemoryLeaks(showAll, file: file, line: line)
        trackForMemoryLeaks(showCategory, file: file, line: line)
        
        return (sut, load, showAll, showCategory, scheduler)
    }
    
    struct Category: Equatable {
        
        let value: String
    }
    
    func makeCategory(
        _ value: String = anyMessage()
    ) -> Category {
        
        return .init(value: value)
    }
    
    struct SelectedCategory: Equatable {
        
        let value: String
    }
    
    func makeSelectedCategory(
        _ value: String = anyMessage()
    ) -> SelectedCategory {
        
        return .init(value: value)
    }
    
    struct CategoryList: Equatable {
        
        let value: String
    }
    
    func makeCategoryList(
        _ value: String = anyMessage()
    ) -> CategoryList {
        
        return .init(value: value)
    }
    
    private func makeCategoryPickerItemElement(
    ) -> Composer.CategoryPickerItem {
        
        return .element(.init(.showAll))
    }
    
    private func makeCategoryPickerItemPlaceholder(
    ) -> Composer.CategoryPickerItem {
        
        return .placeholder(.init())
    }
    
    private struct Failure: Error, Equatable {
        
        let value: String
    }
    
    private func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
    }
}
