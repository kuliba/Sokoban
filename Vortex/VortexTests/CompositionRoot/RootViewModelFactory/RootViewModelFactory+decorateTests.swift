//
//  RootViewModelFactory+decorateTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.10.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_decorateTests: RootViewModelFactoryTests {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, httpClient, decoratee, decoration, logger, _) = makeDecorated()
        
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertEqual(decoratee.callCount, 0)
        XCTAssertEqual(decoration.callCount, 0)
        XCTAssertEqual(logger.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldCallDecoratee() {
        
        let (sut,_, decoratee, _,_, decorated) = makeDecorated()
        
        decorated { _ in }
        
        XCTAssertNoDiff(decoratee.callCount, 1)
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldNotCallDecorationOnDecorateeNilResult() {
        
        let (sut,_, decoratee, decoration, _, decorated) = makeDecorated()
        
        call(decorated, on: { decoratee.complete(with: nil) })
        
        XCTAssertEqual(decoration.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldDeliverNilOnDecorateeNilResult() {
        
        let (sut,_, decoratee, _,_, decorated) = makeDecorated()
        
        call(
            decorated,
            assert: { XCTAssertNoDiff($0, nil) },
            on: { decoratee.complete(with: nil) }
        )
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldNotCallDecorationOnDecorateeEmptyResult() {
        
        let (sut,_, decoratee, decoration, _, decorated) = makeDecorated()
        
        call(decorated, on: { decoratee.complete(with: []) })
        
        XCTAssertEqual(decoration.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldDeliverEmptyOnDecorateeEmptyResult() {
        
        let (sut,_, decoratee, _,_, decorated) = makeDecorated()
        
        call(
            decorated,
            assert: { XCTAssertNoDiff($0, []) },
            on: { decoratee.complete(with: []) }
        )
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldCallDecorationWithOneOnDecorateeResultWithOne() {
        
        let category = makeServiceCategory()
        let (sut,_, decoratee, decoration, _, decorated) = makeDecorated()
        
        call(decorated, on: {
            
            decoratee.complete(with: [category])
            decoration.complete(with: [])
        })
        
        XCTAssertNoDiff(decoration.payloads, [[category]])
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldDeliverOneOnDecorateeResultOfOne() {
        
        let category = makeServiceCategory()
        let (sut,_, decoratee, decoration, _, decorated) = makeDecorated()
        
        call(
            decorated,
            assert: { XCTAssertNoDiff($0, [category]) },
            on: {
                
                decoratee.complete(with: [category])
                decoration.complete(with: [])
            }
        )
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldCallDecorationWithTwoOnDecorateeResultWithTwo() {
        
        let (category1, category2) = (makeServiceCategory(), makeServiceCategory())
        let (sut,_, decoratee, decoration, _, decorated) = makeDecorated()
        
        call(decorated, on: {
            
            decoratee.complete(with: [category1, category2])
            decoration.complete(with: [])
        })
        
        XCTAssertNoDiff(decoration.payloads, [[category1, category2]])
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldDeliverTwoOnDecorateeResultOfTwo() {
        
        let (category1, category2) = (makeServiceCategory(), makeServiceCategory())
        let (sut,_, decoratee, decoration,_, decorated) = makeDecorated()
        
        call(
            decorated,
            assert: { XCTAssertNoDiff($0, [category1, category2]) },
            on: {
                
                decoratee.complete(with: [category1, category2])
                decoration.complete(with: [])
            }
        )
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldNotCallLoggerOnEmptyDecorationResult() {
        
        let (sut,_, decoratee, _, logger, decorated) = makeDecorated()
        
        call(decorated, on: {
            
            decoratee.complete(with: [])
            XCTAssertEqual(logger.callCount, 0)
        })
        
        XCTAssertEqual(logger.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldCallLoggerWithOneOnDecorationResultOfOne() throws {
        
        let categoryName = anyMessage()
        let category = makeServiceCategory(name: categoryName)
        let (sut,_, decoratee, decoration, logger, decorated) = makeDecorated()
        
        call(decorated, on: {
            
            decoratee.complete(with: [self.makeServiceCategory()])
            decoration.complete(with: [category])
        })
        
        XCTAssertNoDiff(logger.events.map(\.level), [.error])
        XCTAssertNoDiff(logger.events.map(\.category), [.network])
        
        try singleMessage(logger, contains: categoryName)
        XCTAssertNotNil(sut)
    }
    
    func test_decorated_shouldCallLoggerWithTwoOnDecorationResultOfTwo() throws {
        
        let (categoryName1, categoryName2) = (anyMessage(), anyMessage())
        let category1 = makeServiceCategory(name: categoryName1)
        let category2 = makeServiceCategory(name: categoryName2)
        let (sut,_, decoratee, decoration, logger, decorated) = makeDecorated()
        
        call(decorated, on: {
            
            decoratee.complete(with: [self.makeServiceCategory()])
            decoration.complete(with: [category1, category2])
        })
        
        XCTAssertNoDiff(logger.events.map(\.level), [.error])
        XCTAssertNoDiff(logger.events.map(\.category), [.network])
        
        try singleMessage(logger, contains: categoryName1)
        try singleMessage(logger, contains: categoryName2)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias Decoratee = Spy<Void, [ServiceCategory]?, Never>
    private typealias Decoration = Spy<[ServiceCategory], [ServiceCategory], Never>
    
    private func makeDecorated(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        decoratee: Decoratee,
        decoration: Decoration,
        logger: LoggerSpy,
        decorated: SUT.Load<[ServiceCategory]>
    ) {
        let (sut, httpClient, logger) = makeSUT(file: file, line: line)
        let decoratee = Decoratee()
        let decoration = Decoration()
        
        let decorated = sut.decorate(
            decoratee.process(completion:),
            with: decoration.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(logger, file: file, line: line)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(decoration, file: file, line: line)
        
        return (sut, httpClient, decoratee, decoration, logger, decorated)
    }
    
    private func call(
        _ decorated: SUT.Load<[ServiceCategory]>,
        assert: @escaping ([ServiceCategory]?) -> Void = { _ in },
        on action: @escaping () -> Void,
        timeout: TimeInterval = 1.0
    ) {
        let exp = expectation(description: "wait for completion")
        
        decorated {
            
            assert($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func singleMessage(
        _ logger: LoggerSpy,
        contains string: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let count = logger.events.count
        XCTAssertEqual(count, 1, "Expected one log message, but got \(count) instead.", file: file, line: line)
        
        let message = try XCTUnwrap(logger.events.first.map(\.message))
        XCTAssert(message.contains(string), "Log message does not contain \"\(string)\".", file: file, line: line)
    }
}
