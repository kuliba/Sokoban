//
//  PaymentProviderServicePickerFlowReducerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.07.2024.
//

@testable import ForaBank
import XCTest

final class PaymentProviderServicePickerFlowReducerTests: XCTestCase {
    
    // MARK: - dismissDestination
    
    func test_dismissDestination_shouldResetPaymentDestination() {
        
        let (state, effect) = makeSUT().reduce(
            makeState(destination: .payment(.preview(transaction: makeTransaction()))),
            .dismissDestination
        )
        
        XCTAssertNil(state.destination)
        XCTAssertNil(effect)
    }
    
    func test_dismissDestination_shouldResetPaymentByInstructionDestination() {
        
        let (state, effect) = makeSUT().reduce(
            makeState(destination: .paymentByInstruction(makePaymentsViewModel())),
            .dismissDestination
        )
        
        XCTAssertNil(state.destination)
        XCTAssertNil(effect)
    }
    
    func test_payByInstructionTap_shouldDeliverEffect() {
        
        let (_, effect) = makeSUT().reduce(makeState(), .payByInstructionTap)
        
        XCTAssertNoDiff(effect, .payByInstruction)
    }
    
    func test_payByInstruction_shouldSetDestination() {
        
        let model = makePaymentsViewModel()
        
        let (state, effect) = makeSUT().reduce(makeState(), .payByInstruction(model))
        
        switch state.destination {
        case let .paymentByInstruction(viewModel):
            XCTAssertTrue(viewModel === model)
            
        default:
            XCTFail("Expected `paymentByInstruction` destination")
        }
        
        XCTAssertNil(effect)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderServicePickerFlowReducer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        alert: PaymentProviderServicePickerFlowState.Alert? = nil,
        content: PaymentProviderServicePickerFlowState.Content? = nil,
        destination: PaymentProviderServicePickerFlowState.Destination? = nil,
        isContentLoading: Bool = false
    ) -> SUT.State {
        
        return .init(
            alert: alert,
            content: content ?? makeContent(),
            destination: destination,
            isContentLoading: isContentLoading
        )
    }
    
    private func makeContent(
        payload: PaymentProviderServicePickerPayload? = nil
    ) -> SUT.State.Content {
        
        return .init(
            initialState: .init(
                payload: payload ?? makePayload()
            ),
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        )
    }
    
    private func makePayload(
        id: String = anyMessage(),
        icon: String? = anyMessage(),
        inn: String? = anyMessage(),
        title: String = anyMessage(),
        segment: String = anyMessage(),
        sortedOrder: Int = .random(in: 1...100),
        qrCode: QRCode = .init(original: "", rawData: [:])
    ) -> PaymentProviderServicePickerPayload {
        
        return .init(
            provider: .init(
                id: id, 
                icon: icon,
                inn: inn,
                title: title,
                segment: segment,
                origin: .provider(.init(
                    id: id,
                    inn: inn ?? "",
                    md5Hash: icon,
                    title: title,
                    sortedOrder: sortedOrder
                ))
            ),
            qrCode: qrCode
        )
    }
    
    private func makeTransaction(
    ) -> SUT.State.Destination.Transaction {
        
        return .init(
            context: .init(
                initial: .init(amount: nil, elements: [], footer: .continue, isFinalStep: false),
                payment: .init(amount: nil, elements: [], footer: .continue, isFinalStep: false),
                staged: [],
                outline: .init(
                    amount: 0,
                    product: nil,
                    fields: [:],
                    payload: .init(
                        puref: anyMessage(), 
                        title: anyMessage(),
                        subtitle: anyMessage(),
                        icon: anyMessage()
                    )
                ),
                shouldRestart: false
            ),
            isValid: true
        )
    }
    
    private func makePaymentsViewModel(
    ) -> PaymentsViewModel {
        
        return .init(category: .general, model: .emptyMock, closeAction: {})
    }
}
