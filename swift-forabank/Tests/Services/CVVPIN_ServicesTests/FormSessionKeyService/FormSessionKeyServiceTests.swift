//
//  FormSessionKeyServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

import CVVPIN_Services
import XCTest

final class FormSessionKeyServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, loadCodeSpy, makeJSONSpy, processSpy, makeSessionKeySpy) = makeSUT()
        
        XCTAssertNoDiff(loadCodeSpy.callCount, 0)
        XCTAssertNoDiff(makeJSONSpy.callCount, 0)
        XCTAssertNoDiff(processSpy.callCount, 0)
        XCTAssertNoDiff(makeSessionKeySpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FormSessionKeyService
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadCodeSpy: LoadCodeSpy,
        makeJSONSpy: MakeJSONSpy,
        processSpy: ProcessSpy,
        makeSessionKeySpy: MakeSessionKeySpy
    ) {
        let loadCodeSpy = LoadCodeSpy()
        let makeJSONSpy = MakeJSONSpy()
        let processSpy = ProcessSpy()
        let makeSessionKeySpy = MakeSessionKeySpy()
        
        let sut = SUT(
            loadCode: loadCodeSpy.load(completion:),
            makeSecretRequestJSON: makeJSONSpy.make(completion:),
            process: processSpy.process,
            makeSessionKey: makeSessionKeySpy.make
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadCodeSpy, file: file, line: line)
        trackForMemoryLeaks(makeJSONSpy, file: file, line: line)
        trackForMemoryLeaks(processSpy, file: file, line: line)
        trackForMemoryLeaks(makeSessionKeySpy, file: file, line: line)
        
        return (sut, loadCodeSpy, makeJSONSpy, processSpy, makeSessionKeySpy)
    }
    
    private final class LoadCodeSpy {
        
        private(set) var completions = [SUT.CodeCompletion]()
        
        var callCount: Int { completions.count }
        
        func load(
            completion: @escaping SUT.CodeCompletion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: SUT.CodeResult,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private final class MakeJSONSpy {
        
        private(set) var completions = [SUT.SecretRequestJSONCompletion]()
        
        var callCount: Int { completions.count }
        
        func make(
            completion: @escaping SUT.SecretRequestJSONCompletion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: SUT.SecretRequestJSONResult,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private final class ProcessSpy {
        
        typealias Message = (payload: SUT.Payload, completion: SUT.ProcessCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func process(
            _ payload: SUT.Payload,
            completion: @escaping SUT.ProcessCompletion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: SUT.ProcessResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private final class MakeSessionKeySpy {
        
        typealias Message = (payload: String, completion: SUT.MakeSessionKeyCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func make(
            _ payload: String,
            completion: @escaping SUT.MakeSessionKeyCompletion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: SUT.MakeSessionKeyResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
}
