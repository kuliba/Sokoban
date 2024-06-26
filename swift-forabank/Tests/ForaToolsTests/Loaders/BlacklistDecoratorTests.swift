//
//  BlacklistDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import ForaTools
import XCTest

final class BlacklistDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, decoratee) = makeSUT()
        
        XCTAssertEqual(decoratee.callCount, 0)
    }
    
    func test_load_shouldCallIsBlacklisted() {
        
        let request = anyRequest()
        var requests = [Request]()
        let (sut, _) = makeSUT(
            isBlacklisted: { requests.append($0); return true}
        )
        
        sut.load(request) { _ in }
        
        XCTAssertNoDiff(requests, [request])
    }
    
    func test_load_shouldNotCallDecorateeOnIsBlacklistedTrue() {
        
        let request = anyRequest()
        let (sut, decoratee) = makeSUT(isBlacklisted: { _ in true })
        
        sut.load(request) { _ in }
        
        XCTAssertNoDiff(decoratee.payloads, [])
    }
    
    func test_load_shouldDeliverBlacklistedErrorOnIsBlacklistedTrue() {
        
        let (sut, _) = makeSUT(isBlacklisted: { _ in true })
        
        assert(sut, with: anyRequest(), toDeliver: .failure(.blacklistedError))
    }
    
    func test_load_shouldCallDecorateeOnIsBlacklistedFalse() {
        
        let request = anyRequest()
        let (sut, decoratee) = makeSUT(isBlacklisted: { _ in false })
        
        sut.load(request) { _ in }
        
        XCTAssertNoDiff(decoratee.payloads, [request])
    }
    
    func test_load_shouldDeliverFailureOnDecorateeFailure() {
        
        let failure = anyLoadFailure()
        let (sut, decoratee) = makeSUT(isBlacklisted: { _ in false })
        
        assert(sut, with: anyRequest(), toDeliver: .failure(.loadFailure(failure))) {
            
            decoratee.complete(with: .failure(failure))
        }
    }
    
    func test_load_shouldDeliverSuccessOnDecorateeSuccess() {
        
        let response = anyResponse()
        let (sut, decoratee) = makeSUT(isBlacklisted: { _ in false })
        
        assert(sut, with: anyRequest(), toDeliver: .success(response)) {
            
            decoratee.complete(with: .success(response))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = BlacklistDecorator<Request, Response, LoadFailure>
    private typealias LoadSpy = Spy<Request, DecorateeResult>
    
    private typealias Request = Int
    private typealias Response = String
    private typealias DecorateeResult = Result<Response, LoadFailure>
    private typealias LoadResult = Result<Response, SUT.Error>
    
    private func makeSUT(
        isBlacklisted: @escaping (Request) -> Bool = { _ in false },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: LoadSpy
    ) {
        
        let decoratee = LoadSpy()
        let sut = SUT(decoratee: decoratee, isBlacklisted: isBlacklisted)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        
        return (sut, decoratee)
    }
    
    private func anyRequest(
        _ value: Int = .random(in: 0...1_000)
    ) -> Request {
        
        return value
    }
    
    private func anyResponse(
        _ value: String = UUID().uuidString
    ) -> Response {
        
        return value
    }
    
    private func anyLoadFailure(
        _ value: String = UUID().uuidString
    ) -> LoadFailure {
        
        return .init(value: value)
    }
    
    private func assert(
        _ sut: SUT,
        with request: Request,
        toDeliver expected: LoadResult,
        on action: () throws -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var result: LoadResult?
        let exp = expectation(description: "wait for completion")
        
        sut.load(request) {
            
            result = $0
            exp.fulfill()
        }
        
        try? action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(result, expected, file: file, line: line)
    }
    
    private struct LoadFailure: Error, Equatable {
        
        let value: String
    }
}
