//
//  PaymentsTransfersToolbarBinderTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Combine
import PayHub
import XCTest

final class PaymentsTransfersToolbarBinderTests: XCTestCase {
    
    func test_flow_shouldReceiveContentSelectEvent_profile() {
        
        let sut = makeSUT()
        
        sut.content.select(.profile)
        
        XCTAssertNoDiff(sut.flow.messages, [.profile])
    }
    
    func test_flow_shouldReceiveContentSelectEvent_qr() {
        
        let sut = makeSUT()
        
        sut.content.select(.qr)
        
        XCTAssertNoDiff(sut.flow.messages, [.qr])
    }
    
    func test_content_shouldReceiveFlowDismissEvent() {
        
        let sut = makeSUT()
        
        sut.flow.dismiss()
        
        XCTAssertNoDiff(sut.content.messages, [.dismiss])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersToolbarBinder<Content, Flow>
    private typealias Selection = PaymentsTransfersToolbarState.Selection
    
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
    
    private final class Content: PaymentsTransfersToolbarContentInterface {
        
        private(set) var messages = [Message]()
        private var subject = PassthroughSubject<Selection, Never>()
        
        var selectionPublisher: AnyPublisher<Selection, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func select(_ selection: Selection) {
            
            subject.send(selection)
        }
        
        func dismiss() {
            
            messages.append(.dismiss)
        }
        
        enum Message {
            
            case dismiss
        }
    }
    
    private final class Flow: PaymentsTransfersToolbarFlowInterface {
        
        private(set) var messages = [Selection]()
        private var subject = PassthroughSubject<Void, Never>()
        
        var dismissEventPublisher: AnyPublisher<Void, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func dismiss() {
            
            subject.send(())
        }
        
        func receive(selection: Selection) {
            
            messages.append(selection)
        }
    }
}
