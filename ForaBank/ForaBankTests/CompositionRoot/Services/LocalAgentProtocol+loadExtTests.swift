//
//  LocalAgentProtocol+loadExtTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.09.2024.
//

@testable import ForaBank
import XCTest

final class LocalAgentProtocol_loadExtTests: XCTestCase {
    
    func test_load_shouldDeliverNilOnBothNil() {
        
        let sut = makeSUT(loadStub: nil, serialStub: nil)
        
        let loaded: (Value, String?)? = sut.load(type: Value.self)
        
        XCTAssertNil(loaded)
    }
    
    func test_load_shouldDeliverNilOnNilValue() {
        
        let sut = makeSUT(loadStub: nil, serialStub: anyMessage())
        
        let loaded: (Value, String?)? = sut.load(type: Value.self)
        
        XCTAssertNil(loaded)
    }
    
    func test_load_shouldDeliverValueWithNilSerial() {
        
        let value = makeValue()
        let sut = makeSUT(loadStub: value, serialStub: nil)
        
        let loaded: (Value, String?)? = sut.load(type: Value.self)
        
        XCTAssertNoDiff(loaded?.0, value)
        XCTAssertNil(loaded?.1)
    }
    
    func test_load_shouldDeliverValueWithSerial() {
        
        let (value, serial) = (makeValue(), anyMessage())
        let sut = makeSUT(loadStub: value, serialStub: serial)
        
        let loaded: (Value, String?)? = sut.load(type: Value.self)
        
        XCTAssertNoDiff(loaded?.0, value)
        XCTAssertNoDiff(loaded?.1, serial)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LocalAgentProtocol
    
    private func makeSUT(
        loadStub: Value? = nil,
        serialStub: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = LocalAgentSpy(loadStub: loadStub, serialStub: serialStub)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private struct Value: Codable, Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
}
