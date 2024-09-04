//
//  CategoryPickerSectionFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import XCTest

final class CategoryPickerSectionFlowEffectHandlerTests: CategoryPickerSectionFlowTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, showAll, showCategory) = makeSUT()
        
        XCTAssertEqual(showAll.callCount, 0)
        XCTAssertEqual(showCategory.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - showAll
    
    func test_showAll_shouldCallShowAllWithEmptyCategoriesOnEmpty() {
        
        let (sut, showAll, _) = makeSUT()
        
        sut.handleEffect(.showAll([])) { _ in }
        
        XCTAssertEqual(showAll.payloads, [[]])
    }
    
    func test_showAll_shouldCallShowAllWithOneCategoryOnOne() {
        
        let category = makeCategory()
        let (sut, showAll, _) = makeSUT()
        
        sut.handleEffect(.showAll([category])) { _ in }
        
        XCTAssertEqual(showAll.payloads, [[category]])
    }
    
    func test_showAll_shouldCallShowAllWithTwoCategoriesOmTwo() {
        
        let (category1, category2) = (makeCategory(), makeCategory())
        let (sut, showAll, _) = makeSUT()
        
        sut.handleEffect(.showAll([category1, category2])) { _ in }
        
        XCTAssertEqual(showAll.payloads, [[category1, category2]])
    }
    
    func test_showAll_shouldDeliverCategoryList() {
        
        let categoryList = makeCategoryList()
        let (sut, showAll, _) = makeSUT()
        
        expect(sut, with: .showAll([]), toDeliver: .receive(.list(categoryList))) {
            
            showAll.complete(with: categoryList)
        }
    }
    
    // MARK: - showCategory
    
    func test_showCategory_shouldCallShowAll() {
        
        let category = makeCategory()
        let (sut, _, showCategory) = makeSUT()
        
        sut.handleEffect(.showCategory(category)) { _ in }
        
        XCTAssertEqual(showCategory.payloads, [category])
    }
    
    func test_showCategory_shouldDeliverCategoryList() {
        
        let model = makeSelectedCategory()
        let (sut, _, showCategory) = makeSUT()
        
        expect(sut, with: .showCategory(makeCategory()), toDeliver: .receive(.category(model))) {
            
            showCategory.complete(with: model)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CategoryPickerSectionFlowEffectHandler<Category, SelectedCategory, CategoryList>
    private typealias ShowAllSpy = Spy<[Category], CategoryList>
    private typealias ShowCategorySpy = Spy<Category, SelectedCategory>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        showAll: ShowAllSpy,
        showCategory: ShowCategorySpy
    ) {
        let showAll = ShowAllSpy()
        let showCategory = ShowCategorySpy()
        let sut = SUT(microServices: .init(
            showAll: showAll.process,
            showCategory: showCategory.process
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(showAll, file: file, line: line)
        trackForMemoryLeaks(showCategory, file: file, line: line)
        
        return (sut, showAll, showCategory)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
