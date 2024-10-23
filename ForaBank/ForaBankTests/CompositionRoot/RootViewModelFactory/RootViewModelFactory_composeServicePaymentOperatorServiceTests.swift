//
//  RootViewModelFactory+composeServicePaymentOperatorServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.09.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class RootViewModelFactory_composeServicePaymentOperatorServiceTests: RootViewModelFactoryTests {
    
    // MARK: - compose
    
    func test_compose_shouldNotCallCollaborators() {
        
        let (sut, httpClient, localAgent, _) = makeCompose()
        
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertEqual(localAgent.loadCallCount, 0)
        XCTAssertEqual(localAgent.storeCallCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - remote
    
    func test_remote_shouldNotCallHTTPClientOnEmptyCategories() {
        
        let (_, httpClient, _, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService([]) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_remote_shouldNotCallHTTPClientOnNonStandardFlowCategory() {
        
        let payloads = [
            makeCategory(flow: .mobile)
        ].map { Payload(serial: nil, category: $0) }
        let (_, httpClient, _, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService(payloads) { _ in exp.fulfill() }
        
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
        let (_, httpClient, _, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService(payloads) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_remote_shouldCallHTTPClientOnStandardFlowCategory() {
        
        let payloads = [
            makeCategory(flow: .standard, type: .digitalWallets)
        ].map { Payload(serial: nil, category: $0) }
        let (_, httpClient, _, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService(payloads) { _ in exp.fulfill() }
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
        let (_, httpClient, _, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService(payloads) { _ in exp.fulfill() }
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
        let (_, httpClient, _, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService(payloads) { _ in exp.fulfill() }
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
        let (_,_,_, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService(payloads) {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_remote_shouldDeliverCategoryOnHTTPFailureOneStandardCategory() {
        
        let payloads = [
            makeCategory(flow: .standard, type: .internet),
        ].map { Payload(serial: nil, category: $0) }
        let (_, httpClient, _, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService(payloads) {
            
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
        let (_, httpClient, _, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService(payloads) {
            
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
        let (_, httpClient, _, batchService) = makeCompose()
        let exp = expectation(description: "wait for completion")
        
        batchService(payloads) {
            
            XCTAssertNoDiff($0.map(\.category.type), [.internet])
            XCTAssertNoDiff($0.map(\.serial), [nil])
            exp.fulfill()
        }
        
        httpClient.complete(with: .failure(anyError()))
        httpClient.complete(with: .success((.getOperatorsListByParam(), anyHTTPURLResponse())), at: 1)
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias BatchService = SUT.ServicePaymentProviderBatchService
    private typealias Payload = SUT.GetOperatorsListByParamPayload
    private typealias Perform = Spy<ServiceCategory.CategoryType, Void, Error>
    
    private func makeCompose(
        loadStub: Model? = nil,
        storeStub: Result<Void, any Error> = .failure(anyError()),
        serialStub: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        localAgent: LocalAgentSpy<Model>,
        batchService: BatchService
    ) {
        let localAgent = LocalAgentSpy(
            loadStub: loadStub,
            storeStub: storeStub,
            serialStub: serialStub
        )
        let model: ForaBank.Model = .mockWithEmptyExcept(
            localAgent: localAgent
        )
        let (sut, httpClient, _) = makeSUT(model: model)
        
        let batchService = sut.composeServicePaymentOperatorService()
        
        trackForMemoryLeaks(localAgent, file: file, line: line)
        
        return (sut, httpClient, localAgent, batchService)
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
        hasSearch: Bool = false,
        type: ServiceCategory.CategoryType = .charity
    ) -> ServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            hasSearch: hasSearch,
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
