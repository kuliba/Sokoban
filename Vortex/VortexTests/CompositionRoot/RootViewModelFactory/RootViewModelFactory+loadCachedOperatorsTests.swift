//
//  RootViewModelFactory+loadCachedOperatorsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import ForaBank
import PayHub
import XCTest

final class RootViewModelFactory_loadCachedOperatorsTests: RootViewModelFactoryTests {
    
    func test_init_shouldNotCallLocalAgent() {
        
        let (_, localAgent) = makeSUT()
        
        XCTAssertEqual(localAgent.loadCallCount, 0)
    }
    
    func test_loadCachedOperators_shouldCallLocalAgent() {
        
        let (sut, localAgent) = makeSUT()
        
        sut.loadCachedOperators(payload: makePayload()) { _ in }
        
        XCTAssertEqual(localAgent.loadCallCount, 1)
    }
    
    func test_loadCachedOperators_shouldDeliverEmptyOnMissingValue() {
        
        expect(withLoadStub: nil, payload: makePayload(), toDeliver: [])
    }
        
    func test_loadCachedOperators_shouldDeliverEmptyOnEmptyValue() {
        
        expect(withLoadStub: [], payload: makePayload(), toDeliver: [])
    }
        
    func test_loadCachedOperators_shouldDeliverEmptyOnNonMatchingCategoryType() {
        
        let (_, model) = makeOperatorWithModel(type: .charity)
        let (sut, _) = makeSUT(loadStub: [model])
        
        expect(
            sut: sut, 
            withLoadStub: [model],
            payload: makePayload(for: .digitalWallets),
            toDeliver: []
        )
    }
        
    func test_loadCachedOperators_shouldDeliverOneOnValueOfOneForMatchingCategoryType() {
        
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
        
    func test_loadCachedOperators_shouldDeliverTwoOnValueOfOneForMatchingCategoryType() {
        
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
    private typealias Payload = LoadOperatorsPayload
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
        
        return .init(categoryType: type, operatorID: id, searchText: searchText, pageSize: pageSize)
    }
    
    private func codable(
        _ `operator`: UtilityPaymentProvider,
        sortedOrder: Int = .random(in: 1...100)
    ) -> CodableServicePaymentOperator {
        
        return .init(id: `operator`.id, inn: `operator`.inn, md5Hash: `operator`.icon, name: `operator`.name, type: `operator`.type, sortedOrder: sortedOrder)
    }
    
    private func makeOperatorWithModel(
        type: ServiceCategory.CategoryType = .repaymentLoansAndAccounts,
        sortedOrder: Int = .random(in: 1...100)
    ) -> (UtilityPaymentProvider, CodableServicePaymentOperator) {
        
        let `operator` = makePaymentServiceOperator(type: type.name)
        
        return (`operator`, codable(`operator`, sortedOrder: sortedOrder))
    }
    
    private func expect(
        sut: SUT? = nil,
        withLoadStub loadStub: [CodableServicePaymentOperator]?,
        payload: Payload,
        toDeliver expectedValue: [UtilityPaymentProvider],
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(loadStub: loadStub).sut
        let exp = expectation(description: "wait for load completion")
        
        sut.loadCachedOperators(payload: payload) {
            
            XCTAssertNoDiff($0, expectedValue, "Expected \(String(describing: expectedValue)), but got \(String(describing: $0)) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: timeout)
    }
}

extension UtilityPaymentProvider {
    
    var name: String { title }
}
