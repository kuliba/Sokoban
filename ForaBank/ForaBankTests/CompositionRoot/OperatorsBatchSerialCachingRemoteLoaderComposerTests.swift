//
//  OperatorsBatchSerialCachingRemoteLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.09.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class OperatorsBatchSerialCachingRemoteLoaderComposerTests: XCTestCase {
    
    // MARK: - compose
    
    func test_compose_shouldNotCallCollaborators() {
        
        let (sut, httpClient, local) = makeSUT()
        
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertEqual(local.loadCallCount, 0)
        XCTAssertEqual(local.storeCallCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - remote
    
    func test_remote_shouldNotCallHTTPClientOnEmptyCategories() {
        
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut([]) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_remote_shouldNotCallHTTPClientOnNonStandardFlowCategory() {
        
        let payloads = [
            makeCategory(flow: .mobile)
        ].map { Payload(serial: nil, category: $0) }
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_remote_shouldNotCallHTTPClientOnNonStandardFlowCategories() {
        
        let payloads = [
            makeCategory(flow: .mobile),
            makeCategory(flow: .qr),
            makeCategory(flow: .taxAndStateServices),
            makeCategory(flow: .transport),
        ].map { Payload(serial: nil, category: $0) }
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_remote_shouldCallHTTPClientOnStandardFlowCategory() {
        
        let payloads = [
            makeCategory(flow: .standard, type: .digitalWallets)
        ].map { Payload(serial: nil, category: $0) }
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 1)
        httpClient.assert(queryItems: [
            [query("operatorOnly", "true"), query("type", "digitalWallets")],
        ])
    }
    
    func test_remote_shouldCallHTTPClientOnStandardFlowCategories() {
        
        let payloads = [
            makeCategory(flow: .standard, type: .education),
            makeCategory(flow: .standard, type: .digitalWallets),
        ].map { Payload(serial: nil, category: $0) }
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        httpClient.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1)
        httpClient.assert(queryItems: [
            [query("operatorOnly", "true"), query("type", "education")],
            [query("operatorOnly", "true"), query("type", "digitalWallets")],
        ])
    }
    
    func test_remote_shouldCallHTTPClientOnStandardFlowCategories_mixed() {
        
        let payloads = [
            makeCategory(flow: .qr),
            makeCategory(flow: .standard, type: .charity),
            makeCategory(flow: .mobile),
            makeCategory(flow: .standard, type: .security),
        ].map { Payload(serial: nil, category: $0) }
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        httpClient.complete(with: .failure(anyError()), at: 1)
        
        wait(for: [exp], timeout: 1)
        httpClient.assert(queryItems: [
            [query("operatorOnly", "true"), query("type", "charity")],
            [query("operatorOnly", "true"), query("type", "security")],
        ])
    }
    
    func test_remote_shouldDeliverEmptyOnNonStandardFlowCategories() {
        
        let payloads = [
            makeCategory(flow: .mobile),
            makeCategory(flow: .qr),
            makeCategory(flow: .taxAndStateServices),
            makeCategory(flow: .transport),
        ].map { Payload(serial: nil, category: $0) }
        let (sut, _, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_remote_shouldDeliverCategoryOnHTTPFailureOneStandardCategory() {
        
        let payloads = [
            makeCategory(flow: .standard, type: .internet),
        ].map { Payload(serial: nil, category: $0) }
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) {
            
            XCTAssertNoDiff($0.map(\.category.type), [.internet])
            XCTAssertNoDiff($0.map(\.serial), [nil])
            exp.fulfill()
        }
        
        httpClient.complete(with: .failure(anyError()))
        wait(for: [exp], timeout: 1)
    }
    
    func test_remote_shouldDeliverTwoCategoriesOnHTTPFailuresTwoStandardCategory() {
        
        let payloads = [
            makeCategory(flow: .standard, type: .internet),
            makeCategory(flow: .standard, type: .security),
        ].map { Payload(serial: nil, category: $0) }
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) {
            
            XCTAssertNoDiff($0.map(\.category.type), [.internet, .security])
            XCTAssertNoDiff($0.map(\.serial), [nil, nil])
            exp.fulfill()
        }
        
        httpClient.complete(with: .failure(anyError()))
        httpClient.complete(with: .failure(anyError()), at: 1)
        wait(for: [exp], timeout: 1)
    }
    
    func test_remote_shouldDeliverMixedOnMixedHTTPFailures() {
        
        let payloads = [
            makeCategory(flow: .standard, type: .internet),
            makeCategory(flow: .standard, type: .security),
        ].map { Payload(serial: nil, category: $0) }
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) {
            
            XCTAssertNoDiff($0.map(\.category.type), [.internet])
            XCTAssertNoDiff($0.map(\.serial), [nil])
            exp.fulfill()
        }
        
        httpClient.complete(with: .failure(anyError()))
        httpClient.complete(with: .success((.getOperatorsListByParam(), anyHTTPURLResponse())), at: 1)
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias Composer = BatchSerialCachingRemoteLoaderComposer
    private typealias SUT = Composer.ServicePaymentProviderService
    private typealias Payload = BatchSerialCachingRemoteLoaderComposer.GetOperatorsListByParamPayload
    private typealias Perform = Spy<ServiceCategory.CategoryType, Void, Error>
    
    private func makeSUT(
        loadStub: Model? = nil,
        storeStub: Result<Void, any Error> = .failure(anyError()),
        serialStub: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        agent: LocalAgentSpy<Model>
    ) {
        let agent = LocalAgentSpy(
            loadStub: loadStub,
            storeStub: storeStub,
            serialStub: serialStub
        )
        let localComposer = LocalLoaderComposer(
            agent: agent,
            interactiveScheduler: .immediate,
            backgroundScheduler: .immediate
        )
        let httpClient = HTTPClientSpy()
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: LoggerAgent()
        )
        let composer = Composer(
            nanoServiceFactory: nanoServiceComposer,
            updateMaker: localComposer
        )
        let sut = composer.composeServicePaymentProviderService(
            getSerial: { _ in agent.serial(for: [CodableServicePaymentProvider].self) }
        )
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(nanoServiceComposer, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(agent, file: file, line: line)
        
        return (sut, httpClient, agent)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
    
    private struct Model: Equatable {
        
        let value: String
    }
    
    private func makeModel(
        _ value: String = anyMessage()
    ) -> Model {
        
        return .init(value: value)
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
    
    private func security() -> Data {
        
        return .getOperatorsListByParam(type: .security)
    }
}

private extension Data {
    
    static func getOperatorsListByParam(
        type: ServiceCategory.CategoryType = .charity
    ) -> Self {
        
        return .init(String.getOperatorsListByParam(type: type).utf8)
    }
}

private extension String {
    
    static func getOperatorsListByParam(
        type: ServiceCategory.CategoryType
    ) -> Self {
        
        return """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "39baea8dd3f9c1d152f69c01fcf3cddc",
        "operatorList": [
            {
                "type": "\(type.name)",
                "atributeList": [
                    {
                        "md5hash": "ef7a4271cdec35cc20c4ca0bb4d43f93",
                        "juridicalName": "МУП РАСПОПИНСКОЕ КХ",
                        "customerId": "18815",
                        "serviceList": [],
                        "inn": "3412302165"
                    }
                ]
            }
        ]
    }
}
"""
    }
}

