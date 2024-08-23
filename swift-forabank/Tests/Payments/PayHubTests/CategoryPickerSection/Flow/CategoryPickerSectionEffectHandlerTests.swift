//
//  CategoryPickerSectionEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//
#warning("add binder composer with tests for subscription")

enum CategoryPickerSectionEvent<Category, CategoryList> {
    
    case category(Category)
    case list(CategoryList)
}

extension CategoryPickerSectionEvent: Equatable where Category: Equatable, CategoryList: Equatable {}

enum CategoryPickerSectionEffect<Category> {
    
    case showAll
    case showCategory(Category)
}

extension CategoryPickerSectionEffect: Equatable where Category: Equatable {}

struct CategoryPickerSectionEffectHandlerMicroServices<Category, CategoryModel, CategoryList> {
    
    let showAll: ShowAll
    let showCategory: ShowCategory
}

extension CategoryPickerSectionEffectHandlerMicroServices {
    
    typealias ShowAll = (@escaping (CategoryList) -> Void) -> Void
    typealias ShowCategory = (Category, @escaping (CategoryModel) -> Void) -> Void
}

final class CategoryPickerSectionEffectHandler<Category, CategoryModel, CategoryList> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = CategoryPickerSectionEffectHandlerMicroServices<Category, CategoryModel, CategoryList>
}

extension CategoryPickerSectionEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .showAll:
            microServices.showAll { dispatch(.list($0)) }
            
        case let .showCategory(category):
            microServices.showCategory(category) { dispatch(.category($0)) }
        }
    }
}

extension CategoryPickerSectionEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CategoryPickerSectionEvent<CategoryModel, CategoryList>
    typealias Effect = CategoryPickerSectionEffect<Category>
}

import XCTest

class CategoryPickerSectionTests: XCTestCase {
    
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

final class CategoryPickerSectionEffectHandlerTests: CategoryPickerSectionTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, showAll, showCategory) = makeSUT()
        
        XCTAssertEqual(showAll.callCount, 0)
        XCTAssertEqual(showCategory.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - showAll
    
    func test_showAll_shouldCallShowAll() {
        
        let (sut, showAll, _) = makeSUT()
        
        sut.handleEffect(.showAll) { _ in }
        
        XCTAssertEqual(showAll.callCount, 1)
    }
    
    func test_showAll_shouldDeliverCategoryList() {
        
        let categoryList = makeCategoryList()
        let (sut, showAll, _) = makeSUT()
        
        expect(sut, with: .showAll, toDeliver: .list(categoryList)) {
            
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
        
        let model = makeCategoryModel()
        let (sut, _, showCategory) = makeSUT()
        
        expect(sut, with: .showCategory(makeCategory()), toDeliver: .category(model)) {
            
            showCategory.complete(with: model)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CategoryPickerSectionEffectHandler<Category, CategoryModel, CategoryList>
    private typealias ShowAllSpy = Spy<Void, CategoryList>
    private typealias ShowCategorySpy = Spy<Category, CategoryModel>
    
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
