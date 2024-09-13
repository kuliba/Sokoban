//
//  ComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.09.2024.
//

import ForaTools
import RemoteServices

final class ServiceCategoryRemoteComposer {
    
    private let nanoServiceFactory: RemoteNanoServiceFactory
    
    init(
        nanoServiceFactory: RemoteNanoServiceFactory
    ) {
        self.nanoServiceFactory = nanoServiceFactory
    }
}

extension ServiceCategoryRemoteComposer {
    
    typealias Remote = ([ServiceCategory], @escaping (Result<Void, Error>) -> Void) -> Void
    
    func compose() -> Remote {
        
        let perform = self.nanoServiceFactory.compose(
            makeRequest: RequestFactory.getOperatorsListByParam(_:),
            mapResponse: RemoteServices.ResponseMapper.mapAnywayOperatorsListResponse
        )
        
        let batcher = Batcher(perform: perform)
        
        return { categories, completion in
            
            let withStandard = categories.filter(\.hasStandardFlow)
            
            guard !withStandard.isEmpty
            else { return completion(.success(())) }
            
            batcher.call(withStandard.map(\.typeName)) { _ in
                
                completion(.success(()))
            }
        }
    }
}

extension ServiceCategory {
    
    var typeName: String {
        
        switch type {
        case .charity:                   return "charity"
        case .digitalWallets:            return "digitalWallets"
        case .education:                 return "education"
        case .housingAndCommunalService: return "housingAndCommunalService"
        case .internet:                  return "internet"
        case .mobile:                    return "mobile"
        case .networkMarketing:          return "networkMarketing"
        case .qr:                        return "qr"
        case .repaymentLoansAndAccounts: return "repaymentLoansAndAccounts"
        case .security:                  return "security"
        case .socialAndGames:            return "socialAndGames"
        case .taxAndStateService:        return "taxAndStateService"
        case .transport:                 return "transport"
        }
    }
}

extension Batcher {
    
    convenience init<T>(
        perform: @escaping (Parameter, @escaping (Result<T, Error>) -> Void) -> Void
    ) {
        self.init(perform: { parameter, completion in
            
            perform(parameter) {
                
                switch $0 {
                case let .failure(failure):
                    completion(failure)
                    
                case .success:
                    completion(nil)
                }
            }
        })
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
        
        let (sut, httpClient) = makeSUT()
        
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - remote
    
    func test_remote_shouldNotCallHTTPClientOnEmptyCategories() {
        
        let (sut, httpClient) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut([]) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_remote_shouldNotCallHTTPClientOnNonStandardFlowCategory() {
        
        let categories = [makeCategory(flow: .mobile)]
        let (sut, httpClient) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_remote_shouldNotCallHTTPClientOnNonStandardFlowCategories() {
        
        let categories = [
            makeCategory(flow: .mobile),
            makeCategory(flow: .qr),
            makeCategory(flow: .taxAndStateServices),
            makeCategory(flow: .transport),
        ]
        let (sut, httpClient) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_remote_shouldCallHTTPClientOnStandardFlowCategory() {
        
        let categories = [
            makeCategory(flow: .standard, type: .digitalWallets)
        ]
        let (sut, httpClient) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 1)
        httpClient.assert(queryItems: [
            [query("operatorOnly", "true"), query("type", "digitalWallets")],
        ])
    }
    
    func test_remote_shouldCallHTTPClientOnStandardFlowCategories() {
        
        let categories = [
            makeCategory(flow: .standard, type: .education),
            makeCategory(flow: .standard, type: .digitalWallets),
        ]
        let (sut, httpClient) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        httpClient.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1)
        httpClient.assert(queryItems: [
            [query("operatorOnly", "true"), query("type", "education")],
            [query("operatorOnly", "true"), query("type", "digitalWallets")],
        ])
    }
    
    func test_remote_shouldCallHTTPClientOnStandardFlowCategories_mixed() {
        
        let categories = [
            makeCategory(flow: .qr),
            makeCategory(flow: .standard, type: .charity),
            makeCategory(flow: .mobile),
            makeCategory(flow: .standard, type: .security),
        ]
        let (sut, httpClient) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(categories) { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        httpClient.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1)
        httpClient.assert(queryItems: [
            [query("operatorOnly", "true"), query("type", "charity")],
            [query("operatorOnly", "true"), query("type", "security")],
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = ServiceCategoryRemoteComposer
    private typealias SUT = Composer.Remote
    private typealias Perform = Spy<ServiceCategory.CategoryType, Void, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: LoggerAgent()
        )
        let composer = Composer(nanoServiceFactory: nanoServiceComposer)
        let sut = composer.compose()
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(nanoServiceComposer, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        
        return (sut, httpClient)
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
    
    private func query(
        _ name: String,
        _ value: String
    ) -> URLQueryItem {
        
        return .init(name: name, value: value)
    }
}
