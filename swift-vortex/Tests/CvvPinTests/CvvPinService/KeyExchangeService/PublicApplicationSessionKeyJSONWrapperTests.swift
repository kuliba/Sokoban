//
//  PublicApplicationSessionKeyJSONWrapperTests.swift
//  
//
//  Created by Igor Malyarov on 19.08.2023.
//

@testable import CvvPin
import XCTest

final class PublicApplicationSessionKeyJSONWrapperTests: XCTestCase {
    
    func test_wrap_shouldReturnUnwrappableData() throws {
        
        let message = "some data"
        let wrapped = try wrap(message.data(using: .utf8)!)
        let unwrapped = try unwrap(wrapped)
        
        XCTAssertNoDiff(
            String(data: unwrapped, encoding: .utf8),
            message
        )
    }
    // MARK: - Helpers
    
    private let wrap = PublicApplicationSessionKeyJSONWrapper.wrap
    private let unwrap = PublicApplicationSessionKeyJSONWrapper.unwrap
}

extension PublicApplicationSessionKeyJSONWrapper {
    
    static func unwrap(_ data: Data) throws -> Data {
        
        let decoded = try JSONDecoder().decode(Wrapper.self, from: data)
        
        guard let data = Data(base64Encoded: decoded.publicApplicationSessionKey)
        else {
            throw NSError(domain: "base64 decoding error", code: 0)
        }
        
        return data
    }
    
    private struct Wrapper: Decodable {
        
        let publicApplicationSessionKey: String
    }
}
