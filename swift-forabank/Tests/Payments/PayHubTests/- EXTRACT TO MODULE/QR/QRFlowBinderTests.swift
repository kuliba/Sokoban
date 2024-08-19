//
//  QRFlowBinderTests.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import Combine
import PayHub
import XCTest

final class QRFlowBinderTests: QRFlowTests {
    
    func test_flowShouldReceiveDismissFromContent() {
        
        let sut = makeSUT()
        
        sut.content.emit(.dismiss)
        
        XCTAssertNoDiff(sut.flow.messages, [.dismiss])
    }
    
    func test_flowShouldReceiveScanResultFromContent() {
        
        let scanResult = makeScanResult()
        let sut = makeSUT()
        
        sut.content.emit(.scanResult(scanResult))
        
        XCTAssertNoDiff(sut.flow.messages, [.scanResult(scanResult)])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRFlowBinder<Content, Flow>
    private typealias Event = QRFlowContentEvent<ScanResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let content = Content()
        let flow = Flow()
        let sut = SUT(content: content, flow: flow)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(content, file: file, line: line)
        trackForMemoryLeaks(flow, file: file, line: line)
        
        return sut
    }
    
    private final class Content: QRFlowContentEventEmitter {
        
        private let subject = PassthroughSubject<Event, Never>()
        
        func emit(_ event: Event) {
            
            subject.send(event)
        }
        
        var qrFlowContentEventPublisher: AnyPublisher<Event, Never> {
            
            subject.eraseToAnyPublisher()
        }
    }
    
    private final class Flow: QRFlowContentEventReceiver {
        
        typealias Message = Int
        
        private(set) var messages = [Event]()
        
        func receive(_ event: Event) {
            
            messages.append(event)
        }
    }
}
