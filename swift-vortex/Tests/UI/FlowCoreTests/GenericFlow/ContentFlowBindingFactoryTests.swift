//
//  ContentFlowBindingFactoryTests.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import CombineSchedulers
import FlowCore
import XCTest

final class ContentFlowBindingFactoryTests: XCTestCase {
    
    func test_contentSelect_shouldCallFlowWithSelect() {
        
        let select = makeSelect()
        let sut = makeSUT()
        let (content, flow, cancellables) = bindSelect(sut)
        
        content.send(select)
        
        XCTAssertNoDiff(flow.payloads, [select])
        XCTAssertNotNil(cancellables)
    }
    
    func test_flowNavigation_shouldCallContentOnlyWhenNavigationFlipsFromNonNilToNil() {
        
        let sut = makeSUT()
        let (content, flow, cancellables) = bindNavigation(sut)
        
        flow.send(nil)
        
        XCTAssertEqual(content.callCount, 0)
        
        flow.send(nil)
        
        XCTAssertEqual(content.callCount, 0)
        
        flow.send(makeNavigation())
        
        XCTAssertEqual(content.callCount, 0)
        
        flow.send(nil)
        
        XCTAssertEqual(content.callCount, 1)
        
        flow.send(nil)
        
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
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {

        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func bindSelect(
        _ sut: SUT
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
        _ sut: SUT
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
