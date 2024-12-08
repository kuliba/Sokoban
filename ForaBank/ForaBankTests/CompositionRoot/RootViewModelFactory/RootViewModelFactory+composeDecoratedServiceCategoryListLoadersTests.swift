//
//  RootViewModelFactory+composeDecoratedServiceCategoryListLoadersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.12.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_composeDecoratedServiceCategoryListLoadersTests: RootViewModelFactoryServiceCategoryTests {
    
    // MARK: - load
    
    func test_load_shouldDeliverNilOnEmptyLocalHTTPClientFailure() {
        
        let emptyLocalAgent = LocalAgent()
        
        expectLoad(nil, emptyLocalAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            
            httpClient.complete(with: anyError())
            self.awaitActorThreadHop()
            
            httpClient.expectRequests(withQueryValueFor: "type", match: [
                "getServiceCategoryList",
            ])
            XCTAssertEqual(localAgent.loadCallCount, 2)
            XCTAssertEqual(localAgent.storeCallCount, 0)
        }
    }
    
    func test_load_shouldDeliverRemoteCategoriesOnEmptyLocalHTTPClientSuccess() {
        
        let emptyLocalAgent = LocalAgent()
        let (remoteCategories, json) = (categories(), getServiceCategoryListJSON())
        
        expectLoad(remoteCategories, emptyLocalAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            
            httpClient.complete(with: json)
            self.awaitActorThreadHop()
            
            httpClient.expectRequests(withQueryValueFor: "type", match: [
                "getServiceCategoryList",
            ])
            XCTAssertEqual(localAgent.loadCallCount, 2)
            XCTAssertEqual(localAgent.storeCallCount, 1)
        }
    }
    
    func test_load_shouldDeliverLocalCategoriesWithNoHTTPClientCalls() {
        
        let (localCategories, categoryModelStub) = makeCategoryWithModel()
        let localAgent = LocalAgentMock(stubs: [([categoryModelStub], anyMessage())])
        
        expectLoad([localCategories], localAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            
            XCTAssertEqual(localAgent.loadCallCount, 1)
            XCTAssertEqual(localAgent.storeCallCount, 0)
            XCTAssertEqual(httpClient.callCount, 0)
        }
    }
    
    // MARK: - reload
    
    func test_reload_shouldDeliverNilOnHTTPClientFailureEmptyLocal() {
        
        let emptyLocalAgent = LocalAgent()
        
        expectReload(nil, emptyLocalAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            XCTAssertEqual(localAgent.loadCallCount, 1)
            
            httpClient.complete(with: anyError())
            self.awaitActorThreadHop()
        }
    }
    
    func test_reload_shouldNotCacheOnHTTPClientFailureEmptyLocal() {
        
        let emptyLocalAgent = LocalAgent()
        
        expectReload(nil, emptyLocalAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            
            httpClient.complete(with: anyError())
            self.awaitActorThreadHop()
            
            XCTAssertEqual(localAgent.storeCallCount, 0)
        }
    }
    
    func test_reload_shouldNotMakeAnotherRequestOnHTTPClientFailureEmptyLocal() {
        
        let emptyLocalAgent = LocalAgent()
        
        expectReload(nil, emptyLocalAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            
            httpClient.complete(with: anyError())
            self.awaitActorThreadHop()
            
            httpClient.expectRequests(withQueryValueFor: "type", match: [
                "getServiceCategoryList",
            ])
        }
    }
    
    func test_reload_shouldDeliverLocalCategoriesOnHTTPClientFailure() {
        
        let (localCategories, categoryModelStub) = makeCategoryWithModel()
        let localAgent = LocalAgentMock(stubs: [([categoryModelStub], anyMessage())])
        
        expectReload([localCategories], localAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            httpClient.complete(with: anyError())
        }
    }
    
    func test_reload_shouldCallForOperatorsWithTypeOfLocalCategoriesOnHTTPClientFailure() {
        
        let (localCategories, categoryModelStub) = makeCategoryWithModel(type: .security)
        let localAgent = LocalAgentMock(stubs: [([categoryModelStub], anyMessage())])
        
        expectReload([localCategories], localAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            
            httpClient.complete(with: anyError())
            self.awaitActorThreadHop()
            
            httpClient.expectRequests(withQueryValueFor: "type", match: [
                "getServiceCategoryList",
                "getOperatorsListByParam-security",
            ])
            XCTAssertEqual(localAgent.loadCallCount, 2)
            XCTAssertEqual(localAgent.storeCallCount, 0)
        }
    }
    
    func test_reload_shouldDeliverLocalOnHTTPClientWithSameSerial() {
        
        let (serial, json) = (serial(), getServiceCategoryListJSON())
        let (localCategories, categoryModelStub) = makeCategoryWithModel(type: .charity)
        let localAgent = LocalAgentMock(stubs: [([categoryModelStub], serial)])
        
        expectReload([localCategories], localAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            httpClient.complete(with: json)
        }
    }
    
    func test_reload_shouldCallForOperatorsWithTypeOfLocalCategoriesOnHTTPClientWithSameSerial() {
        
        let (serial, json) = (serial(), getServiceCategoryListJSON())
        let (localCategories, categoryModelStub) = makeCategoryWithModel(type: .charity)
        let localAgent = LocalAgentMock(stubs: [([categoryModelStub], serial)])
        
        expectReload([localCategories], localAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            
            httpClient.complete(with: json)
            self.awaitActorThreadHop()
            
            httpClient.expectRequests(withQueryValueFor: "type", match: [
                "getServiceCategoryList",
                "getOperatorsListByParam-charity",
            ])
            XCTAssertEqual(localAgent.loadCallCount, 2)
            XCTAssertEqual(localAgent.storeCallCount, 0)
        }
    }
    
    func test_reload_shouldDeliverRemoteOnHTTPClientWithDifferentSerial() {
        
        let (_, categoryModelStub) = makeCategoryWithModel()
        let localAgent = LocalAgentMock(stubs: [([categoryModelStub], anyMessage())])
        let (remoteCategories, json) = (categories(), getServiceCategoryListJSON())
        
        expectReload(remoteCategories, localAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            httpClient.complete(with: json)
        }
    }
    
    func test_reload_shouldCacheOnHTTPClientWithDifferentSerial() {
        
        let (_, categoryModelStub) = makeCategoryWithModel()
        let localAgent = LocalAgentMock(stubs: [([categoryModelStub], anyMessage())])
        let (remoteCategories, json) = (categories(), getServiceCategoryListJSON())
        
        expectReload(remoteCategories, localAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            
            httpClient.complete(with: json)
            self.awaitActorThreadHop()
            
            XCTAssertEqual(localAgent.storeCallCount, 1)
        }
    }
    
    func test_reload_shouldCallForOperatorsWithStandardFlowOnHTTPClientWithDifferentSerial() {
        
        let (_, categoryModelStub) = makeCategoryWithModel()
        let localAgent = LocalAgentMock(stubs: [([categoryModelStub], anyMessage())])
        let (remoteCategories, json) = (categories(), getServiceCategoryListJSON())
        XCTAssertNoDiff(remoteCategories.map(\.type), [.mobile, .housingAndCommunalService, .internet])
        XCTAssertNoDiff(remoteCategories.map(\.paymentFlow), [.mobile, .standard, .standard])
        
        expectReload(remoteCategories, localAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            
            httpClient.complete(with: json)
            self.awaitActorThreadHop()
            
            httpClient.complete(with: anyError(), at: 1)
            self.awaitActorThreadHop()
            
            httpClient.complete(with: anyError(), at: 2)
            self.awaitActorThreadHop()
            
            // does not call for `mobile` with non-standard flow
            httpClient.expectRequests(withQueryValueFor: "type", match: [
                "getServiceCategoryList",
                "getOperatorsListByParam-housingAndCommunalService",
                "getOperatorsListByParam-internet"
            ])
        }
    }
    
    func test_reload_shouldCacheLoadedOperators() {
        
        let (_, categoryModelStub) = makeCategoryWithModel()
        let localAgent = LocalAgentMock(stubs: [([categoryModelStub], anyMessage())])
        let (remoteCategories, categoriesJSON) = (categories(), getServiceCategoryListJSON())
        
        expectReload(remoteCategories, localAgent) { httpClient, localAgent in
            
            self.awaitActorThreadHop()
            XCTAssertNil(localAgent.lastStoredValue(ofType: [CodableServicePaymentOperator].self))
            
            httpClient.complete(with: categoriesJSON)
            self.awaitActorThreadHop()
            
            httpClient.complete(with: self.getOperatorsListByParamJSON(), at: 1)
            self.awaitActorThreadHop()
            
            XCTAssertEqual(localAgent.getStoredValues(ofType: [CodableServicePaymentOperator].self).count, 1, "Expected to cache Operators once.")
            XCTAssertNoDiff(localAgent.lastStoredValue(ofType: [CodableServicePaymentOperator].self)?.map(\.name), [
                "ООО МЕТАЛЛЭНЕРГОФИНАНС",
                "ООО  ИЛЬИНСКОЕ ЖКХ",
                "ТОВАРИЩЕСТВО СОБСТВЕННИКОВ НЕДВИЖИМОСТИ ЧИСТОПОЛЬСКАЯ 61 А",
            ])
        }
    }
    
    // MARK: - Helpers
    
    private typealias LocalAgent = LocalAgentMock
    
    private func makeCategoryWithModel(
        type: CodableServiceCategory.CategoryType = .education
    ) -> (ServiceCategory, CodableServiceCategory) {
        
        let model = makeCodableServiceCategory(type: type)
        
        return (model.serviceCategory, model)
    }
    
    private func expectLoad(
        _ expectedCategories: [ServiceCategory]?,
        _ localAgent: LocalAgent = .init(),
        on action: @escaping (HTTPClientSpy, LocalAgent) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let (sut, httpClient, _) = makeSUT(model: model, file: file, line: line)
        let (load, _) = sut.composeDecoratedServiceCategoryListLoaders()
        
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, expectedCategories, "Expected \(String(describing: expectedCategories)), but got \(String(describing: $0)) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        action(httpClient, localAgent)
        
        wait(for: [exp], timeout: 1.0)
    }
    private func expectReload(
        _ expectedCategories: [ServiceCategory]?,
        _ localAgent: LocalAgent,
        on action: @escaping (HTTPClientSpy, LocalAgent) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let (sut, httpClient, _) = makeSUT(model: model, file: file, line: line)
        let (_, reload) = sut.composeDecoratedServiceCategoryListLoaders()
        
        let exp = expectation(description: "wait for load completion")
        
        reload {
            
            XCTAssertNoDiff($0, expectedCategories, "Expected \(String(describing: expectedCategories)), but got \(String(describing: $0)) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        action(httpClient, localAgent)
        
        wait(for: [exp], timeout: 1.0)
    }
}
