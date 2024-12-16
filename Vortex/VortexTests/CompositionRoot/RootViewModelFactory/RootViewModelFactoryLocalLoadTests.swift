//
//  RootViewModelFactoryLocalLoadTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.12.2024.
//

@testable import Vortex

class RootViewModelFactoryLocalLoadTests: RootViewModelFactoryTests {
    
    // MARK: - Helpers
    
     typealias LocalAgent = LocalAgentSpy<[Value]>
     typealias Load = () -> [Value]?
    
     func makeSUT(
        loadStub: [Value]? = nil,
        model: Model = .mockWithEmptyExcept(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        logger: LoggerSpy
    ) {
        let localAgent = LocalAgent(loadStub: loadStub)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let (sut, _, logger) = makeSUT(model: model)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(logger, file: file, line: line)
        
        return (sut, logger)
    }
    
     func message(_ message: String) -> LoggerSpy.Event {
        
        return .init(level: .debug, category: .cache, message: message)
    }
    
     struct Value: Equatable, Decodable {
        
        let value: String
    }
    
     func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
}
