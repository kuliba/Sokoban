//
//  ContentFlowBindingFactoryTests.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class ContentFlowBindingFactory {
    
    private let delay: Delay
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        delay: Delay,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.delay = delay
        self.scheduler = scheduler
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}

extension ContentFlowBindingFactory {
    
    func bind<Content, Flow, Select>(
        content: Content,
        contentWitness: @escaping (Content) -> AnyPublisher<Select, Never>,
        flow: Flow,
        flowWitness: @escaping (Flow) -> (Select) -> Void
    ) -> Set<AnyCancellable> {
        
        let select = contentWitness(content)
            .delay(for: delay, scheduler: scheduler)
            .sink { flowWitness(flow)($0) }
        
        return [select]
    }
}

import XCTest
import CombineSchedulers

final class ContentFlowBindingFactoryTests: XCTestCase {
    
    func test_contentSelect_shouldCallFlowWithSelect() {
        
        let select = makeSelect()
        let (sut, scheduler) = makeSUT(delay: .milliseconds(200))
        let content = PassthroughSubject<Select, Never>()
        let flow = CallSpy<Select, Void>(stubs: [()])
        let cancellables = sut.bind(
            content: content,
            contentWitness: { $0.eraseToAnyPublisher() },
            flow: flow,
            flowWitness: { flow in { flow.call(payload: $0) }}
        )
        
        content.send(select)
        
        XCTAssertNoDiff(flow.payloads, [])
        
        scheduler.advance(by: .milliseconds(199))
        XCTAssertNoDiff(flow.payloads, [])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(flow.payloads, [select])
        
        XCTAssertNotNil(cancellables)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ContentFlowBindingFactory
    
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
    
    private struct Select: Equatable {
        
        let value: String
    }
    
    private func makeSelect(
        _ value: String = anyMessage()
    ) -> Select {
        
        return .init(value: value)
    }
}
