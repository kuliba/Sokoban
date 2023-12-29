//
//  Model+getFastPaymentContractFindListTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
@testable import ForaBank
import XCTest

final class Model_getFastPaymentContractFindListTests: XCTestCase {
    
    func test_getFastPaymentContractFindList_shouldSendFPSCFLRequest() {
        
        let (sut, _, spy) = makeSUT()
        XCTAssertNoDiff(spy.values.count, 0)
        
        _ = sut.getFastPaymentContractFindList()
        
        XCTAssertNoDiff(spy.values.count, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsServices
    private typealias Spy = ValueSpy<Model.FPSCFLRequest>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        model: Model,
        spy: Spy
    ) {
        let model: Model = .mockWithEmptyExcept()
        let httpClient = HTTPClientSpy()
        let sut = Services.makeFastPaymentsServices(
            httpClient: httpClient,
            model: model,
            log: { _,_,_ in }
        )
        let spy = ValueSpy(model.fastPaymentSettingsContractFindList)
        
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, model, spy)
    }
}

// MARK: - DSL

private extension Model {
    
    typealias FPSCFLRequest = ModelAction.FastPaymentSettings.ContractFindList.Request
    typealias FastPaymentSettingsContractFindListPublisher = AnyPublisher<FPSCFLRequest, Never>
    
    var fastPaymentSettingsContractFindList: FastPaymentSettingsContractFindListPublisher {
        
        action
            .compactMap { $0 as? FPSCFLRequest }
            .eraseToAnyPublisher()
    }
}
