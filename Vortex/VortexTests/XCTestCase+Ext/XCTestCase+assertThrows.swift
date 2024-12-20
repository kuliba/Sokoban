//
//  XCTestCase+assertThrows.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.06.2023.
//

import XCTest

extension XCTestCase {
    
    /// Like `XCTAssertThrowsError` for `async` expressions.
    func assertThrows<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async rethrows {
       
        do {
            let t = try await expression()
            XCTFail("Expected error, got \(t) instead.", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }

    func assertThrowsAsNSError<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line,
        error expectedError: Error
    ) async rethrows {
       
        do {
            let t = try await expression()
            XCTFail("Expected error, got \(t) instead.", file: file, line: line)
        } catch {
            XCTAssertNoDiff(
                error as NSError,
                expectedError as NSError,
                file: file, line: line
            )
        }
    }
}
