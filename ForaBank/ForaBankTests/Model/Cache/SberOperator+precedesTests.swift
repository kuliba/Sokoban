//
//  SberOperator+precedesTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.07.2024.
//

@testable import ForaBank
import OperatorsListComponents
import XCTest

final class SberOperator_precedesTests: XCTestCase {

    func test_precedes_shouldSortByTitleCyrillicFirst() {
        
        let operator1 = makeOperator(title: "apple")
        let operator2 = makeOperator(title: "эра")
        
        XCTAssertTrue(operator2.precedes(operator1))
    }
    
    func test_precedes_shouldSortByInnOnSameTitle() {
        
        let operator1 = makeOperator(inn: "123", title: "abc")
        let operator2 = makeOperator(inn: "012", title: "abc")
        
        XCTAssertTrue(operator2.precedes(operator1))
    }
    
    // MARK: - Helpers
    
    private func makeOperator(
        id: String = anyMessage(),
        inn: String? = anyMessage(),
        md5Hash: String? = nil,
        title: String = anyMessage()
    ) -> SberOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, title: title)
    }
}

func anyMessage(
    _ value: String = UUID().uuidString
) -> String {
    
    return value
}
