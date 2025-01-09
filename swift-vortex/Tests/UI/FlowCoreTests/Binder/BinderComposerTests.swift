//
//  BinderComposerTests.swift
//
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Combine
import CombineSchedulers
import FlowCore
import XCTest

final class BinderComposerTests: XCTestCase {
    
    func test_compose_shouldSetContent() {
        
        let (sut, content, _) = makeSUT()
        
        let binder = sut.compose()
        
        XCTAssertTrue(binder.content === content)
    }
    
    // MARK: - immediate schedulers
    
    func test_flow_shouldSetNavigationOnContentSelect() {
        
        let select = makeSelect()
        let (sut, _,_) = makeSUT(schedulers: .immediate)
        let binder = sut.compose()
        XCTAssertNil(binder.flow.state.navigation)
        
        binder.content.emit(select)
        
        XCTAssertNoDiff(binder.flow.state.navigation, select)
    }
    
    func test_content_shouldReceiveOnFlowNavigationDismiss() {
        
        let select = makeSelect()
        let (sut, _,_) = makeSUT(schedulers: .immediate)
        let binder = sut.compose()
        XCTAssertEqual(binder.content.receiveCount, 0)
        
        binder.content.emit(select)
        XCTAssertNoDiff(binder.flow.state.navigation, select)
        
        binder.flow.event(.dismiss)
        
        XCTAssertEqual(binder.content.receiveCount, 1)
    }
    
    // MARK: - test schedulers
    
    func test_flow_shouldSetNavigationOnContentSelectWithDelay() {
        
        let select = makeSelect()
        let (sut, _, schedulers) = makeSUT(delay: .milliseconds(500))
        let binder = sut.compose()
        XCTAssertNil(binder.flow.state.navigation)
        
        binder.content.emit(select)
        
        XCTAssertNil(binder.flow.state.navigation)
        
        schedulers.main.advance()
        schedulers.interactive.advance(by: .milliseconds(500))
        schedulers.main.advance()
        
        XCTAssertNoDiff(binder.flow.state.navigation, select)
    }
    
    func test_content_shouldReceiveOnFlowNavigationDismissWithDelay() {
        
        let select = makeSelect()
        let (sut, _, schedulers) = makeSUT(delay: .milliseconds(500))
        let binder = sut.compose()
        XCTAssertEqual(binder.content.receiveCount, 0)
        
        binder.content.emit(select)

        XCTAssertNil(binder.flow.state.navigation)
        
        schedulers.main.advance()
        schedulers.interactive.advance(by: .milliseconds(500))
        schedulers.main.advance()
        
        XCTAssertNoDiff(binder.flow.state.navigation, select)
        
        binder.content.emit(select)
        
        XCTAssertNoDiff(binder.flow.state.navigation, select)
        
        binder.flow.event(.dismiss)
        schedulers.main.advance()
        
        XCTAssertEqual(binder.content.receiveCount, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = BinderComposer<Content, Select, Select>
    
    private func makeSUT(
        delay: SUT.Delay = .milliseconds(200),
        getNavigation: @escaping SUT.Domain.GetNavigation = { $2($0) },
        schedulers: Schedulers? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        content: Content,
        schedulers: TestSchedulers
    ) {
        let content = Content()
        let (test, testSchedulers) = Schedulers.test()
        
        let sut = SUT(
            delay: delay,
            getNavigation: getNavigation,
            makeContent: { content },
            schedulers: schedulers ?? test,
            witnesses: .init(
                emitting: { $0.eventPublisher },
                dismissing: { $0.receive }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(content, file: file, line: line)
        trackForMemoryLeaks(testSchedulers.main, file: file, line: line)
        trackForMemoryLeaks(testSchedulers.interactive, file: file, line: line)
        
        return (sut, content, testSchedulers)
    }
    
    private final class Content {
        
        typealias Event = FlowEvent<Select, Never>
        
        private let eventSubject = PassthroughSubject<Event, Never>()
        private(set) var receiveCount = 0
        
        var eventPublisher: AnyPublisher<Event, Never> {
            
            eventSubject.eraseToAnyPublisher()
        }
        
        func emit(_ event: Event) {
            
            eventSubject.send(event)
        }
        
        func emit(_ select: Select) {
            
            eventSubject.send(.select(select))
        }
        
        func receive() {
            
            receiveCount += 1
        }
    }
    
    private struct Select: Equatable {
        
        let value: String
    }
    
    private func makeSelect(
        _ value: String = anyMessage()
    ) -> Select {
        
        return .init(value: value)
    }
}
