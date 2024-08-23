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
    
    func test_shouldNotChangeFlowNavigationOnContentDeselectEvent() {
        
        let (sut, _,_,_, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.destination))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.showAll))
        sut.content.event(.select(nil))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll, nil])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_showAll() {
        
        let list = makeCategoryList()
        let (sut, _, showAll, _, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.destination))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.showAll))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
        
        showAll.complete(with: list)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .list(list)])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_category() {
        
        let category = makeCategory()
        let model = makeCategoryModel()
        let (sut, _,_, showCategory, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.destination))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(.category(category)))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .category(category)])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
        
        showCategory.complete(with: model)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .category(category)])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .category(model)])
    }
    
    func test_shouldResetContentSelectionOnFlowDismissEvent() {
        
        let list = makeCategoryList()
        let (sut, _, showAll, _, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selected))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.destination))
        
        sut.content.event(.select(.showAll))
        scheduler.advance()
        
        showAll.complete(with: list)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .list(list)])
        
        sut.flow.event(.dismiss)
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(contentSpy.values, [nil, .showAll, nil])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .list(list), nil])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = CategoryPickerSectionBinderComposer<Category, CategoryModel, CategoryList>
    private typealias Content = Composer.Content
    private typealias Flow = Composer.Flow
    private typealias SUT = Binder<Content, Flow>
    private typealias LoadSpy = Spy<Void, [Composer.Item]>
    private typealias ShowAllSpy = Spy<Void, CategoryList>
    private typealias ShowCategorySpy = Spy<Category, CategoryModel>
    
    private func makeSUT(
        placeholderCount: Int = 6,
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
        let composer = CategoryPickerSectionBinderComposer(
            load: load.process(completion:),
            microServices: .init(
                showAll: showAll.process,
                showCategory: showCategory.process
            ),
            placeholderCount: placeholderCount,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose()
        
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
    
    struct CategoryModel: Equatable {
        
        let value: String
    }
    
    func makeCategoryModel(
        _ value: String = anyMessage()
    ) -> CategoryModel {
        
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
}
