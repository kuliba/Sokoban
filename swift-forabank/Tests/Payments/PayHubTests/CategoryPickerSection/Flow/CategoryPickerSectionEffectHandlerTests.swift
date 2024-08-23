//
//  CategoryPickerSectionEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//
#warning("add binder composer with tests for subscription")

struct CategoryPickerSectionState<CategoryModel, CategoryList> {
    
    var destination: Destination?
}

extension CategoryPickerSectionState {
    
    enum Destination {
        
        case category(CategoryModel)
        case list(CategoryList)
    }
}

extension CategoryPickerSectionState: Equatable where CategoryModel: Equatable, CategoryList: Equatable {}
extension CategoryPickerSectionState.Destination: Equatable where CategoryModel: Equatable, CategoryList: Equatable {}

enum CategoryPickerSectionEvent<Category, CategoryModel, CategoryList> {
    
    case receive(Receive)
    case select(Select?)
}

extension CategoryPickerSectionEvent {
    
    enum Receive {
        
        case category(CategoryModel)
        case list(CategoryList)
    }
    
    enum Select {
        
        case category(Category)
        case list
    }
}

extension CategoryPickerSectionEvent: Equatable where Category: Equatable, CategoryModel: Equatable, CategoryList: Equatable {}
extension CategoryPickerSectionEvent.Receive: Equatable where CategoryModel: Equatable, CategoryList: Equatable {}
extension CategoryPickerSectionEvent.Select: Equatable where Category: Equatable, CategoryList: Equatable {}

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
            microServices.showAll { dispatch(.receive(.list($0))) }
            
        case let .showCategory(category):
            microServices.showCategory(category) { dispatch(.receive(.category($0))) }
        }
    }
}

extension CategoryPickerSectionEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CategoryPickerSectionEvent<Category, CategoryModel, CategoryList>
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

final class CategoryPickerSectionReducer<Category, CategoryModel, CategoryList> {}

extension CategoryPickerSectionReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .receive(receive):
            switch receive {
            case let .category(category):
                state.destination = .category(category)
                
            case let .list(list):
                state.destination = .list(list)
            }
            
        case let .select(select):
            state.destination = nil

            switch select {
            case .none:
                break
                
            case let .category(category):
                effect = .showCategory(category)
                
            case .list:
                effect = .showAll
            }
        }
        
        return (state, effect)
    }
}

extension CategoryPickerSectionReducer {
    
    typealias State = CategoryPickerSectionState<CategoryModel, CategoryList>
    typealias Event = CategoryPickerSectionEvent<Category, CategoryModel, CategoryList>
    typealias Effect = CategoryPickerSectionEffect<Category>
}

final class CategoryPickerSectionReducerTests: CategoryPickerSectionTests {
    
    // MARK: - receive
    
    func test_receive_category_shouldSetDestinationToCategory() {
        
        let category = makeCategoryModel()
        
        assert(makeState(destination: nil), event: .receive(.category(category))) {
            
            $0.destination = .category(category)
        }
    }
    
    func test_receive_category_shouldNotDeliverEffect() {
        
        assert(makeState(destination: nil), event: .receive(.category(makeCategoryModel())), delivers: nil)
    }
    
    func test_receive_list_shouldSetDestinationToCategory() {
        
        let list = makeCategoryList()
        
        assert(makeState(destination: nil), event: .receive(.list(list))) {
            
            $0.destination = .list(list)
        }
    }
    
    func test_receive_list_shouldNotDeliverEffect() {
        
        assert(makeState(destination: nil), event: .receive(.list(makeCategoryList())), delivers: nil)
    }
    
    // MARK: - select
    
    func test_deselect_shouldResetCategoryDestination() {
        
        let state = makeState(destination: .category(makeCategoryModel()))
        
        assert(state, event: .select(nil)) {
            
            $0.destination = nil
        }
    }
    
    func test_deselect_shouldNotDeliverEffect() {
        
        let state = makeState(destination: .category(makeCategoryModel()))
        
        assert(state, event: .select(nil), delivers: nil)
    }
    
    func test_select_category_shouldResetDestination() {
        
        let category = makeCategory()
        
        assert(
            makeState(destination: .category(makeCategoryModel())),
            event: .select(.category(category))
        ) {
            $0.destination = nil
        }
    }
    
    func test_select_category_shouldDeliverEffect() {
        
        let category = makeCategory()
        
        assert(makeState(), event: .select(.category(category)), delivers: .showCategory(category))
    }
    
    func test_select_list_shouldResetDestination() {
        
        let category = makeCategory()
        
        assert(
            makeState(destination: .category(makeCategoryModel())),
            event: .select(.list)
        ) {
            $0.destination = nil
        }
    }
    
    func test_select_list_shouldDeliverEffect() {
        
        assert(makeState(), event: .select(.list), delivers: .showAll)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CategoryPickerSectionReducer<Category, CategoryModel, CategoryList>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        destination: SUT.State.Destination? = nil
    ) -> SUT.State {
        
        return .init(destination: destination)
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
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
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
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
        
        expect(sut, with: .showAll, toDeliver: .receive(.list(categoryList))) {
            
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
        
        expect(sut, with: .showCategory(makeCategory()), toDeliver: .receive(.category(model))) {
            
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
