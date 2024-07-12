//
//  InputWrapperValidatorTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 12.07.2024.
//

import Foundation
import XCTest
@testable import ForaBank
import SwiftUI

final class InputWrapperViewValidatorTests: XCTestCase {

    func test_isValid_shouldNotDeliverErrorForMatchingRegex() {

        assert(value: "abc123", regExp: "^[a-zA-Z0-9]+$", isMatching: true)
    }

    func test_isValid_shouldDeliverErrorForNonMatchingRegex() {

        assert(value: "abc-123", regExp: "^[a-zA-Z0-9]+$", isMatching: false)
    }

    func test_isValid_shouldDeliverErrorForNilRegex() {

        assert(value: "abc-123", regExp: nil, isMatching: true)
    }

    private func assert(
        value: String,
        regExp pattern: String?,
        isMatching: Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            InputWrapperView<EmptyView>.isValidate(value, regExp: pattern),
            isMatching,
            file: file, line: line
        )
    }
}
