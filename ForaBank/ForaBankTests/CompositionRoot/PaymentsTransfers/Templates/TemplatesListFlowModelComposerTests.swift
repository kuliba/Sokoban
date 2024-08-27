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
        
        let (sut, _,_) = makeSUT()
        let exp = expectation(description: "wait for dismiss action")
        let flowModel = sut.compose { exp.fulfill() }
        
        try flowModel.dismissContent()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldSetTemplatesNavBarBackAction() throws {
        
        let (sut, _,_) = makeSUT()
        let exp = expectation(description: "wait for dismiss action")
        let flowModel = sut.compose { exp.fulfill() }
        
        try flowModel.dismissContentViaNavBarBackButton()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldDeliverLegacyOnLegacy() {
        
        let (sut, spy, _) = makeSUT()
        let flowModel = sut.compose {}
        
        flowModel.select(makeTemplate())
        spy.complete(with: .success(.legacy(.sample)))
        
        assertLegacyDestination(flowModel)
    }
    
    func test_compose_shouldCallCollaboratorWithTemplate() {
        
        let template = makeTemplate()
        let (sut, spy, _) = makeSUT()
        let flowModel = sut.compose {}
        
        flowModel.select(template)
        
        XCTAssertNoDiff(spy.payloads.map(\.0), [template])
    }
    
    func test_compose_shouldDeliverConnectivityFailureOnConnectivityError() {
        
        let (sut, spy, _) = makeSUT()
        let flowModel = sut.compose {}
        
        flowModel.select(makeTemplate())
        spy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(flowModel.state.alert, .connectivityError)
    }
    
    func test_compose_shouldDeliverServerFailureOnServerError() {
        
        let message = anyMessage()
        let (sut, spy, _) = makeSUT()
        let flowModel = sut.compose {}
        
        flowModel.select(makeTemplate())
        spy.complete(with: .failure(.serverError(message)))
        
        XCTAssertNoDiff(flowModel.state.alert, .serverError(message))
    }
    
    func test_compose_shouldDeliverV1OnSuccess() {
        
        let (sut, spy, composer) = makeSUT()
        let flowModel = sut.compose {}
        
        flowModel.select(makeTemplate())
        spy.complete(with: .success(.v1(composer.compose(transaction: makeTransaction()))))
        
        assertV1Destination(flowModel)
    }
    
    // MARK: - Helpers
    
    private typealias Flag = UtilitiesPaymentsFlag
    private typealias SUT = TemplatesListFlowModelComposer
    private typealias FlowModel = TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel>
    private typealias Transaction = AnywayTransactionState.Transaction
    private typealias MakePaymentSpy = Spy<(PaymentTemplateData, () -> Void), SUT.MicroServices.Payment, ServiceFailure>
    private typealias ServiceFailure = ServiceFailureAlert.ServiceFailure
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: MakePaymentSpy,
        composer: AnywayFlowComposer
    ) {
        let httpClient = HTTPClientSpy()
        let model: Model = .emptyMock
        let spy = MakePaymentSpy()
        let transactionComposer = AnywayTransactionViewModelComposer(
            flag: .stub,
            model: model,
            httpClient: httpClient,
            log: { _,_,_,_,_ in },
            scheduler: .immediate
        )
        let composer = AnywayFlowComposer(
            makeAnywayTransactionViewModel: transactionComposer.compose(transaction:),
            model: model,
            scheduler: .immediate
        )
        let sut = SUT(
            makeAnywayFlowModel: composer.compose(transaction:),
            model: model,
            microServices: .init(makePayment: spy.process),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(transactionComposer, file: file, line: line)
        
        return (sut, spy, composer)
    }
    
    private func makeTemplate(
        id: Int = .random(in: 1...100),
        type: PaymentTemplateData.Kind = .housingAndCommunalService
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
