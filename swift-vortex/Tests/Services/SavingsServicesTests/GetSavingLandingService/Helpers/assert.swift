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

func assertBody(
    of request: URLRequest,
    hasJSON json: String,
    file: StaticString = #file,
    line: UInt = #line
) throws {
    
    try XCTAssertNoDiff(
        String(data: XCTUnwrap(request.httpBody), encoding: .utf8)?.convertToDictionary(),
        json.replacingOccurrences(of: "\\s", with: "", options: .regularExpression).convertToDictionary(),
        file: file, line: line
    )
}

private extension String {
    
    func convertToDictionary(
    ) -> [String: String]? {
        
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(
                with: data,
                options: []) as? [String: String]
        }
        return nil
    }
}
