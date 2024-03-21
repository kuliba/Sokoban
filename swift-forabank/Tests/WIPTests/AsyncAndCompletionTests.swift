//
//  AsyncAndCompletionTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2024.
//

import XCTest

final class AsyncAndCompletionTests: XCTestCase {
    
    func test_() async throws {
        
        let spy = Spy<Void, String>()
        
        @Sendable
        func process(
            _ f: @escaping (@escaping (String)  -> Void) -> Void
        ) async -> String {
            
            await withCheckedContinuation { continuation in
                
                f { continuation.resume(returning: $0) }
            }
        }
        
        async let p = process(spy.process(completion:))
        try await Task.sleep(for: .milliseconds(50))
        spy.complete(with: "abc")
        let r = await p
        
        XCTAssertNoDiff(r, "abc")
    }
}
