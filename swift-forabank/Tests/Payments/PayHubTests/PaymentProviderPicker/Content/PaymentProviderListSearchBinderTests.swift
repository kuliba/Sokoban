//
//  PaymentProviderListSearchBinderTests.swift
//
//
//  Created by Igor Malyarov on 02.09.2024.
//

import Combine
import PayHub
import XCTest

final class PaymentProviderListSearchBinderTests: XCTestCase {
    
    func test_providerList_shouldReceiveTextEmittedBySearch() {
        
        let text = anyMessage()
        let (search, providerList, subscription) = makeSUT()
        
        search.emit(text)
        
        XCTAssertNoDiff(providerList.messages, [text])
        XCTAssertNotNil(subscription)
    }
    
    func test_providerList_shouldReceiveEmptyTextEmittedBySearch() {
        
        let (search, providerList, subscription) = makeSUT()
        
        search.emit("")
        
        XCTAssertNoDiff(providerList.messages, [""])
        XCTAssertNotNil(subscription)
    }
    
    func test_providerList_shouldReceiveTextsEmittedBySearch() {
        
        let (search, providerList, subscription) = makeSUT()
        
        search.emit("")
        search.emit("abc")
        search.emit("123")
        
        XCTAssertNoDiff(providerList.messages, ["", "abc", "123"])
        XCTAssertNotNil(subscription)
    }
    
    // MARK: - Helpers
    
    private typealias Binder = PaymentProviderListSearchBinder<Receiver, Emitter<String>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        emitter: Emitter<String>,
        receiver: Receiver,
        subscription: Set<AnyCancellable>
    ) {
        let emitter = Emitter<String>()
        let receiver = Receiver()
        let subscription = Binder.bind(
            providerList: .init(model: receiver, makeReceive: { $0.receive(_:) }),
            search: .init(model: emitter, makePublisher: { $0.publisher })
        )
        
        trackForMemoryLeaks(emitter, file: file, line: line)
        trackForMemoryLeaks(receiver, file: file, line: line)
        
        return (emitter, receiver, subscription)
    }
    
    private final class Receiver {
        
        private(set) var messages = [String]()
        
        func receive(_ message: String) {
            
            messages.append(message)
        }
    }
    
    private final class Emitter<Value> {
        
        private let subject = PassthroughSubject<Value, Never>()
        
        func emit(_ value: Value) {
            
            subject.send(value)
        }
        
        var publisher: AnyPublisher<Value, Never> {
            
            subject.eraseToAnyPublisher()
        }
    }
}
