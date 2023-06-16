//
//  TransportPaymentsViewModelTests.swift
//  
//
//  Created by Igor Malyarov on 14.06.2023.
//

import Combine
import XCTest

final class TransportPaymentsViewModel<Item>: ObservableObject
where Item: INNedLocatedNamed {
    
    @Published private(set) var filteredItems: [Item] = []
    
    init(
        items: [Item],
        textFilter: AnyPublisher<String?, Never>,
        regionFilter: AnyPublisher<String?, Never>,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        Publishers.CombineLatest(
            textFilter.prepend(nil),
            regionFilter.prepend(nil)
        )
        .map(Filter<String>.init(text:region:))
        .removeDuplicates()
        .map { [items] in items.filtered(with: $0) }
        .receive(on: scheduler)
        .assign(to: &$filteredItems)
    }
}

extension Filter where Region == String {
    
    init(text: String?, region: String?) {
        
        self.init(textFilter: .init(with: text), region: region)
    }
}

final class TransportPaymentsViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialFilteredValueToEmpty_onEmpty() {
        
        let (_, scheduler, spy) = makeSUT(items: [])
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [[]])
    }
    
    func test_init_shouldSetInitialFilteredValueToAll() {
        
        let (_, scheduler, spy) = makeSUT()
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [.all])
    }
    
    func test_shouldUpdateFilterValueOnTextFilterChange() {
        
        let textFilter = PassthroughSubject<String?, Never>()
        let (_, scheduler, spy) = makeSUT(
            textFilter: textFilter.eraseToAnyPublisher()
        )
        
        setText(to: "Xyz", filter: textFilter, on: scheduler)
        setText(to: "a", filter: textFilter, on: scheduler)
        setText(to: nil, filter: textFilter, on: scheduler)
        setText(to: "bb", filter: textFilter, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .all,
            [],
            [.a],
            .all,
            [.b],
        ])
    }
    
    func test_shouldUpdateFilterValueOnRegionFilterChange() {
        
        let regionFilter = PassthroughSubject<String?, Never>()
        let (_, scheduler, spy) = makeSUT(
            regionFilter: regionFilter.eraseToAnyPublisher()
        )
        
        setText(to: "Xyz", filter: regionFilter, on: scheduler)
        setText(to: "Z", filter: regionFilter, on: scheduler)
        setText(to: nil, filter: regionFilter, on: scheduler)
        setText(to: "Y", filter: regionFilter, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .all,
            [],
            [.d],
            .all,
            [.b, .c],
        ])
    }
    
    func test_shouldUpdateFilterValueOnFiltersChange() {
        
        let text = PassthroughSubject<String?, Never>()
        let region = PassthroughSubject<String?, Never>()
        let (_, scheduler, spy) = makeSUT(
            textFilter: text.eraseToAnyPublisher(),
            regionFilter: region.eraseToAnyPublisher()
        )
        
        setText(to: "Abc", filter: text, on: scheduler)
        setText(to: "Z", filter: region, on: scheduler)
        setText(to: "cc", filter: text, on: scheduler)
        setText(to: "dd", filter: text, on: scheduler)
        setText(to: nil, filter: text, on: scheduler)
        setText(to: "Y", filter: region, on: scheduler)
        setText(to: "bbb", filter: text, on: scheduler)
        setText(to: "3", filter: text, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .all,
            [],
            [],
            [],
            [.d],
            [.d],
            [.b, .c],
            [.b],
            [.c],
        ])
    }
    
    // MARK: - Helpers
    
    private typealias ViewModel = TransportPaymentsViewModel<TestElement>
    private typealias StringFilter = Filter<String>
    
    private func makeSUT(
        items: [TestElement] = .all,
        textFilter: AnyPublisher<String?, Never> = Empty().eraseToAnyPublisher(),
        regionFilter: AnyPublisher<String?, Never> = Empty().eraseToAnyPublisher(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ViewModel,
        scheduler: TestSchedulerOfDispatchQueue,
        spy: ValueSpy<[TestElement]>
    ) {
        let scheduler = DispatchQueue.test
        let sut = ViewModel(
            items: items,
            textFilter: textFilter,
            regionFilter: regionFilter,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$filteredItems.dropFirst())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, scheduler, spy)
    }
    
    // MARK: - DSL
    
    private func setText(
        to text: String?,
        filter: PassthroughSubject<String?, Never>,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        filter.send(text)
        scheduler.advance()
    }
}

private extension Filter where Region == String {
    
    static let empty: Self = .init(textFilter: nil, region: nil)
}
