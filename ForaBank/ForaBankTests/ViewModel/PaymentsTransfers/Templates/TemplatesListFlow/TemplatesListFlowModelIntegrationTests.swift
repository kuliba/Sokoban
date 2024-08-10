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
    
    // MARK: - init
    
    func test_init_shouldSetStatusToNil() {
        
        let (sut, _, statusSpy, _) = makeSUT()
        
        XCTAssertNoDiff(statusSpy.values, [nil])
        XCTAssertNotNil(sut)
    }
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, _,_, makePaymentSpy) = makeSUT()
        
        XCTAssertEqual(makePaymentSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - emit productID
    
    func test_shouldChangeStatusOnContentEmittingProductID() {
        
        let productID = makeProductID()
        let (sut, content, statusSpy, _) = makeSUT()
        
        content.emitProductID(productID)
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.productID(productID))
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - emit template
    
    func test_shouldCallMakePaymentWithTemplateOnContentEmittingTemplate() {
        
        let template = makeTemplate()
        let (sut, content, _, makePaymentSpy) = makeSUT()
        
        content.emitTemplate(template)
        makePaymentSpy.complete(with: .success(makeLegacy()))
        
        XCTAssertNoDiff(makePaymentSpy.payloads.map(\.0), [template])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallMakePaymentWithDismissDestinationClosureOnContentEmittingTemplate() {
        
        let (sut, content, statusSpy, makePaymentSpy) = makeSUT()
        
        content.emitTemplate(makeTemplate())
        makePaymentSpy.complete(with: .success(makeLegacy()))
        makePaymentSpy.payloads.last?.1()
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.inflight),
            .destination(.payment(.legacy)),
            .none
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetLegacyPaymentCloseActionOnContentEmittingTemplate() throws {
        
        let (sut, content, _, makePaymentSpy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        content.emitTemplate(makeTemplate())
        makePaymentSpy.complete(with: .success(makeLegacy(close: { exp.fulfill() })))
        
        try sut.dismissLegacyPayment()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_shouldSetLegacyPaymentDestinationOnContentEmittingTemplate() {
        
        let (sut, content, statusSpy, makePaymentSpy) = makeSUT()
        
        content.emitTemplate(makeTemplate())
        makePaymentSpy.complete(with: .success(makeLegacy()))
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.inflight),
            .destination(.payment(.legacy))
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetConnectivityAlertOnMakePaymentServerErrorOnContentEmittingTemplate() {
        
        let (sut, content, statusSpy, makePaymentSpy) = makeSUT()
        
        content.emitTemplate(makeTemplate())
        makePaymentSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.inflight),
            .alert(.connectivityError)
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetServerErrorAlertOnMakePaymentServerErrorOnContentEmittingTemplate() {
        
        let message = anyMessage()
        let (sut, content, statusSpy, makePaymentSpy) = makeSUT()
        
        content.emitTemplate(makeTemplate())
        makePaymentSpy.complete(with: .failure(.serverError(message)))
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.inflight),
            .alert(.serverError(message))
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TemplatesListFlowModel<Content>
    private typealias ProductID = ProductData.ID
    private typealias StatusSpy = ValueSpy<SUT.State.EquatableStatus?>
    private typealias MicroServices = TemplatesListFlowEffectHandlerMicroServices
    private typealias MakePaymentSpy = Spy<MicroServices.MakePaymentPayload, SUT.Event.Payment, ServiceFailure>
    private typealias ServiceFailure = ServiceFailureAlert.ServiceFailure
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        content: Content,
        statusSpy: StatusSpy,
        makePaymentSpy: MakePaymentSpy
    ) {
        let content = Content()
        let reducer = TemplatesListFlowReducer<Content>()
        let makePaymentSpy = MakePaymentSpy()
        let effectHandler = TemplatesListFlowEffectHandler(
            microServices: .init(
                makePayment: makePaymentSpy.process(_:completion:)
            )
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
        trackForMemoryLeaks(makePaymentSpy, file: file, line: line)
        
        return (sut, content, statusSpy, makePaymentSpy)
    }
    
    private func makeProductID() -> ProductID {
        
        return .random(in: 1...100)
    }
    
    private func makeTemplate(
        id: Int = .random(in: 1...100),
        type: PaymentTemplateData.Kind = .sfp
    ) -> PaymentTemplateData {
        
        return .templateStub(paymentTemplateId: id, type: type)
    }
    
    private func makeLegacy(
        _ template: PaymentTemplateData? = nil,
        close: @escaping () -> Void = {}
    ) -> SUT.Event.Payment {
        
        return .legacy(.init(
            source: .template((template ?? makeTemplate()).id),
            model: .emptyMock,
            closeAction: close
        ))
    }
    
    private final class Content: ProductIDEmitter & TemplateEmitter {
        
        private let productIDSubject = PassthroughSubject<ProductID, Never>()
        private let templateSubject = PassthroughSubject<PaymentTemplateData, Never>()
        
        var productIDPublisher: AnyPublisher<ProductID, Never> {
            
            productIDSubject.eraseToAnyPublisher()
        }
        
        var templatePublisher: AnyPublisher<PaymentTemplateData, Never> {
            
            templateSubject.eraseToAnyPublisher()
        }
        
        func emitProductID(_ productID: ProductID) {
            
            productIDSubject.send(productID)
        }
        
        func emitTemplate(_ template: PaymentTemplateData) {
            
            templateSubject.send(template)
        }
    }
}

private extension TemplatesListFlowState {
    
    var equatableStatus: EquatableStatus? {
        
        switch status {
        case .none:
            return .none
            
        case let .alert(serviceFailure):
            return .alert(serviceFailure)
            
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
        
        case alert(Status.ServiceFailure)
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
