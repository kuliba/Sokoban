//
//  TemplatesListFlowModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import CombineSchedulers
@testable import ForaBank
import XCTest

final class TemplatesListFlowModelTests: XCTestCase {
    
    func test_init_shouldSetStatusToNil() {
        
        let (sut, _, statusSpy) = makeSUT()
        
        XCTAssertNoDiff(statusSpy.values, [nil])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldChangeStatusOnContentEmittingProductID() {
        
        let productID = makeProductID()
        let (sut, content, statusSpy) = makeSUT()
        
        content.productIDSubject.send(productID)
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.productID(productID))
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetDestinationOnContentEmittingTemplate() {
        
        let template = makeTemplate()
        let (sut, content, statusSpy) = makeSUT()
        
        content.templateSubject.send(template)
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.inflight),
            .destination(.payment)
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldResetDestinationOnPaymentDismiss() throws {
        
        let template = makeTemplate()
        let (sut, content, statusSpy) = makeSUT()
        content.templateSubject.send(template)
        
        try sut.dismissPayment()
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.inflight),
            .destination(.payment),
            .none
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TemplatesListFlowModel<Content>
    private typealias ProductID = ProductData.ID
    private typealias StatusSpy = ValueSpy<SUT.State.EquatableStatus?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        content: Content,
        statusSpy: StatusSpy
    ) {
        let content = Content()
        let reducer = TemplatesListFlowReducer<Content>()
        let sut = SUT(
            initialState: .init(content: content),
            reduce: reducer.reduce(_:_:),
            factory: .init(
                makePaymentModel: {
                    
                    return .init(source: .template($0.id), model: .emptyMock, closeAction: $1)
                }
            ),
            scheduler: .immediate
        )
        let statusSpy = StatusSpy(sut.$state.map(\.equatableStatus))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(content, file: file, line: line)
        trackForMemoryLeaks(statusSpy, file: file, line: line)
        
        return (sut, content, statusSpy)
    }
    
    private func makeProductID() -> ProductID {
        
        return .random(in: 1...100)
    }
    
    private func makeTemplate(
        id: Int = .random(in: 1...100),
        type: PaymentTemplateData.Kind = .sfp
    ) -> PaymentTemplateData {
        
        PaymentTemplateData.templateStub(paymentTemplateId: id, type: type)
    }
    
    private final class Content: ProductIDEmitter & TemplateEmitter {
        
        let productIDSubject = PassthroughSubject<ProductID, Never>()
        let templateSubject = PassthroughSubject<PaymentTemplateData, Never>()
        
        var productIDPublisher: AnyPublisher<ProductID, Never> {
            
            productIDSubject.eraseToAnyPublisher()
        }
        
        var templatePublisher: AnyPublisher<PaymentTemplateData, Never> {
            
            templateSubject.eraseToAnyPublisher()
        }
    }
}

private extension TemplatesListFlowState {
    
    var equatableStatus: EquatableStatus? {
        
        switch status {
        case .none:
            return .none
            
        case .destination(.payment):
            return .destination(.payment)
            
        case let .outside(outside):
            return .outside(outside)
        }
    }
    
    enum EquatableStatus: Equatable {
        
        case destination(Destination)
        case outside(Status.Outside)
        
        
        enum Destination: Equatable {
            
            case payment
        }
    }
}

// MARK: - DSL

private extension TemplatesListFlowModel {
    
    func dismissPayment(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let payment = try XCTUnwrap(state.payment, "Expected to have payment, but got nil instead.", file: file, line: line)
        payment.closeAction()
    }
}

private extension TemplatesListFlowState {
    
    var payment: PaymentsViewModel? {
        
        guard case let .payment(payment) = destination
        else { return nil }
        
        return payment
    }
}
