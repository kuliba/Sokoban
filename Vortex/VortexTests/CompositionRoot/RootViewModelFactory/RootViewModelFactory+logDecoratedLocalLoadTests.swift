//
//  RootViewModelFactory+logDecoratedLocalLoadTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import Vortex
import PayHubUI
import XCTest

final class RootViewModelFactory_logDecoratedLocalLoadTests: RootViewModelFactoryTests {
    
    func test_init_shouldNotCallLogger() {
        
        let (_, logger) = makeSUT()
        
        XCTAssertEqual(logger.callCount, 0)
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverNilForMissingValue() {
        
        let (load, _) = makeSUT(loadStub: nil)
        
        XCTAssertNil(load())
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverMessageForMissingValue() {
        
        let (load, logger) = makeSUT(loadStub: nil)
        
        _ = load()
        
        XCTAssertNoDiff(logger.events, [
            message("No values for type Array<Value>.")
        ])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverEmptyForEmptyValue() {
        
        let (load, _) = makeSUT(loadStub: [])
        
        XCTAssertNoDiff(load(), [])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverMessageForEmptyValue() {
        
        let (load, logger) = makeSUT(loadStub: [])
        
        _ = load()
        
        XCTAssertNoDiff(logger.events, [
            message("No values for type Array<Value>.")
        ])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverOneValueForValueOfOne() {
        
        let value = makeValue()
        let (load, _) = makeSUT(loadStub: [value])
        
        XCTAssertNoDiff(load(), [value])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverMessageForValueOfOne() {
        
        let value = makeValue()
        let (load, logger) = makeSUT(loadStub: [value])
        
        _ = load()
        
        XCTAssertNoDiff(logger.events, [
            message("Loaded \(1) item(s) of type Array<Value>.")
        ])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverTwoValuesForValueOfTwo() {
        
        let (value1, value2) = (makeValue(), makeValue())
        let (load, _) = makeSUT(loadStub: [value1, value2])
        
        XCTAssertNoDiff(load(), [value1, value2])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverMessageForValueOfTwo() {
        
        let (value1, value2) = (makeValue(), makeValue())
        let (load, logger) = makeSUT(loadStub: [value1, value2])
        
        _ = load()
        
        XCTAssertNoDiff(logger.events, [
            message("Loaded \(2) item(s) of type Array<Value>.")
        ])
    }
    
    // MARK: - Helpers
    
    private typealias LocalAgent = LocalAgentSpy<[Value]>
    private typealias Load = () -> [Value]?
    
    private func makeSUT(
        loadStub: [Value]? = nil,
        model: Model = .mockWithEmptyExcept(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        load: Load,
        logger: LoggerSpy
    ) {
        let localAgent = LocalAgent(loadStub: loadStub)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let (sut, _, logger) = makeSUT(model: model)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(logger, file: file, line: line)
        
        let load = { sut.logDecoratedLocalLoad(type: [Value].self) }
        
        return (load, logger)
    }
    
    private func message(_ message: String) -> LoggerSpy.Event {
        
        return .init(level: .debug, category: .cache, message: message)
    }
    
    private struct Value: Equatable, Decodable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
}
