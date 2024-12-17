//
//  PaymentProviderServicePickerFlowEffectHandlerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.07.2024.
//

@testable import ForaBank
import XCTest

final class PaymentProviderServicePickerFlowEffectHandlerTests: XCTestCase {
    
    func test_payByInstruction_shouldDeliverModel() {
        
        let model = makePaymentsViewModel()
        let sut = makeSUT(model: model)
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(.payByInstruction) {
            
            switch $0 {
            case let .payByInstruction(viewModel):
                XCTAssertTrue(viewModel === model)
                
            default:
                XCTFail("Expected `payByInstruction` event")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.05)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderServicePickerFlowEffectHandler
    
    private func makeSUT(
        model: PaymentsViewModel? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let model = model ?? makePaymentsViewModel()
        let sut = SUT(makePayByInstructionModel: { $0(model) })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makePaymentsViewModel(
    ) -> PaymentsViewModel {
        
        return .init(category: .general, model: .emptyMock, closeAction: {})
    }
}
