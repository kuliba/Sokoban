//
//  ItemSelectViewModelTests.swift
//  
//
//  Created by Igor Malyarov on 04.06.2023.
//

import Combine
import XCTest

fileprivate typealias IconData = [String: String]
fileprivate typealias Model = ItemSelectModel<Country>
fileprivate typealias ViewModel = IconedItemSelectViewModel<Country, IconData>

@available(macOS 13.0.0, *)
final class IconedItemSelectViewModelTests: XCTestCase {
    
    private let iconDataLoader = PassthroughSubject<IconData, Never>()
    
    // MARK: - init
    
    func test_init_shouldSetToExpandedOnExpanded() {
        
        let (sut, _, scheduler) = makeSUT(
            initialState: .expanded(.all),
            iconDataLoader: iconDataLoader
        )
        let spy = ValueSpy(sut.$state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .init(selectState: .expanded(.all), iconData: [:]),
            .init(selectState: .expanded(.all), iconData: [:]),
        ])
    }
    
    func test_init_shouldSetToCollapsedOnCollapsed() {
        
        let (sut, _, scheduler) = makeSUT(
            initialState: .collapsed,
            iconDataLoader: iconDataLoader
        )
        let spy = ValueSpy(sut.$state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .init(selectState: .collapsed, iconData: [:]),
            .init(selectState: .collapsed, iconData: [:]),
        ])
    }
    
    func test_init_shouldSetToSelectedExpandedOnSelectedExpanded() {
        
        let (sut, _, scheduler) = makeSUT(
            initialState: .selected(.am, listState: .expanded),
            iconDataLoader: iconDataLoader
        )
        let spy = ValueSpy(sut.$state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .init(selectState: .selected(.am, listState: .expanded), iconData: [:]),
            .init(selectState: .selected(.am, listState: .expanded), iconData: [:]),
        ])
    }
    
    func test_init_shouldSetToSelectedCollapsedOnSelectedCollapsed() {
        
        let (sut, _, scheduler) = makeSUT(
            initialState: .selected(.am, listState: .collapsed),
            iconDataLoader: iconDataLoader
        )
        let spy = ValueSpy(sut.$state)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .init(selectState: .selected(.am, listState: .collapsed), iconData: [:]),
            .init(selectState: .selected(.am, listState: .collapsed), iconData: [:]),
        ])
    }
    
    // MARK: - iconDataLoader
    
    func test_iconDataLoader_shouldNotUpdateImagesOnEmpty() {
        
        let (sut, _, scheduler) = makeSUT(
            initialState: .expanded(.all),
            iconDataLoader: iconDataLoader
        )
        let spy = ValueSpy(sut.$state)
        
        iconDataLoader.send([:])
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .init(selectState: .expanded(.all), iconData: [:]),
            .init(selectState: .expanded(.all), iconData: [:]),
        ])
    }
    
    func test_iconDataLoader_shouldUpdateImages() {
        
        let (sut, _, scheduler) = makeSUT(
            initialState: .expanded(.all),
            iconDataLoader: iconDataLoader
        )
        let spy = ValueSpy(sut.$state)
        
        iconDataLoader.send(["a": "b"])
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .init(selectState: .expanded(.all), iconData: [:]),
            .init(selectState: .expanded(.all), iconData: [:]),
            .init(selectState: .expanded(.all), iconData: ["a": "b"]),
        ])
    }
    
    // MARK: - select state changes
    
    func test_itemSelectModel_toggleListVisibility_false_shouldCollapseList2() {
        
        let selectStateLoader = PassthroughSubject<Model.State, Never>()
        let (sut, scheduler) = makeSUT(
            initialState: .expanded(.all),
            iconDataLoader: iconDataLoader,
            selectStateLoader: selectStateLoader
        )
        let spy = ValueSpy(sut.$state)
        
        selectStateLoader.send(.collapsed)
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .init(selectState: .expanded(.all), iconData: [:]),
            .init(selectState: .collapsed, iconData: [:]),
        ])
    }
    
    func test_itemSelectModel_toggleListVisibility_shouldCollapseListFromExpanded() {
        
        let (sut, itemSelectModel, scheduler) = makeSUT(
            initialState: .expanded(.all),
            iconDataLoader: iconDataLoader
        )
        let spy = ValueSpy(sut.$state)
        
        sut.send(.toggleListVisibility)
        scheduler.advance()
        
        XCTAssertNoDiff(itemSelectModel.state, .collapsed)
        XCTAssertNoDiff(spy.values, [
            .init(selectState: .expanded(.all), iconData: [:]),
            .init(selectState: .expanded(.all), iconData: [:]),
            .init(selectState: .collapsed, iconData: [:]),
        ])
    }
    
    func test_itemSelectModel__shouldCollapseList_onCollapse() {
        
        let selectStateLoader = PassthroughSubject<Model.State, Never>()
        let (sut, scheduler) = makeSUT(
            initialState: .expanded(.all),
            iconDataLoader: iconDataLoader,
            selectStateLoader: selectStateLoader
        )
        let spy = ValueSpy(sut.$state)
        
        selectStateLoader.send(.collapsed)
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            .init(selectState: .expanded(.all), iconData: [:]),
            .init(selectState: .collapsed, iconData: [:]),
        ])
    }
    
    func test_pipeline_shape() {
        
        struct State: Equatable {
            let string: String
            let int: Int
        }
        
        let selectState = PassthroughSubject<String, Never>()
        let iconData = PassthroughSubject<Int, Never>()
        let initialState = State(string: "z", int: 0)
        let publisher = Publishers
            .MergeMany(
                selectState
                    .map { (String?.some($0), Int?.none) }
                    .eraseToAnyPublisher()
                ,
                iconData
                    .map { (String?.none, Int?.some($0)) }
                    .eraseToAnyPublisher()
            )
            .scan(initialState) { state, tuple in
                
                    .init(
                        string: tuple.0 ?? state.string,
                        int: tuple.1 ?? state.int
                    )
            }
        let spy = ValueSpy(publisher)
        
        selectState.send("a")
        selectState.send("b")
        iconData.send(1)
        selectState.send("c")
        iconData.send(2)
        selectState.send("d")
        
        XCTAssertNoDiff(spy.values, [
            .init(string: "a", int: 0),
            .init(string: "b", int: 0),
            .init(string: "b", int: 1),
            .init(string: "c", int: 1),
            .init(string: "c", int: 2),
            .init(string: "d", int: 2),
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialState: Model.State,
        iconDataLoader: PassthroughSubject<IconData, Never>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ViewModel,
        itemSelectModel: Model,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let textField = TextFieldSpy<Country>()
        let scheduler = DispatchQueue.test
        let itemSelectModel = Model(
            initialState: initialState,
            items: .all,
            filterKeyPath: \.name,
            textField: textField,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = ViewModel(
            title: "A title",
            initialState: .init(selectState: initialState, iconData: [:]),
            itemSelectModel: itemSelectModel,
            iconDataLoader: iconDataLoader.eraseToAnyPublisher(),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(itemSelectModel, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, itemSelectModel, scheduler)
    }
    
    private func makeSUT(
        initialState: Model.State,
        iconDataLoader: PassthroughSubject<IconData, Never>,
        selectStateLoader: PassthroughSubject<Model.State, Never>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ViewModel,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let textField = TextFieldSpy<Country>()
        let scheduler = DispatchQueue.test
        let sut = ViewModel(
            title: "A title",
            initialState: .init(selectState: initialState, iconData: [:]),
            textField: textField,
            selectStateLoader: selectStateLoader.eraseToAnyPublisher(),
            send: { _ in },
            iconDataLoader: iconDataLoader.eraseToAnyPublisher(),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, scheduler)
    }
}
