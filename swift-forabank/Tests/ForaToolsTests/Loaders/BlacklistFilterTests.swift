//
//  BlacklistFilterTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import ForaTools
import XCTest

final class BlacklistFilterTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        var requests = [Request]()
        let sut = makeSUT(
            isBlacklisted: { request,_ in
                
                requests.append(request)
                return true
            }
        )
        
        XCTAssertNoDiff(requests, [])
        XCTAssertNotNil(sut)
    }
    
    func test_isBlacklisted_shouldCallIsBlacklisted_true() {
        
        let request = anyRequest()
        var requests = [(request: Request, attempts: Int)]()
        let sut = makeSUT(
            isBlacklisted: { request, attempts in
                
                requests.append((request, attempts))
                return true
            }
        )
        
        _ = sut.isBlacklisted(request)
        _ = sut.isBlacklisted(request)
        _ = sut.isBlacklisted(request)
        
        XCTAssertNoDiff(requests.map(\.request), [request, request, request])
        XCTAssertNoDiff(requests.map(\.attempts), [1, 2, 3])
    }
    
    func test_isBlacklisted_shouldCallIsBlacklisted_false() {
        
        let request = anyRequest()
        var requests = [(request: Request, attempts: Int)]()
        let sut = makeSUT(
            isBlacklisted: { request, attempts in
                
                requests.append((request, attempts))
                return false
            }
        )
        
        _ = sut.isBlacklisted(request)
        _ = sut.isBlacklisted(request)
        _ = sut.isBlacklisted(request)
        
        XCTAssertNoDiff(requests.map(\.request), [request, request, request])
        XCTAssertNoDiff(requests.map(\.attempts), [1, 2, 3])
    }
    
    func test_isBlacklisted_shouldNotCountAttemptsOnIsBlacklistedReturnsNil() {
        
        let request = anyRequest()
        var requests = [(request: Request, attempts: Int)]()
        let sut = makeSUT(
            isBlacklisted: { request, attempts in
                
                requests.append((request, attempts))
                return nil
            }
        )
        
        _ = sut.isBlacklisted(request)
        _ = sut.isBlacklisted(request)
        _ = sut.isBlacklisted(request)
        
        XCTAssertNoDiff(requests.map(\.request), [request, request, request])
        XCTAssertNoDiff(requests.map(\.attempts), [1, 1, 1])
    }
    
    func test_isBlacklisted_shouldReturnIsBlacklistedResultFalse() {
        
        let sut = makeSUT(isBlacklisted: { _,_ in return false })
        
        XCTAssertFalse(sut.isBlacklisted(anyRequest()))
    }
    
    func test_isBlacklisted_shouldReturnIsBlacklistedResultTrue() {
        
        let sut = makeSUT(isBlacklisted: { _,_ in return true })
        
        XCTAssertTrue(sut.isBlacklisted(anyRequest()))
    }
    
    func test_isBlacklisted_shouldIncrementAttemptCount() {
        
        let (request1, request2) = (anyRequest(), anyRequest())
        var request1Attempts = [Int]()
        var request2Attempts = [Int]()
        
        let sut = makeSUT(
            isBlacklisted: { request, attempts in
                
                if request == request1 {
                    request1Attempts.append(attempts)
                } else if request == request2 {
                    request2Attempts.append(attempts)
                }
                return false
            }
        )
        
        _ = sut.isBlacklisted(request1)
        _ = sut.isBlacklisted(request1)
        _ = sut.isBlacklisted(request2)
        _ = sut.isBlacklisted(request2)
        _ = sut.isBlacklisted(request2)
        
        XCTAssertNoDiff(request1Attempts, [1, 2])
        XCTAssertNoDiff(request2Attempts, [1, 2, 3])
    }
    
    func test_isBlacklisted_shouldReturnIsBlacklistedResult_0() {
        
        let request = anyRequest()
        let sut = makeSUT(isBlacklisted: { _, attempts in return attempts > 0 })
        
        XCTAssertTrue(sut.isBlacklisted(request))
    }
    
    func test_isBlacklisted_shouldReturnIsBlacklistedResult_1() {
        
        let request = anyRequest()
        let sut = makeSUT(isBlacklisted: { _, attempts in return attempts > 1 })
        
        XCTAssertFalse(sut.isBlacklisted(request))
        XCTAssertTrue(sut.isBlacklisted(request))
    }
    
    func test_isBlacklisted_shouldReturnIsBlacklistedResult_2() {
        
        let request = anyRequest()
        let sut = makeSUT(isBlacklisted: { _, attempts in return attempts > 2 })
        
        XCTAssertFalse(sut.isBlacklisted(request))
        XCTAssertFalse(sut.isBlacklisted(request))
        XCTAssertTrue(sut.isBlacklisted(request))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = BlacklistFilter<Request>
    private typealias Request = String
    
    private func makeSUT(
        isBlacklisted: @escaping SUT.IsBlacklisted = { _,_ in false },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(isBlacklisted: isBlacklisted)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func anyRequest(
        _ value: String = UUID().uuidString
    ) -> Request {
        
        return value
    }
}
