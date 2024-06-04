//
//  Model+SuccessTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 12.08.2023.
//

import Foundation

import XCTest
@testable import ForaBank

final class ModelSuccessTests: XCTestCase {
    
    //MARK: TemplateButtonState
    
    func test_templateButtonState_withOutTemplate_shouldReturnIdle() {
        
        let sut = makeSUT()
        
        XCTAssertNoDiff(sut, .idle)
    }
    
    func test_templateButtonState_withDirectTemplate_shouldReturnIdle() {
        
        let sut = makeSUT(template: directTemplate())
        
        XCTAssertNoDiff(sut, .idle)
    }
    
    func test_templateButtonState_shouldReturnRefresh_onRegularService() {
        
        let sut = makeSUT(
            template: templateWithParameterList(),
            operation: regularPaymentService(),
            detail: detailWithAmount()
        )
        
        XCTAssertNoDiff(sut, .refresh)
    }
    
    func test_templateButtonState_shouldReturnIdle_onRegularService_withDetailCardId() {
        
        let sut = makeSUT(
            template: templateWithParameterList(),
            operation: regularPaymentService(),
            detail: anyDetailWithCardID()
        )
        
        XCTAssertNoDiff(sut, .refresh)
    }
    
    func test_templateButtonState_shouldReturnIdle_onRegularService_templatePayeeExternalNil() {
        
        let sut = makeSUT(
            template: templateWithPayeeExternalNil(),
            operation: regularPaymentService(),
            detail: anyDetailWithCardID()
        )
        
        XCTAssertNoDiff(sut, .idle)
    }
    
    func test_templateButtonState_shouldReturnComplete_onAnotherCardOperation_withEqualProductId() {
        
        let sut = makeSUT(
            template: templateWithPayeeExternalNil(),
            operation: makeToAnotherCardOperation(productTemplateValue: "1"),
            detail: anyDetailWithCardID(cardID: 1)
        )
        
        XCTAssertNoDiff(sut, .complete)
    }
    
    func test_templateButtonState_shouldReturnRefresh_onAnotherCardOperation_withDifferentProductId() {
        
        let sut = makeSUT(
            template: templateWithPayeeExternalNil(),
            operation: makeToAnotherCardOperation(productTemplateValue: "2"),
            detail: anyDetailWithCardID(cardID: 1)
        )
        
        XCTAssertNoDiff(sut, .refresh)
    }
    
    func test_templateButtonState_shouldReturnComplete_onC2bOperation() {
                
        let sut = makeSUT(
            template: templateWithParameterList(),
            operation: makeC2bOperation(),
            detail: anyDetailWithCardID()
        )
        
        XCTAssertNoDiff(sut, .complete)
    }
    
    func test_templateButtonState_shouldReturnComplete_onC2bOperation_withParameterAnyway() {
        
        let sut = makeSUT(
            template: templateWithParameterAnyway(),
            operation: regularPaymentService(service: .c2b),
            detail: anyDetailWithCardIDAndAmount()
        )
        
        XCTAssertNoDiff(sut, .complete)
    }
    
    func test_templateButtonState_shouldReturnComplete_onUtilityOperation_withCardIdAndAmount() {
        
        let sut = makeSUT(
            template: templateWithParameterAnyway(),
            operation: makeUtilityOperation(),
            detail: anyDetailWithCardIDAndAmount()
        )
        
        XCTAssertNoDiff(sut, .complete)
    }
    
    func test_templateButtonState_shouldReturnRefresh_onRegularOperation_withOneParameter() {
        
        let sut = makeSUT(
            template: templateWithParameterAnyway(),
            operation: makeOperationWithOneParameter(),
            detail: anyDetailWithCardIDAndAmount()
        )
        
        XCTAssertNoDiff(sut, .refresh)
    }
    
    func test_templateButtonState_shouldReturnComplete_onMeToMePayment_withGeneralParametersLists() {
        
        let amount = 100.0
        
        let sut = makeSUT(
            
            template: templateWithGeneralParameter(amount: amount),
            meToMePayment: meToMePayment(),
            detail: anyDetailWithCardIDAndAmount()
        )
        
        XCTAssertNoDiff(sut, .complete)
    }
    
    func test_templateButtonState_shouldReturnIdle_onMeToMePayment_withPayeeExternalNil_amountNil() {
        
        let sut = makeSUT(
            template: templateWithGeneralParameter(
                    payeeExternal: nil,
                    amount: nil
                ),
            meToMePayment: meToMePayment(),
            detail: anyDetailWithCardIDAndAmount()
        )
        
        XCTAssertNoDiff(sut, .idle)
    }
    
    func test_templateButtonState_shouldReturnRefresh_onMeToMePayment() {
        
        let amount = 100.0
        
        let sut = makeSUT(
            template: templateWithGeneralParameter(amount: amount),
            meToMePayment: meToMePayment(payerProductId: 2),
            detail: anyDetailWithCardIDAndAmount()
        )
        
        XCTAssertNoDiff(sut, .refresh)
    }
    
    // MARK: - Helpers
    
    private func regularPaymentService(
        service: Payments.Service = .abroad
    ) -> Payments.Operation {
        
        return .init(service: service)
    }
    
    private func makeOperationWithOneParameter() -> Payments.Operation {
        
        let operation = paymentOperationStub(
            service: .avtodor,
            parameters: [
                Payments.ParameterMock(
                    id: "RecipientID",
                    value: "123123"
                )
            ]
        )
        
        return operation
    }
    
