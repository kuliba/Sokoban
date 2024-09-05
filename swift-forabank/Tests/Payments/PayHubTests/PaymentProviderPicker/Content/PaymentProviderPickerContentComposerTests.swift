//
//  PaymentProviderPickerContentComposerTests.swift
//
//
//  Created by Igor Malyarov on 02.09.2024.
//

import Combine
import PayHub
import XCTest

final class PaymentProviderPickerContentComposerTests: XCTestCase {
    
    func test_providerList_shouldReceiveTextEmittedBySearch() {
        
        let text = anyMessage()
        let sut = makeSUT()
        
        sut.search?.emit(text)
        
        XCTAssertNoDiff(sut.providerList.messages, [text])
    }
    
    func test_providerList_shouldReceiveEmptyTextEmittedBySearch() {
        
        let sut = makeSUT()
        
        sut.search?.emit("")
        
        XCTAssertNoDiff(sut.providerList.messages, [""])
    }
    
    func test_providerList_shouldReceiveTextsEmittedBySearch() {
        
        let sut = makeSUT()
        
        sut.search?.emit("")
        sut.search?.emit("abc")
        sut.search?.emit("123")
        
        XCTAssertNoDiff(sut.providerList.messages, ["", "abc", "123"])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = PaymentProviderPickerContentComposer<Receiver, Emitter<String>>
    private typealias SUT = PaymentProviderPickerContent<Receiver, Emitter<String>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let composer = Composer()
        let emitter = Emitter<String>()
        let receiver = Receiver()
        let sut = composer.compose(
            providerList: .init(model: receiver, makeReceive: { $0.receive(_:) }),
            search: .init(model: emitter, makePublisher: { $0.publisher })
        )
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(emitter, file: file, line: line)
        trackForMemoryLeaks(receiver, file: file, line: line)
        
        return sut
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
