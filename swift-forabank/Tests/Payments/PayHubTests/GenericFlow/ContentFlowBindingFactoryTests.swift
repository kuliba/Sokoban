//
//  ContentFlowBindingFactoryTests.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import CombineSchedulers
import PayHub
import XCTest

final class ContentFlowBindingFactoryTests: XCTestCase {
    
    func test_contentSelect_shouldCallFlowWithSelect() {
        
        let select = makeSelect()
        let (sut, scheduler) = makeSUT(delay: .milliseconds(200))
        let (content, flow, cancellables) = bindSelect(sut, scheduler)
        
        content.send(select)
        
        XCTAssertNoDiff(flow.payloads, [])
        
        scheduler.advance(by: .milliseconds(199))
        XCTAssertNoDiff(flow.payloads, [])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(flow.payloads, [select])
        
        XCTAssertNotNil(cancellables)
    }
    
    func test_flowNavigation_shouldCallContentOnlyWhenNavigationFlipsFromNonNilToNil() {
        
        let (sut, scheduler) = makeSUT(delay: .milliseconds(200))
        let (content, flow, cancellables) = bindNavigation(sut, scheduler)
        
        flow.send(nil)
        
        scheduler.advance(by: .milliseconds(200))
        XCTAssertEqual(content.callCount, 0)
        
        flow.send(nil)
        
        scheduler.advance(by: .milliseconds(200))
        XCTAssertEqual(content.callCount, 0)
        
        flow.send(makeNavigation())
        
        scheduler.advance(by: .milliseconds(200))
        XCTAssertEqual(content.callCount, 0)
        
        flow.send(nil)
        
        XCTAssertEqual(content.callCount, 0)
        
        scheduler.advance(by: .milliseconds(199))
        XCTAssertEqual(content.callCount, 0)
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertEqual(content.callCount, 1)
        
        flow.send(nil)
        
        scheduler.advance(by: .milliseconds(200))
        XCTAssertEqual(content.callCount, 1)
        
        XCTAssertNotNil(cancellables)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ContentFlowBindingFactory
    private typealias Content = PassthroughSubject<Select, Never>
    private typealias ContentSpy = CallSpy<Void, Void>
    private typealias Flow = PassthroughSubject<Navigation?, Never>
    private typealias FlowSpy = CallSpy<Select, Void>
    
    private func makeSUT(
        delay: SUT.Delay,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let sut = SUT(
            delay: delay,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, scheduler)
    }
    
    private func bindSelect(
        _ sut: SUT,
        _ scheduler: TestSchedulerOf<DispatchQueue>
    ) -> (
        content: Content,
        flow: FlowSpy,
        cancellables: Set<AnyCancellable>
    ) {
        let content = Content()
        let flow = FlowSpy(stubs: [(), ()])
        
        let cancellables = sut.bind(
            content: content,
            flow: flow,
            witnesses: selectWitnesses
        )
        
        return (content, flow, cancellables)
    }
    
    private func bindNavigation(
        _ sut: SUT,
        _ scheduler: TestSchedulerOf<DispatchQueue>
    ) -> (
        content: ContentSpy,
        flow: Flow,
        cancellables: Set<AnyCancellable>
    ) {
        let content = ContentSpy(stubs: [(), ()])
        let flow = Flow()
        
        let cancellables = sut.bind(
            content: content,
            flow: flow,
            witnesses: navigationWitnesses
        )
        
        return (content, flow, cancellables)
    }
    
    private let selectWitnesses = ContentFlowWitnesses<Content, FlowSpy, Select, Navigation>(
        contentEmitting: { $0.eraseToAnyPublisher() },
        contentDismissing: { _ in {}},
        flowEmitting: { _ in Empty().eraseToAnyPublisher() },
        flowReceiving: { flow in { flow.call(payload: $0) }}
    )
    
    private let navigationWitnesses = ContentFlowWitnesses<ContentSpy, Flow, Select, Navigation>(
        contentEmitting: { _ in Empty().eraseToAnyPublisher() },
        contentDismissing: { $0.call },
        flowEmitting: { $0.eraseToAnyPublisher() },
        flowReceiving: { _ in { _ in }}
    )
    
    private struct Select: Equatable {
        
        let value: String
    }
    
    private func makeSelect(
        _ value: String = anyMessage()
    ) -> Select {
        
        return .init(value: value)
    }
    
    private struct Navigation: Equatable {
        
        let value: String
    }
    
    private func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
}
