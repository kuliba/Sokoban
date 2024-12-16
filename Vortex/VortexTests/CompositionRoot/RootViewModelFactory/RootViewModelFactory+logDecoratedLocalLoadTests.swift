//
//  RootViewModelFactory+logDecoratedLocalLoadTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import Vortex
import PayHubUI
import XCTest

final class RootViewModelFactory_logDecoratedLocalLoadTests: RootViewModelFactoryLocalLoadTests {
    
    func test_init_shouldNotCallLoggerForMissingValue() {
        
        let (_, logger) = makeSUT(stub: nil)
        
        XCTAssertEqual(logger.callCount, 0)
    }
    
    func test_init_shouldNotCallLoggerForEmpty() {
        
        let (_, logger) = makeSUT(stub: [])
        
        XCTAssertEqual(logger.callCount, 0)
    }
    
    func test_init_shouldNotCallLoggerForOne() {
        
        let (_, logger) = makeSUT(stub: [makeValue()])
        
        XCTAssertEqual(logger.callCount, 0)
    }
    
    func test_init_shouldNotCallLoggerForTwo() {
        
        let (_, logger) = makeSUT(stub: [makeValue(), makeValue()])
        
        XCTAssertEqual(logger.callCount, 0)
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverNilForMissingValue() {
        
        let (load, _) = makeSUT(stub: nil)
        
        XCTAssertNil(load())
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverMessageForMissingValue() {
        
        let (load, logger) = makeSUT(stub: nil)
        
        _ = load()
        
        XCTAssertNoDiff(logger.events, [
            message("No values for type Array<Value>.")
        ])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverEmptyForEmptyValue() {
        
        let (load, _) = makeSUT(stub: [])
        
        XCTAssertNoDiff(load(), [])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverMessageForEmptyValue() {
        
        let (load, logger) = makeSUT(stub: [])
        
        _ = load()
        
        XCTAssertNoDiff(logger.events, [
            message("No values for type Array<Value>.")
        ])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverOneValueForValueOfOne() {
        
        let value = makeValue()
        let (load, _) = makeSUT(stub: [value])
        
        XCTAssertNoDiff(load(), [value])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverMessageForValueOfOne() {
        
        let value = makeValue()
        let (load, logger) = makeSUT(stub: [value])
        
        _ = load()
        
        XCTAssertNoDiff(logger.events, [
            message("Loaded 1 item(s) of type Array<Value>.")
        ])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverTwoValuesForValueOfTwo() {
        
        let (value1, value2) = (makeValue(), makeValue())
        let (load, _) = makeSUT(stub: [value1, value2])
        
        XCTAssertNoDiff(load(), [value1, value2])
    }
    
    func test_logDecoratedLocalLoad_shouldDeliverMessageForValueOfTwo() {
        
        let (value1, value2) = (makeValue(), makeValue())
        let (load, logger) = makeSUT(stub: [value1, value2])
        
        _ = load()
        
        XCTAssertNoDiff(logger.events, [
            message("Loaded 2 item(s) of type Array<Value>.")
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Load = () -> [Value]?
    
    private func makeSUT(
        stub loadStub: [Value]? = nil,
        model: Model = .mockWithEmptyExcept(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        load: Load,
        logger: LoggerSpy
    ) {
        let (sut, logger) = super.makeSUT(loadStub: loadStub, model: model, file: file, line: line)
        
        let load = { sut.logDecoratedLocalLoad(type: [Value].self) }
        
        return (load, logger)
    }
}
