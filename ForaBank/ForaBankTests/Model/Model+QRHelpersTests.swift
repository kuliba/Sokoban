//
//  Model+QRHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 23.07.2024.
//

@testable import ForaBank
import XCTest
final class Model_QRHelpersTests: XCTestCase {
    
    // MARK: - helpers tests
    
    func test_load_shouldDeliverNilOnEmptyStub() {
        
        let sut = makeSUT(operators: nil)
        
        XCTAssertNil(load(sut))
    }
    
    func test_load_shouldDeliverEmptyOnEmptyStub() {
        
        let sut = makeSUT(operators: [])
        
        XCTAssertEqual(load(sut), [])
    }
    
    func test_load_shouldDeliverStub() {
        
        let sut = makeSUT(operators: makeCachingOperators(count: 13))
        
        XCTAssertEqual(load(sut)?.count, 13)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Model
    private typealias CachingOperator = CachingSberOperator
    
    private func makeSUT(
        operators: [CachingOperator]?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let localAgent = try! LocalAgentStub(with: operators)
        let sut = SUT.mockWithEmptyExcept(localAgent: localAgent)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(localAgent, file: file, line: line)
        
        return sut
    }
    
    private func makeCachingOperator(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = anyMessage(),
        title: String = anyMessage(),
        sortedOrder: Int
    ) -> CachingOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, title: title, sortedOrder: sortedOrder)
    }
    
    private func makeCachingOperators(
        count: Int
    ) -> [CachingOperator] {
        
        let operators = (0..<count).enumerated().map { order, _ in
            
            return makeCachingOperator(sortedOrder: order)
        }
        
        precondition(operators.count == count)
        return operators
    }
    
    // MARK: - DSL
    
    private func load(_ sut: SUT) -> [CachingOperator]? {
        
        return sut.localAgent.load(type: [CachingOperator].self)
    }
}
