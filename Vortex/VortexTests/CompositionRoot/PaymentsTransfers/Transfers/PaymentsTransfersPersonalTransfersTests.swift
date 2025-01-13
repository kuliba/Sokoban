//
//  PaymentsTransfersPersonalTransfersTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 26.10.2024.
//

@testable import Vortex
import XCTest

class PaymentsTransfersPersonalTransfersTests: XCTestCase {
    
    typealias Domain = PaymentsTransfersPersonalTransfersDomain
    
    func assert(
        _ navigation: Domain.NavigationResult,
        _ failure: PaymentsTransfersPersonalTransfersDomain.NavigationFailure,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(navigation.equatable, .failure(failure), message(), file: file, line: line)
    }
    
    func assert(
        _ navigation: Domain.NavigationResult,
        _ success: PaymentsTransfersPersonalTransfersDomain.EquatableNavigation,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(navigation.equatable, .success(success), message(), file: file, line: line)
    }
}
