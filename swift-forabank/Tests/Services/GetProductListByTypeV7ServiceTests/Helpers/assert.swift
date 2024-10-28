//
//  assert.swift
//

import XCTest

func assert<T: Equatable>(
    _ received: [T],
    equals partial: inout [T],
    appending: T...,
    message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    partial += appending
    XCTAssertNoDiff(received, partial, message(), file: file, line: line)
}
