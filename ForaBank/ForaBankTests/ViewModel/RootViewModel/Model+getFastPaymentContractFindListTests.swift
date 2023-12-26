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
    
        let (sut, spy) = makeSUT()
        XCTAssertNoDiff(spy.values.count, 0)
        
        sut.getFastPaymentContractFindList()
        
        XCTAssertNoDiff(spy.values.count, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Model
    private typealias Spy = ValueSpy<Model.FPSCFLRequest>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let sut: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(sut.fastPaymentSettingsContractFindList)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
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
