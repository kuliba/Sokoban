//
//  BinderComposerPreviewTests.swift
//  BinderComposerPreviewTests
//
//  Created by Igor Malyarov on 14.12.2024.
//

@testable import BinderComposerPreview
import Combine
import CombineSchedulers
import PayHub
import XCTest

final class BinderComposerPreviewTests: XCTestCase {
    
    func test_init_shouldSetToNil() {
        
        let (sut, navigationSpy, destinationSpy, sheetSpy) = makeSUT()
        
        XCTAssertEqual(navigationSpy.values, [nil])
        XCTAssertEqual(destinationSpy.values, [nil])
        XCTAssertEqual(sheetSpy.values, [nil])
        XCTAssertNotNil(sut)
    }
    
    func test_navigationFlow_immediate() throws {
        
        let (sut, navigationSpy, _,_) = makeSUT(schedulers: .immediate)
        
        sut.content.event(.select(.destination))
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination])
        
        try destination(sut).event(.select(.next))
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination])
        
        awaitThreadHop()
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet])
        
        try sheet(sut).event(.select(.next))
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet,])
        
        awaitThreadHop()
        awaitThreadHop()
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet, nil, .destination])
    }
    
    func test_navigationFlow() throws {
        
        let interactiveScheduler = DispatchQueue.test
        let schedulers = Schedulers(
            main: DispatchQueue.immediate.eraseToAnyScheduler(),
            interactive: interactiveScheduler.eraseToAnyScheduler()
        )
        let delay: Delay = .milliseconds(1_000)
        let (sut, navigationSpy, _,_) = makeSUT(delay: delay, schedulers: schedulers)
        
        XCTAssertNoDiff(navigationSpy.values, [nil])
        
        sut.content.event(.select(.destination))
        advance(interactiveScheduler, by: delay)
        advance(interactiveScheduler, by: delay)
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination])
        
        try destination(sut).event(.select(.next))
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination])
        
        awaitThreadHop()
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil])
        
        advance(interactiveScheduler, by: delay)
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet])
        
        try sheet(sut).event(.select(.next))
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet])
        
        awaitThreadHop()
        awaitThreadHop()
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet, nil])
        
        advance(interactiveScheduler, by: delay)
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet, nil, .destination])
    }
    
    func test_destinationAndSheetFlow_immediate() throws {
        
        let (sut, navigationSpy, destinationSpy, sheetSpy) = makeSUT(schedulers: .immediate)
        
        sut.content.event(.select(.destination))
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination])
        XCTAssertNoDiff(destinationSpy.values, [nil, nil, .content])
        XCTAssertNoDiff(sheetSpy.values, [nil, nil, nil])
        
        try destination(sut).event(.select(.next))
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination])
        XCTAssertNoDiff(destinationSpy.values, [nil, nil, .content])
        XCTAssertNoDiff(sheetSpy.values, [nil, nil, nil])
        
        awaitThreadHop()
        awaitThreadHop()
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet])
        XCTAssertNoDiff(destinationSpy.values, [nil, nil, .content, nil, nil])
        XCTAssertNoDiff(sheetSpy.values, [nil, nil, nil, nil, .content])
        
        try sheet(sut).event(.select(.next))
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet,])
        XCTAssertNoDiff(destinationSpy.values, [nil, nil, .content, nil, nil])
        XCTAssertNoDiff(sheetSpy.values, [nil, nil, nil, nil, .content])
        
        awaitThreadHop()
        awaitThreadHop()
        
        XCTAssertNoDiff(navigationSpy.values, [nil, nil, .destination, nil, .sheet, nil, .destination])
        XCTAssertNoDiff(destinationSpy.values, [nil, nil, .content, nil, nil, nil, .content])
        XCTAssertNoDiff(sheetSpy.values, [nil, nil, nil, nil, .content, nil, nil])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootDomain.Binder
    private typealias Delay = RootDomain.BinderComposer.Delay
    private typealias NavigationSpy = ValueSpy<EquatableNavigation?>
    private typealias DestinationSpy = ValueSpy<EquatableDestination?>
    private typealias SheetSpy = ValueSpy<EquatableSheet?>
    
    private func makeSUT(
        delay: Delay = .milliseconds(100),
        schedulers: Schedulers = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        navigationSpy: NavigationSpy,
        destinationSpy: DestinationSpy,
        sheetSpy: SheetSpy
    ) {
        let sut = SUT.default(delay: delay, schedulers: schedulers)
        
        let navigationPublisher = sut.flow.$state.map(\.navigation)
        let navigationSpy = NavigationSpy(navigationPublisher.map { $0.map(self.equatable) })
        let destinationSpy = DestinationSpy(navigationPublisher.map { $0?.destination.map(self.equatable)})
        let sheetSpy = SheetSpy(navigationPublisher.map { $0?.sheet.map(self.equatable)})
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(destinationSpy, file: file, line: line)
        trackForMemoryLeaks(sheetSpy, file: file, line: line)
        
        return (sut, navigationSpy, destinationSpy, sheetSpy)
    }
    
    private func equatable(
        _ navigation: RootDomain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .destination: return .destination
        case .sheet:       return .sheet
        }
    }
    
    private enum EquatableNavigation {
        
        case destination
        case sheet
    }
    
    private func equatable(
        _ navigation: RootDomain.Navigation.Destination
    ) -> EquatableDestination {
        
        switch navigation {
        case .content: return .content
        }
    }
    
    private enum EquatableDestination {
        
        case content
    }
    
    private func equatable(
        _ sheet: RootDomain.Navigation.Sheet
    ) -> EquatableSheet {
        
        switch sheet {
        case .content: return .content
        }
    }
    
    private enum EquatableSheet {
        
        case content
    }
    
    // MARK: - DSL
    
    private func destination(
        _ sut: SUT,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> DestinationDomain.Content {
        
        guard case let .destination(node) = sut.flow.state.navigation
        else { throw NSError(domain: "Expected destination", code: -1) }
        
        return node.model
    }
    
    private func sheet(
        _ sut: SUT,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> DestinationDomain.Content {
        
        guard case let .sheet(node) = sut.flow.state.navigation
        else { throw NSError(domain: "Expected destination", code: -1) }
        
        return node.model
    }
    
    private func advance(
        _ scheduler: TestSchedulerOf<DispatchQueue>,
        by delay: Delay
    ) {
        scheduler.advance(to: .init(.now().advanced(by: delay.timeInterval)))
    }
    
    private func awaitThreadHop(timeout: TimeInterval = 0.01) {
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

extension Schedulers {
    
    static let immediate: Self = .init(
        main: DispatchQueue.immediate.eraseToAnyScheduler(),
        interactive: DispatchQueue.immediate.eraseToAnyScheduler(),
        userInitiated: DispatchQueue.immediate.eraseToAnyScheduler(),
        background: DispatchQueue.immediate.eraseToAnyScheduler()
    )
}
