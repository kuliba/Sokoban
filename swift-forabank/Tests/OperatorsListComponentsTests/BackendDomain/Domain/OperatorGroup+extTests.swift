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
        
        let operators = makeOperatorGroups(titles: [])
        let payload = makeLoadOperatorsPayload()
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, [])
    }
    
    func test_paged_shouldReturnEmptyOnEmptyWithNonEmptyPayload() {
        
        let operators = makeOperatorGroups(titles: [])
        let payload = makeLoadOperatorsPayload(
            operatorID: "abc",
            searchText: "123",
            pageSize: 13
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, [])
    }
    
    func test_paged_shouldReturnPageFromBeginningOnNilOperatorID() {
        
        let operators = makeOperatorGroups(titles: [
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: nil,
            pageSize: 3
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(
            titles: ["b", "a", "c"]
        ))
    }
    
    func test_paged_shouldReturnPageFromIDOnNonNilOperatorID_1() {
        
        let operators = makeOperatorGroups(titles: [
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "a",
            pageSize: 1
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(
            titles: ["c"]
        ))
    }
    
    func test_paged_shouldReturnPageFromIDOnNonNilOperatorID_2() {
        
        let operators = makeOperatorGroups(titles: [
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "a",
            pageSize: 2
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(
            titles: ["c", "d"]
        ))
    }
    
    func test_paged_shouldReturnPageFromIDOnNonNilOperatorID_3() {
        
        let operators = makeOperatorGroups(titles: [
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "a",
            pageSize: 3
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(
            titles: ["c", "d", "e"]
        ))
    }
    
    func test_paged_shouldReturnPageFromIDOnNonNilOperatorID_10() {
        
        let operators = makeOperatorGroups(titles: [
            "b", "a", "c", "d", "e"
        ])
        let payload = makeLoadOperatorsPayload(
            operatorID: "a",
            pageSize: 10
        )
        
        let paged = operators.paged(with: payload)
        
        XCTAssertNoDiff(paged, makeOperatorGroups(
            titles: ["c", "d", "e"]
        ))
    }
    
#warning("add tests for `inn` field")
    
    private func makeOperatorGroups(
        titles: [String]
    ) -> [OperatorGroup] {
        
        titles.map {
            
            .init(md5hash: "", title: $0, description: "")
        }
    }
    
    private func makeLoadOperatorsPayload(
        operatorID: Operator.ID? = nil,
        searchText: String = "",
        pageSize: Int = 10
    ) -> LoadOperatorsPayload {
        
        .init(
            afterOperatorID: operatorID,
            searchText: searchText,
            pageSize: pageSize
        )
    }
}
