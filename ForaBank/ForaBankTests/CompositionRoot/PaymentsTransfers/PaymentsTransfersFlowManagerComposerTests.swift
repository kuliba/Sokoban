//
//  PaymentsTransfersFlowManagerComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.05.2024.
//

@testable import ForaBank
import XCTest

final class PaymentsTransfersFlowManagerComposerTests: XCTestCase {
    
    func test_compose_inactive_shouldNotFail() {
        
        _ = makeSUT(flag: .inactive).compose(nil)
    }
    
    func test_compose_live_shouldNotFail() {
        
        _ = makeSUT(flag: .active(.live)).compose(nil)
    }
    
    func test_compose_stub_shouldNotFail() {
        
        _ = makeSUT(flag: .active(.stub)).compose(nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersFlowManagerComposer
    
    private func makeSUT(
        flag: UtilitiesPaymentsFlag.RawValue,
        model: Model? = nil,
        pageSize: Int = 30,
        observeLast: Int = 5,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let model = model ?? .mockWithEmptyExcept()
        let httpClient = HTTPClientSpy()
        let sut = SUT(
            flag: .init(flag),
            model: model,
            httpClient: httpClient,
            log: { _,_,_,_,_  in },
            pageSize: pageSize,
            observeLast: observeLast
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        
        return sut
    }
}