    private func makeUtilityOperation() -> Payments.Operation {
        
        let parameters = [
            Payments.ParameterMock(
                id: "trnPickupPoint",
                value: "AM"
            ),
            Payments.ParameterMock(
                id: "RecipientID",
                value: "123123"
            )
        ]
        
        let operation = paymentOperationStub(
            service: .avtodor,
            parameters: parameters
        )
        
        return operation
    }
    
    private func makeC2bOperation() -> Payments.Operation {
        
        let operation = paymentOperationStub(
            service: .c2b,
            parameters: requisitesParameters()
        )

        return operation
    }
    
    private func makeToAnotherCardOperation(
        productTemplateValue: String
    ) -> Payments.Operation {
        
        let parameters = [Payments.ParameterMock(
            id: Payments.Parameter.Identifier.productTemplate.rawValue,
            value: productTemplateValue
        )]
        
        let operation = paymentOperationStub(
            service: .toAnotherCard,
            parameters: parameters
        )
        
        return operation
    }
    
    private func requisitesParameters() -> [PaymentsParameterRepresentable] {
    
        let parameters = [
            Payments.ParameterMock(
                id: Payments.Parameter.Identifier.requisitsInn.rawValue,
                value: "7733126977"),
            Payments.ParameterMock(
                id: Payments.Parameter.Identifier.requisitsKpp.rawValue,
                value: "773301001"),
            Payments.ParameterMock(
                id: Payments.Parameter.Identifier.requisitsAccountNumber.rawValue,
                value: "40702810238170103538"),
            Payments.ParameterMock(
                id: Payments.Parameter.Identifier.requisitsName.rawValue,
                value: "Эстейт Сервис"),
            Payments.ParameterMock(
                id: Payments.Parameter.Identifier.requisitsMessage.rawValue,
                value: "comment")
        ]
        
        return parameters
    }
    
    private func templateWithParameterAnyway() -> PaymentTemplateData {
        
        templateWithParameterList(
            with: TransferAnywayData.anywayStub()
        )
    }
    
    private func templateWithPayeeExternalNil(
        amount: Decimal = 10,
        cardId: Int = 1
    ) -> PaymentTemplateData {
        
        templateWithParameterList(
            with: TransferGeneralData.generalStub(
                payeeExternal: nil,
                amount: amount,
                cardId: cardId
            ))
    }
    
    private func meToMePayment(
        with amount: Double = 100,
        payerProductId: Int = 1
    ) -> MeToMePayment {
        .init(payerProductId: payerProductId, payeeProductId: 1, amount: amount)
    }
    
    private func anyDetailWithCardIDAndAmount() -> OperationDetailData {

        return .stub(payerCardId: 10000184511, amount: 100)
    }

    
    private func anyDetailWithCardID(
        cardID: Int = 1,
        amount: Double = 10
    ) -> OperationDetailData {
    
        return .stub(payerCardId: cardID, amount: amount)
    }
    
    private func detailWithAmount(
        detail: OperationDetailData = .stub(amount: 100)
    ) -> OperationDetailData {
        return detail
    }
    
    private func templateWithGeneralParameter(
        payeeExternal: TransferGeneralData.PayeeExternal? = .stub,
        amount: Double? = 100.0
    ) -> PaymentTemplateData {
        
        guard let amount else {
            return templateWithParameterList(with: TransferGeneralData.generalStub(
                amount: nil
            ))
        }
        
        return templateWithParameterList(with: TransferGeneralData.generalStub(
            amount: Decimal(amount)
        ))
    }
    
    private func templateWithParameterList(
        with transferData: [TransferData] = TransferGeneralData.generalStub(amount: 10)
    ) -> PaymentTemplateData {
        
        .templateStub(
            paymentTemplateId: 1,
            type: .newDirect,
            parameterList: transferData
        )
    }
    
    private func directTemplate() -> PaymentTemplateData {
        
        .templateStub(
            paymentTemplateId: 1,
            type: .newDirect
        )
    }
    
    private func paymentOperationStub(
        service: Payments.Service,
        parameters: [PaymentsParameterRepresentable] = []
    ) -> Payments.Operation {
        
        return Payments.Operation(
            service: service,
            source: .template(1),
            steps: [.init(
                parameters: parameters,
                front: .empty(),
                back: .empty()
            )],
            visible: []
        )
    }
    
    private func makeSUT(
        model: Model = .mockWithEmptyExcept(),
        template: PaymentTemplateData = .templateStub(type: .betweenTheir),
        operation: Payments.Operation? = nil,
        meToMePayment: MeToMePayment? = nil,
        detail: OperationDetailData = .stub()
    ) -> State {
        
        model.paymentTemplates.value += [template]
        
        return .init(state: TemplateButton.templateButtonState(
            model: model,
            template: template,
            operation: operation,
            meToMePayment: meToMePayment,
            detail: detail
        ))
    }
    
    private enum State: Equatable {
        
        case idle
        case refresh
        case complete
        case loading
        
        init(state: TemplateButtonView.ViewModel.State) {
            switch state {
            case .idle:
                self = .idle
                
            case .refresh:
                self = .refresh
                
            case .complete:
                self = .complete
                
            case .loading:
                self = .loading
            }
        }
    }
}
