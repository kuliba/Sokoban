//
//  OperatorGroup+extTests.swift
//
//
//  Created by Igor Malyarov on 29.02.2024.
//

import OperatorsListComponents
import XCTest

final class OperatorGroup_extTests: XCTestCase {
    
    func test_paged_shouldReturnEmptyOnEmptyWithEmptyPayload() {
        
        let operators = makeOperatorGroups([])
        let payload = makeLoadOperatorsPayload()
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, [])
    }
    
    func test_paged_shouldReturnEmptyOnEmptyWithNonEmptyPayload() {
        
        let operators = makeOperatorGroups([])
        let payload = makeLoadOperatorsPayload(
            operatorID: "abc",
            searchText: "123",
            pageSize: 13
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, [])
    }
    
    func test_paged_shouldReturnPageFromBeginningOnNilOperatorID() {
        
        let operators = makeOperatorGroups([
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: nil,
            pageSize: 3
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(["b", "a", "c"]))
    }
    
    func test_paged_shouldReturnPageFromIDOnNonNilOperatorID_1() {
        
        let operators = makeOperatorGroups([
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "a",
            pageSize: 1
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(["c"]))
    }
    
    func test_paged_shouldReturnPageFromIDOnNonNilOperatorID_2() {
        
        let operators = makeOperatorGroups([
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "a",
            pageSize: 2
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(["c", "d"]))
    }
    
    func test_paged_shouldReturnPageFromIDOnNonNilOperatorID_3() {
        
        let operators = makeOperatorGroups([
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "a",
            pageSize: 3
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(["c", "d", "e"]))
    }
    
    func test_paged_shouldReturnPageFromIDOnNonNilOperatorID_10() {
        
        let operators = makeOperatorGroups([
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "a",
            pageSize: 10
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(["c", "d", "e"]))
    }
    
    func test_paged_shouldDeliverPageFromStartOnNilOperatorIDWithSearch() {
        
        let operators = makeOperatorGroups([
            "b", "a", "aa", "c", "aaa", "aaaa", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: nil,
            searchText: "aa",
            pageSize: 2
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(["aa", "aaa"]))
    }
    
    func test_paged_shouldDeliverEmptyPageAfterMissingOperatorIDWithSearch_2() {
        
        let operators = makeOperatorGroups([
            "b", "a", "aa", "c", "aaa", "aaaa", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "a",
            searchText: "aa",
            pageSize: 2
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups([]))
    }
    
    func test_paged_shouldDeliverPageAfterOperatorIDWithSearch_3() {
        
        let operators = makeOperatorGroups([
            "b", "a", "aa", "c", "aaa", "aaaa", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "aa",
            searchText: "aa",
            pageSize: 2
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(["aaa", "aaaa"]))
    }
    
#warning("add tests for `inn` field")
    
    private func makeOperatorGroups(
        _ titles: [String]
    ) -> [_OperatorGroup] {
        
        titles.map {
            
            .init(md5hash: "", title: $0, description: "")
        }
    }
    
    private func makeLoadOperatorsPayload(
        operatorID: Operator.ID? = nil,
        searchText: String = "",
        pageSize: Int = 10
    ) -> LoadOperatorsPayload<String> {
        
        .init(
            afterOperatorID: operatorID,
            searchText: searchText,
            pageSize: pageSize
        )
    }
}
