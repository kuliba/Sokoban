//
//  RootViewModelFactory+loadOperatorsTests.swift
//  ForaBankTests
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
        
    func test_loadOperators_shouldDeliverEmptyOnEmptyValue() {
        
        expect(withLoadStub: [], payload: makePayload(), toDeliver: [])
    }
        
    func test_loadOperators_shouldDeliverEmptyOnNonMatchingCategoryType() {
        
        let (_, model) = makeOperatorWithModel(type: .charity)
        let (sut, _) = makeSUT(loadStub: [model])
        
        expect(
            sut: sut, 
            withLoadStub: [model],
            payload: makePayload(for: .digitalWallets),
            toDeliver: []
        )
    }
        
    func test_loadOperators_shouldDeliverOneOnValueOfOneForMatchingCategoryType() {
        
        let categoryType: CategoryType = .networkMarketing
        let (`operator`, model) = makeOperatorWithModel(type: categoryType)
        let (sut, _) = makeSUT(loadStub: [model])
        
        expect(
            sut: sut, 
            withLoadStub: [model],
            payload: makePayload(for: categoryType),
            toDeliver: [`operator`]
        )
    }
        
    func test_loadOperators_shouldDeliverTwoOnValueOfOneForMatchingCategoryType() {
        
        let categoryType: CategoryType = .socialAndGames
        let (operator1, model1) = makeOperatorWithModel(type: categoryType)
        let (operator2, model2) = makeOperatorWithModel(type: categoryType)
        let (sut, _) = makeSUT(loadStub: [model1, model2])
        
        expect(
            sut: sut, 
            withLoadStub: [model1, model2],
            payload: makePayload(for: categoryType),
            toDeliver: [operator1, operator2]
        )
    }
        
    // MARK: - Helpers
    
    private typealias LocalAgent = LocalAgentSpy<[CodableServicePaymentOperator]>
    private typealias Payload = UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    private typealias CategoryType = ServiceCategory.CategoryType
    
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
    
    private func makePaymentServiceOperator(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = anyMessage(),
        name: String = anyMessage(),
        type: String = anyMessage()
    ) -> PaymentServiceOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, name: name, type: type)
    }
    
    private func codable(
        _ `operator`: PaymentServiceOperator,
        sortedOrder: Int = .random(in: 1...100)
    ) -> CodableServicePaymentOperator {
        
        return .init(id: `operator`.id, inn: `operator`.inn, md5Hash: `operator`.md5Hash, name: `operator`.name, type: `operator`.type, sortedOrder: sortedOrder)
    }
    
    private func makeOperatorWithModel(
        type: ServiceCategory.CategoryType = .repaymentLoansAndAccounts,
        sortedOrder: Int = .random(in: 1...100)
    ) -> (PaymentServiceOperator, CodableServicePaymentOperator) {
        
        let `operator` = makePaymentServiceOperator(type: type.name)
        
        return (`operator`, codable(`operator`, sortedOrder: sortedOrder))
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
        
        sut.loadOperators(payload: payload) {
            
            XCTAssertNoDiff($0, expectedValue, "Expected \(String(describing: expectedValue)), but got \(String(describing: $0)) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: timeout)
    }
}
