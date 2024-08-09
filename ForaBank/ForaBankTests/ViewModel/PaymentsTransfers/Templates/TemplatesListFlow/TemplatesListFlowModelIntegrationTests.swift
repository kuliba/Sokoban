//
//  TemplatesListFlowModelIntegrationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import CombineSchedulers
@testable import ForaBank
import XCTest

final class TemplatesListFlowModelIntegrationTests: XCTestCase {
    
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
    
    func test_shouldSetLegacyPaymentDestinationOnContentEmittingTemplate() {
        
        let template = makeTemplate()
        let (sut, content, statusSpy) = makeSUT()
        
        content.templateSubject.send(template)
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.inflight),
            .destination(.payment(.legacy))
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldResetDestinationOnLegacyPaymentDismiss() throws {
        
        let template = makeTemplate()
        let (sut, content, statusSpy) = makeSUT()
        content.templateSubject.send(template)
        
        try sut.dismissLegacyPayment()
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.inflight),
            .destination(.payment(.legacy)),
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
        let microServices = TemplatesListFlowEffectHandlerMicroServices(
            makePayment: { template, close in
                
                return .legacy(.init(
                    source: .template(template.id),
                    model: .emptyMock,
                    closeAction: close
                ))
            }
        )
        let effectHandler = TemplatesListFlowEffectHandler(
            microServices: microServices
        )
        
        let sut = SUT(
            initialState: .init(content: content),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
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
            
        case let .destination(.payment(payment)):
            switch payment {
            case .legacy:
                return .destination(.payment(.legacy))
            }
            
        case let .outside(outside):
            return .outside(outside)
        }
    }
    
    enum EquatableStatus: Equatable {
        
        case destination(Destination)
        case outside(Status.Outside)
        
        enum Destination: Equatable {
            
            case payment(Payment)
            
            enum Payment: Equatable {
                
                case legacy
            }
        }
    }
}

// MARK: - DSL

private extension TemplatesListFlowModel {
    
    func dismissLegacyPayment(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let payment = try XCTUnwrap(state.legacy, "Expected to have payment, but got nil instead.", file: file, line: line)
        payment.closeAction()
    }
}

private extension TemplatesListFlowState {
    
    var legacy: PaymentsViewModel? {
        
        guard case let .payment(.legacy(legacy)) = destination
        else { return nil }
        
        return legacy
    }
}
