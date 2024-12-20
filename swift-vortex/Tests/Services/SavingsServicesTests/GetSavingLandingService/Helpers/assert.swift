//
//

import XCTest

func assert<E: Equatable>(
    _ receivedResult: Result<Void, E>,
    equals expectedResult: Result<Void, E>,
    file: StaticString = #file,
    line: UInt = #line
) {
    switch (receivedResult, expectedResult) {
    case let (
        .failure(received),
        .failure(expected)
    ):
        XCTAssertNoDiff(received, expected, file: file, line: line)
        
    case (
        .success(()),
        .success(())
    ):
        break
        
    default:
        XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
    }
}
