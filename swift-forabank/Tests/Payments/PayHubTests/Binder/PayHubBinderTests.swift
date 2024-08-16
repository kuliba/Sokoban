//
//  PayHubBinderTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import Combine
import PayHub
import XCTest

final class PayHubBinderTests: PayHubFlowTests {
    
    func test_contentSelect_shouldNotifyFlowWithNil() {
        
        let item: Item? = .none
        let sut = makeSUT()
        
        sut.content.select(item)
        
        XCTAssertNoDiff(sut.flow.messages, [.none])
    }
    
    func test_contentSelect_shouldNotifyFlowWithItem() {
        
        let item: Item? = .exchange
        let sut = makeSUT()
        
        sut.content.select(item)
        
        XCTAssertNoDiff(sut.flow.messages, [item])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PayHubBinder<Content, Flow>
    private typealias Item = PayHubItem<Latest>
    
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
    
    private final class Content: PayHubItemSelector {
        
        private let subject = PassthroughSubject<Item?, Never>()
        
        var selectPublisher: AnyPublisher<Item?, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func select(_ item: Item?) {
            
            subject.send(item)
        }
    }
    
    private final class Flow: PayHubItemReceiver {
        
        private(set) var messages = [Item?]()
        
        func receive(_ item: Item?) {
            
            messages.append(item)
        }
    }
}
