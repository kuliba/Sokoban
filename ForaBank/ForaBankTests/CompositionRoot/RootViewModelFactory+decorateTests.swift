//
//  RootViewModelFactory+decorateTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 21.10.2024.
//

extension RootViewModelFactory {
    
    func decorate(
        decoratee: @escaping Load<[ServiceCategory]>,
        with decoration: @escaping ([ServiceCategory], @escaping ([ServiceCategory]) -> Void) -> Void
    ) -> Load<[ServiceCategory]> {
        
        return { completion in
            
        }
    }
}

@testable import ForaBank
import XCTest

final class RootViewModelFactory_decorateTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, httpClient, decoratee, decoration, _) = makeSUT()
        
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertEqual(decoratee.callCount, 0)
        XCTAssertEqual(decoration.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootViewModelFactory
    private typealias Decoratee = Spy<Void, [ServiceCategory], Never>
    private typealias Decoration = Spy<[ServiceCategory], [ServiceCategory], Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        decoratee: Decoratee,
        decoration: Decoration,
        decorated: SUT.Load<[ServiceCategory]>
    ) {
        let model: Model = .mockWithEmptyExcept()
        let httpClient = HTTPClientSpy()
        let logger = LoggerSpy() // TODO: add logging tests
        let sut = SUT(
            model: model,
            httpClient: httpClient,
            logger: logger
        )
        let decoratee = Decoratee()
        let decoration = Decoration()
        
        let decorated = sut.decorate(
            decoratee: decoratee.process(completion:),
            with: decoration.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: - restore memory leaks tracking after Model fix
        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(logger, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(decoration, file: file, line: line)
        
        return (sut, httpClient, decoratee, decoration, decorated)
    }
}
