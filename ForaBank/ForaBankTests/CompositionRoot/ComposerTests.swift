//
//  ComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.09.2024.
//

import ForaTools

final class RemoteComposer {
    
    private let batcher: ServiceCategoryTypeBatcher
    
    init(
        perform: @escaping Perform
    ) {
        self.batcher = Batcher(perform: perform)
    }
    
    typealias ServiceCategoryTypeBatcher = Batcher<ServiceCategory.CategoryType>
    typealias Perform = (ServiceCategory.CategoryType, @escaping (Result<Void, Error>) -> Void) -> Void
}

extension RemoteComposer {
    
    typealias Remote = ([ServiceCategory], @escaping (Result<Void, Error>) -> Void) -> Void
    
    func compose() -> Remote {
        let _: RemoteNanoServiceFactory
        return { categories, completion in
            
            let types = categories.filter(\.hasStandardFlow).map(\.type)
            
            guard !types.isEmpty else { return completion(.success(())) }
            
            self.batcher.call(types) { _ in
                
                completion(.success(()))
            }
        }
    }
}

extension Batcher {
    
    convenience init(
        perform: @escaping (Parameter, @escaping (Result<Void, Error>) -> Void) -> Void
    ) {
        self.init { type, completion in
            
            perform(type) {
                
                switch $0 {
                case let .failure(failure):
                    completion(failure)
                    
                case .success(()):
                    completion(nil)
                }
            }
        }
    }
}

extension ServiceCategory {
    
    var hasStandardFlow: Bool { paymentFlow == .standard }
}

@testable import ForaBank
import XCTest

final class ComposerTests: XCTestCase {
    
    // MARK: - compose
    
    func test_compose_shouldNotCallCollaborators() {
        
        let (sut, perform) = makeSUT()
        
        XCTAssertEqual(perform.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - remote
    
    func test_remote_shouldNotCallPerformOnEmptyCategories() {
        
        let (sut, perform) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut([]) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(perform.callCount, 0)
    }
    
    func test_remote_shouldNotCallPerformOnNonStandardFlowCategory() {
        
        let categories = [makeCategory(flow: .mobile)]
        let (sut, perform) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(perform.callCount, 0)
    }
    
    func test_remote_shouldNotCallPerformOnNonStandardFlowCategories() {
        
        let categories = [
            makeCategory(flow: .mobile),
            makeCategory(flow: .qr),
            makeCategory(flow: .taxAndStateServices),
            makeCategory(flow: .transport),
        ]
        let (sut, perform) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(perform.callCount, 0)
    }
    
    func test_remote_shouldCallPerformOnStandardFlowCategory() {
        
        let categories = [
            makeCategory(flow: .standard, type: .digitalWallets)
        ]
        let (sut, perform) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        perform.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(perform.payloads, [.digitalWallets])
    }
    
    func test_remote_shouldCallPerformOnStandardFlowCategories() {
        
        let categories = [
            makeCategory(flow: .standard, type: .education),
            makeCategory(flow: .standard, type: .digitalWallets),
        ]
        let (sut, perform) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        perform.complete(with: .failure(anyError()))
        perform.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(perform.payloads, [.education, .digitalWallets])
    }
    
    func test_remote_shouldCallPerformOnStandardFlowCategories_mixed() {
        
        let categories = [
            makeCategory(flow: .qr),
            makeCategory(flow: .standard, type: .charity),
            makeCategory(flow: .mobile),
            makeCategory(flow: .standard, type: .security),
        ]
        let (sut, perform) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        perform.complete(with: .failure(anyError()))
        perform.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(perform.payloads, [.charity, .security])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = RemoteComposer
    private typealias SUT = Composer.Remote
    private typealias Perform = Spy<ServiceCategory.CategoryType, Void, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        perform: Perform
    ) {
        let perform = Perform()
        let composer = Composer(perform: perform.process(_:completion:))
        let sut = composer.compose()
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(perform, file: file, line: line)
        
        return (sut, perform)
    }
    
    private func makeCategory(
        latestPaymentsCategory: ServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = .random(in: 1...100),
        flow paymentFlow: ServiceCategory.PaymentFlow,
        search: Bool = false,
        type: ServiceCategory.CategoryType = .charity
    ) -> ServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            search: search,
            type: type
        )
    }
}
