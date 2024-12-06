//
//  RootViewModelFactory+loadOperatorsTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import ForaBank
import PayHubUI
import XCTest

final class RootViewModelFactory_loadOperatorsTests: RootViewModelFactoryTests {
    
    func test_init_shouldNotCallLocalAgent() {
        
        let (_, localAgent) = makeSUT()
        
        XCTAssertEqual(localAgent.loadCallCount, 0)
    }
    
    func test_loadOperators_shouldCallLocalAgent() {
        
        let (sut, localAgent) = makeSUT()
        
        sut.loadOperators(payload: makePayload()) { _ in }
        
        XCTAssertEqual(localAgent.loadCallCount, 1)
    }
    
    func test_loadOperators_shouldDeliverEmptyOnMissingValue() {
        
        expect(withLoadStub: nil, payload: makePayload(), toDeliver: [])
    }
        
    // MARK: - Helpers
    
    private typealias LocalAgent = LocalAgentSpy<[CodableServicePaymentOperator]>
    private typealias Payload = UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    
    private func makeSUT(
        loadStub: [CodableServicePaymentOperator]? = nil,
        schedulers: Schedulers = .immediate,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        localAgent: LocalAgent
    ) {
        let localAgent = LocalAgent(loadStub: loadStub)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let sut = super.makeSUT(model: model, schedulers: schedulers, file: file, line: line).sut
        
        trackForMemoryLeaks(localAgent, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, localAgent)
    }
    
    private func makePayload(
        afterOperatorID id: String? = nil,
        for type: ServiceCategory.CategoryType = .internet,
        searchText: String = "",
        pageSize: Int = 3
    ) -> Payload {
        
        return .init(afterOperatorID: id, for: type, searchText: searchText, pageSize: pageSize)
    }
    
    private func expect(
        sut: SUT? = nil,
        withLoadStub loadStub: [CodableServicePaymentOperator]?,
        payload: Payload,
        toDeliver expectedValue: [PaymentServiceOperator],
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(loadStub: loadStub).sut
        let exp = expectation(description: "wait for load completion")
        
        sut.loadOperators(payload: makePayload()) {
            
            XCTAssertNoDiff($0, expectedValue, "Expected \(String(describing: expectedValue)), but got \(String(describing: $0)) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: timeout)
    }
}
