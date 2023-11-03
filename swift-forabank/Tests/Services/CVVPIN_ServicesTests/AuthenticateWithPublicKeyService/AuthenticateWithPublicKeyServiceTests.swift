//
//  AuthenticateWithPublicKeyServiceTests.swift
//  
//
//  Created by Igor Malyarov on 03.11.2023.
//

import CVVPIN_Services
import XCTest

final class AuthenticateWithPublicKeyServiceTests: XCTestCase {
    
    func test_init_shouldNotMessageCollaborators() {
        
        let (_, prepareKeyExchangeSpy, processSpy, makeSessionKeySpy) = makeSUT()
        
        XCTAssertEqual(prepareKeyExchangeSpy.callCount, 0)
        XCTAssertEqual(processSpy.callCount, 0)
        XCTAssertEqual(makeSessionKeySpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AuthenticateWithPublicKeyService
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        prepareKeyExchangeSpy: PrepareKeyExchangeSpy,
        processSpy: ProcessSpy,
        makeSessionKeySpy: MakeSessionKeySpy
    ) {
        
        let prepareKeyExchangeSpy = PrepareKeyExchangeSpy()
        let processSpy = ProcessSpy()
        let makeSessionKeySpy = MakeSessionKeySpy()
        
        let sut = SUT(
            prepareKeyExchange: prepareKeyExchangeSpy.prepare,
            process: processSpy.process,
            makeSessionKey: makeSessionKeySpy.make
        )
        
        trackForMemoryLeaks(sut, file: file, line:  line)
        trackForMemoryLeaks(prepareKeyExchangeSpy, file: file, line:  line)
        trackForMemoryLeaks(processSpy, file: file, line:  line)
        trackForMemoryLeaks(makeSessionKeySpy, file: file, line:  line)
        
        return (sut, prepareKeyExchangeSpy, processSpy, makeSessionKeySpy)
    }
    
    private final class PrepareKeyExchangeSpy {
        
        private(set) var completions = [SUT.PrepareKeyExchangeCompletion]()
        
        var callCount: Int { completions.count }
        
        func prepare(
            completion: @escaping SUT.PrepareKeyExchangeCompletion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: SUT.PrepareKeyExchangeResult,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private final class ProcessSpy {
        
        typealias Message = (data: Data, completion: SUT.ProcessCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func process(
            _ data: Data,
            completion: @escaping SUT.ProcessCompletion
        ) {
            messages.append((data, completion))
        }
        
        func complete(
            with result: SUT.ProcessResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private final class MakeSessionKeySpy {
        
        typealias Message = (response: SUT.Response, completion: SUT.MakeSessionKeyCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func make(
            _ response: SUT.Response,
            completion: @escaping SUT.MakeSessionKeyCompletion
        ) {
            messages.append((response, completion))
        }
        
        func complete(
            with result: SUT.MakeSessionKeyResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
}
