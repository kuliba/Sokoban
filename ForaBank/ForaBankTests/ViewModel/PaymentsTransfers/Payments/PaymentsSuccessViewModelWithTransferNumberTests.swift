//
//  PaymentsSuccessViewModelWithTransferNumberTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 25.11.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsSuccessViewModelWithTransferNumberTests: XCTestCase {
    
    func test_copyButtonDidTappedOnTransferNumber_shouldSetInformer() throws {
        
        let (sut, spy) = makeSUT()
        let transferNumber = try sut.transferNumberViewModel()
        XCTAssertNoDiff(spy.values, [nil])
        
        transferNumber.copyButtonDidTapped()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, .init("Номер скопирован")])
    }
    
    func test_copyButtonDidTappedOnTransferNumber_shouldResetInformerAfterTimeout() throws {
        
        let (sut, spy) = makeSUT()
        let transferNumber = try sut.transferNumberViewModel()
        XCTAssertNoDiff(spy.values, [nil])
        
        transferNumber.copyButtonDidTapped()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [nil, .init("Номер скопирован")])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 1.9)
        XCTAssertNoDiff(spy.values, [nil, .init("Номер скопирован")])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [nil, .init("Номер скопирован"), nil])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsSuccessViewModel
    
    private func makeSUT(
        transferNumber: String = UUID().uuidString,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<SUT.Informer?>
    ) {
        let param = Payments.ParameterSuccessTransferNumber(
            number: transferNumber
        )
        let viewModel = PaymentsSuccessTransferNumberView.ViewModel(
            param
        )
        let section = PaymentsSectionViewModel(
            placement: .feed,
            items: [viewModel]
        )
        let model: Model = .mockWithEmptyExcept()
        //        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        let adapter = PaymentsSuccessViewModelAdapterSpy(model: model)
        let sut = SUT(
            sections: [section],
            adapter: adapter,
            operation: nil
        )
        let spy = ValueSpy(sut.$informer)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leak tracking for model
        // trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(adapter, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}

private extension PaymentsSuccessViewModel {
    
    func parameterViewModel(
        with id: Payments.Parameter.ID
    ) throws -> PaymentsParameterViewModel {
        
        try XCTUnwrap(sections.flatMap(\.items).first(where: { $0.id == id }))
    }
    
    func transferNumberViewModel(
    ) throws -> PaymentsSuccessTransferNumberView.ViewModel {
        
        let id = Payments.Parameter.Identifier.successTransferNumber.rawValue
        let viewModel = try parameterViewModel(with: id)
        
        return try XCTUnwrap(viewModel as? PaymentsSuccessTransferNumberView.ViewModel)
    }
}
