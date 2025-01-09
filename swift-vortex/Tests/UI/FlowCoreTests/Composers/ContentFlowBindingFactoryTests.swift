//
//  ContentFlowBindingFactoryTests.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import FlowCore
import XCTest

final class ContentFlowBindingFactoryTests: XCTestCase {
    
    func test_init_shouldNotMessage() {
        
        let (content, flow, cancellables) = makeSUT()
        
        XCTAssertEqual(content.callCount, 0)
        XCTAssertEqual(flow.callCount, 0)
        XCTAssertNotNil(cancellables)
    }
    
    // MARK: - Flow to Content
    
    func test_shouldNotMessageContentOnNavigation() {
        
        let (content, flow, cancellables) = makeSUT()
        
        flow.emit(makeNavigation())
        
        XCTAssertEqual(content.callCount, 0)
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldNotMessageContentOnSecondNavigation() {
        
        let (content, flow, cancellables) = makeSUT()
        
        flow.emit(makeNavigation())
        flow.emit(makeNavigation())
        
        XCTAssertEqual(content.callCount, 0)
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldMessageContentOnNilAfterNonNilNavigation() {
        
        let (content, flow, cancellables) = makeSUT()
        
        flow.emit(makeNavigation())
        flow.emit(nil)
        
        XCTAssertEqual(content.callCount, 1)
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldNotMessageContentOnSecondNilAfterNonNilNavigation() {
        
        let (content, flow, cancellables) = makeSUT()
        
        flow.emit(makeNavigation())
        flow.emit(nil)
        flow.emit(nil)
        
        XCTAssertEqual(content.callCount, 1)
        XCTAssertNotNil(cancellables)
    }
    
    // MARK: - Content to Flow
    
    func test_shouldMessageFlowWithIsLoadingTrue_onContentEmittingIsLoadingTrue() {
        
        let (content, flow, cancellables) = makeSUT()
        
        content.emit(.isLoading(true))
        
        XCTAssertNoDiff(flow.received, [.isLoading(true)])
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldMessageFlowWithIsLoadingFalse_onContentEmittingIsLoadingFalse() {
        
        let (content, flow, cancellables) = makeSUT()
        
        content.emit(.isLoading(false))
        
        XCTAssertNoDiff(flow.received, [.isLoading(false)])
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldMessageFlowWithDismiss_onContentEmittingDismiss() {
        
        let (content, flow, cancellables) = makeSUT()
        
        content.emit(.dismiss)
        
        XCTAssertNoDiff(flow.received, [.dismiss])
        XCTAssertNotNil(cancellables)
    }
    
    func test_shouldMessageFlowWithSelect_onContentEmittingSelect() {
        
        let select = makeSelect()
        let (content, flow, cancellables) = makeSUT()
        
        content.emit(.select(select))
        
        XCTAssertNoDiff(flow.received, [.select(select)])
        XCTAssertNotNil(cancellables)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ContentFlowBindingFactory
    private typealias Content = EmitterReceiver<FlowEvent<Select, Never>, Void>
    private typealias Flow = EmitterReceiver<Navigation?, FlowEvent<Select, Never>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        content: Content,
        flow: Flow,
        cancellables: Set<AnyCancellable>
    ) {
        let content = Content()
        let flow = Flow()
        
        trackForMemoryLeaks(content, file: file, line: line)
        trackForMemoryLeaks(flow, file: file, line: line)
        
        let bind = SUT.bind(with: witnesses)
        let cancellables = bind(content, flow)
        
        return (content, flow, cancellables)
    }
    
    private let witnesses = ContentFlowWitnesses<Content, Flow, Select, Navigation>(
        contentEmitting: { $0.publisher },
        contentDismissing: { content in { content.receive(()) }},
        flowEmitting: { $0.publisher },
        flowReceiving: { content in { content.receive($0) }}
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
    
    private final class EmitterReceiver<Emit, Receive> {
        
        private let subject = PassthroughSubject<Emit, Never>()
        private(set) var received = [Receive]()
        
        var callCount: Int { received.count }
        
        var publisher: AnyPublisher<Emit, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ emit: Emit) {
            
            subject.send(emit)
        }
        
        func receive(_ receive: Receive) {
            
            received.append(receive)
        }
    }
}
