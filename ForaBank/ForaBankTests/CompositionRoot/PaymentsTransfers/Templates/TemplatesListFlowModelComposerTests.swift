//
//  TemplatesListFlowModelComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.08.2024.
//

@testable import ForaBank
import XCTest

final class TemplatesListFlowModelComposerTests: XCTestCase {
    
    func test_compose_shouldSetTemplatesDismissAction() throws {
        
        let (sut, _) = makeSUT(flag: .inactive)
        let exp = expectation(description: "wait for dismiss action")
        let flowModel = sut.compose { exp.fulfill() }
        
        try flowModel.dismissContent()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldSetTemplatesNavBarBackAction() throws {
        
        let (sut, _) = makeSUT(flag: .inactive)
        let exp = expectation(description: "wait for dismiss action")
        let flowModel = sut.compose { exp.fulfill() }
        
        try flowModel.dismissContentViaNavBarBackButton()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldDeliverLegacyForInactiveFlag() throws {
        
        let (sut, _) = makeSUT(flag: .inactive)
        let flowModel = sut.compose {}
        
        flowModel.select(makeTemplate())
        
        assertLegacyDestination(flowModel)
    }
    
    func test_compose_shouldCallCollaboratorWithTemplateForActiveLiveFlag() throws {
        
        let template = makeTemplate()
        let (sut, spy) = makeSUT(flag: .active(.live))
        let flowModel = sut.compose {}
        
        flowModel.select(template)
        
        XCTAssertNoDiff(spy.payloads, [template])
    }
    
    func test_compose_shouldDeliverConnectivityFailureOnConnectivityErrorForActiveLiveFlag() throws {
        
        let (sut, spy) = makeSUT(flag: .active(.live))
        let flowModel = sut.compose {}
        
        flowModel.select(makeTemplate())
        spy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(flowModel.state.alert, .connectivityError)
    }
    
    func test_compose_shouldDeliverServerFailureOnServerErrorForActiveLiveFlag() throws {
        
        let message = anyMessage()
        let (sut, spy) = makeSUT(flag: .active(.live))
        let flowModel = sut.compose {}
        
        flowModel.select(makeTemplate())
        spy.complete(with: .failure(.serverError(message)))
        
        XCTAssertNoDiff(flowModel.state.alert, .serverError(message))
    }
    
    func test_compose_shouldDeliverV1OnSuccessForActiveLiveFlag() throws {
        
        let (sut, spy) = makeSUT(flag: .active(.live))
        let flowModel = sut.compose {}
        
        flowModel.select(makeTemplate())
        spy.complete(with: .success(makeTransaction()))
        
        assertV1Destination(flowModel)
    }
    
    // MARK: - Helpers
    
    private typealias Flag = UtilitiesPaymentsFlag
    private typealias SUT = TemplatesListFlowModelComposer
    private typealias FlowModel = TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel>
    private typealias Transaction = AnywayTransactionState.Transaction
    private typealias InitiatePaymentSpy = Spy<PaymentTemplateData, Transaction, ServiceFailure>
    private typealias ServiceFailure = ServiceFailureAlert.ServiceFailure

    private func makeSUT(
        flag: Flag.RawValue,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: InitiatePaymentSpy
    ) {
        let httpClient = HTTPClientSpy()
        let model: Model = .emptyMock
        let spy = InitiatePaymentSpy()
        let sut = SUT(
            composer: .init(
                composer: .init(
                    flag: .init(flag),
                    model: model,
                    httpClient: httpClient,
                    log: { _,_,_,_,_ in },
                    scheduler: .immediate
                ),
                model: model,
                scheduler: .immediate
            ),
            model: model,
            nanoServices: .init(initiatePayment: spy.process(_:completion:)),
            utilitiesPaymentsFlag: .init(flag),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeTemplate(
        id: Int = .random(in: 1...100),
        type: PaymentTemplateData.Kind = .sfp
    ) -> PaymentTemplateData {
        
        return .templateStub(paymentTemplateId: id, type: type)
    }
    
    private func makeTransaction(
    ) -> Transaction {
        
        return .init(
            context: .init(
                initial: .init(
                    amount: nil, 
                    elements: [], 
                    footer: .continue,
                    isFinalStep: false
                ),
                payment: .init(
                    amount: nil, 
                    elements: [], 
                    footer: .continue,
                    isFinalStep: false
                ),
                staged: .init(),
                outline: .init(
                    amount: nil,
                    product: .init(
                        currency: "RUB",
                        productID: 1,
                        productType: .card
                    ),
                    fields: .init(),
                    payload: .init(
                        puref: anyMessage(),
                        title: anyMessage(),
                        subtitle: nil,
                        icon: nil
                    )
                ),
                shouldRestart: false
            ),
            isValid: true
        )
    }
    
    private func assertLegacyDestination(
        _ flowModel: FlowModel,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flowModel.state.status {
        case .destination(.payment(.legacy)):
            break
            
        default:
            XCTFail("Expected to have legacy destination but got \(String(describing: flowModel.state.status)) instead.", file: file, line: line)
        }
    }
    
    private func assertV1Destination(
        _ flowModel: FlowModel,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flowModel.state.status {
        case .destination(.payment(.v1)):
            break
            
        default:
            XCTFail("Expected to have legacy destination but got \(String(describing: flowModel.state.status)) instead.", file: file, line: line)
        }
    }
}

// MARK: - DSL

private extension TemplatesListFlowModel
where Content == TemplatesListViewModel {
    
    func select(_ template: PaymentTemplateData) {
        
        let action = TemplatesListViewModelAction.OpenDefaultTemplate(template: template)
        state.content.action.send(action)
    }
    
    func dismissContent(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        state.content.dismissAction()
    }
    
    func dismissContentViaNavBarBackButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

        let navBar = try XCTUnwrap(state.content.navBarState.regularModel, "Expected to have regular nav bar", file: file, line: line)
        navBar.backButton.action()
    }
}

private extension TemplatesListFlowState {
    
    var alert: Status.ServiceFailure? {
        
        guard case let .alert(alert) = status else { return nil }
        
        return alert
    }
}
