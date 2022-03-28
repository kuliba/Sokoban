//
//  AsyncAwaitTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 09.02.2022.
//

import XCTest

class AsyncAwaitTests: XCTestCase {
    
    func callbackMethod(completion: @escaping (Int) -> Void ) {
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(50)) {
            
            completion(1)
        }
    }
    
    func asyncMethod() async -> Int {
        
        await withCheckedContinuation({ continuation in
            
            callbackMethod { value in
                
                continuation.resume(returning: value)
            }
        })
    }

    func testExample() async throws {
   
        let result = await asyncMethod()
        
        XCTAssertEqual(result, 1)
    }
}
