//
//  Model+loadOperatorsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.02.2024.
//

@testable import ForaBank
import OperatorsListComponents
import XCTest

private typealias SUT = Model

//final class Model_loadOperatorsTests: XCTestCase {
//    
//    func test_loadOperators_shouldDeliverEmptyOnEmpty() throws {
//        
//        let payload = makeLoadOperatorsPayload()
//        let sut = try makeSUT(stub: [])
//        
//        expect(sut, with: payload, toDeliver: .success([]))
//    }
//    
//    func test_loadOperators_shouldDeliverFirstPageOnNilOperatorID() throws {
//        
//        let payload = makeLoadOperatorsPayload(
//            operatorID: nil,
//            pageSize: 2
//        )
//        let sut = try makeSUT(names: [
//            "b", "a", "c", "d", "e"
//        ])
//        
//        expect(sut, with: payload, toDeliver: .success(["b", "a"]))
//    }
//    
//    func test_loadOperators_shouldDeliverPageAfterOperatorID() throws {
//        
//        let payload = makeLoadOperatorsPayload(
//            operatorID: "a",
//            pageSize: 2
//        )
//        let sut = try makeSUT(names: [
//            "b", "a", "c", "d", "e"
//        ])
//        
//        expect(sut, with: payload, toDeliver: .success(["c", "d"]))
//    }
//    
//    func test_loadOperators_shouldDeliverPageFromStartOnNilOperatorIDWithSearch() throws {
//        
//        let payload = makeLoadOperatorsPayload(
//            operatorID: nil,
//            searchText: "aa",
//            pageSize: 2
//        )
//        let sut = try makeSUT(names: [
//            "b", "a", "aa", "c", "aaa", "aaaa", "d", "e"
//        ])
//        
//        expect(sut, with: payload, toDeliver: .success(["aa", "aaa"]))
//    }
//    
//    func test_loadOperators_shouldDeliverEmptyPageAfterMissingOperatorIDWithSearch_2() throws {
//        
//        let payload = makeLoadOperatorsPayload(
//            operatorID: "a",
//            searchText: "aa",
//            pageSize: 2
//        )
//        let sut = try makeSUT(names: [
//            "b", "a", "aa", "c", "aaa", "aaaa", "d", "e"
//        ])
//        
//        expect(sut, with: payload, toDeliver: .success([]))
//    }
//    
//    func test_loadOperators_shouldDeliverPageAfterOperatorIDWithSearch_3() throws {
//        
//        let payload = makeLoadOperatorsPayload(
//            operatorID: "aa",
//            searchText: "aa",
//            pageSize: 2
//        )
//        let sut = try makeSUT(names: [
//            "b", "a", "aa", "c", "aaa", "aaaa", "d", "e"
//        ])
//        
//        expect(sut, with: payload, toDeliver: .success(["aaa", "aaaa"]))
//    }
//    
//    // MARK: - Helpers
//    
//    private func makeSUT(
//        names: [String],
//        file: StaticString = #file,
//        line: UInt = #line
//    ) throws -> SUT {
//        
//        try makeSUT(stub: .stub(titles: names))
//    }
//    
//    private func makeSUT(
//        stub: [_OperatorGroup] = .stub(),
//        file: StaticString = #file,
//        line: UInt = #line
//    ) throws -> SUT {
//        
//        let sut: SUT = try .mockWithEmptyExcept(
//            localAgent: LocalAgentStub(
//                type: [_OperatorGroup].self,
//                value: stub
//            )
//        )
//        
//        trackForMemoryLeaks(sut, file: file, line: line)
//        
//        return sut
//    }
//    
//    private func makeLoadOperatorsPayload(
//        operatorID: OperatorsListComponents.Operator.ID? = nil,
//        searchText: String = "",
//        pageSize: Int = 10
//    ) -> LoadOperatorsPayload {
//        
//        .init(
//            afterOperatorID: operatorID,
//            searchText: searchText,
//            pageSize: pageSize
//        )
//    }
//    
//    private func expect(
//        _ sut: SUT,
//        with payload: LoadOperatorsPayload,
//        toDeliver expectedResult: Result<[String], Error>,
//        file: StaticString = #file,
//        line: UInt = #line
//    ) {
//        let expectedResult: SUT.LoadOperatorsResult = expectedResult.map { .stub(names: $0) }
//        
//        let exp = expectation(description: "wait for completion")
//        
//        sut.loadOperators(payload) { receivedResult in
//            
//            ForaBankTests.assert(receivedResult, expectedResult, file: file, line: line)
//            
//            exp.fulfill()
//        }
//        
//        wait(for: [exp], timeout: 1)
//    }
//    
//    private func expect(
//        _ sut: SUT,
//        with payload: LoadOperatorsPayload,
//        delivers expectedResult: SUT.LoadOperatorsResult,
//        file: StaticString = #file,
//        line: UInt = #line
//    ) {
//        let exp = expectation(description: "wait for completion")
//        
//        sut.loadOperators(payload) { receivedResult in
//            
//            ForaBankTests.assert(receivedResult, expectedResult, file: file, line: line)
//            
//            exp.fulfill()
//        }
//        
//        wait(for: [exp], timeout: 1)
//    }
//}

private func assert(
    _ receivedResult: SUT.LoadOperatorsResult,
    _ expectedResult: SUT.LoadOperatorsResult,
    file: StaticString = #file,
    line: UInt = #line
) {
    switch (receivedResult, expectedResult) {
    case let (
        .failure(receivedError as NSError),
        .failure(expectedError as NSError)
    ):
        XCTAssertNoDiff(receivedError, expectedError, file: file, line: line)
        
    case let (
        .success(received),
        .success(expected)
    ):
        XCTAssertNoDiff(received, expected, file: file, line: line)
        
    default:
        XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
    }
}

private extension Array where Element == _OperatorGroup {
    
    static func stub(
        titles: [String] = []
    ) -> Self {
        
        titles.map {
            
            .init(md5hash: "", title: $0, description: "")
        }
    }
}

private extension Array where Element == OperatorsListComponents.Operator {
    
    static func stub(
        names: [String] = []
    ) -> Self {
        
        names.map {
            
            .init(id: $0, title: $0, subtitle: "", image: nil)
        }
    }
}
