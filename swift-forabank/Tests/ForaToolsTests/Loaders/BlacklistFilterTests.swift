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
    
    func test_isBlacklisted_shouldCallIsBlacklisted() {
        
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
    
    func test_isBlacklisted_shouldReturnIsBlacklistedResultFalse() {
        
        let sut = makeSUT(isBlacklisted: { _,_ in return false} )
        
        XCTAssertFalse(sut.isBlacklisted(anyRequest()))
    }
    
    func test_isBlacklisted_shouldReturnIsBlacklistedResultTrue() {
        
        let sut = makeSUT(isBlacklisted: { _,_ in return true} )
        
        XCTAssertTrue(sut.isBlacklisted(anyRequest()))
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
