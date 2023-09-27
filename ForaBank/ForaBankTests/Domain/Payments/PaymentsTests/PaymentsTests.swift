//
//  PaymentsTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 18.08.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsTests: XCTestCase {
    
    func test_paymentC2bComplete_card() async throws {
        
        let sut = makeSUT(serverStub: c2bPaymentCardStub())
        let operation = c2bOperationWithParameter(
            parameters: [c2bQrcIdMockParameter()]
        )
        
        let success = try await sut.paymentsC2BComplete(operation: operation)
        
        XCTAssert(success.hasDetailId)
    }
    
    func test_init_paymentSuccessViewModel_withSuccessOperationDetailID() async throws {
        
        let sut = makeSUT(serverStub: c2bPaymentCardStub())
        let operation = c2bOperationWithParameter(
            parameters: [c2bQrcIdMockParameter()]
        )
        
        let success = try await sut.paymentsC2BComplete(operation: operation)
        
        let viewModel = PaymentsSuccessViewModel(paymentSuccess: success, sut)
        
        XCTAssertNoDiff(viewModel.paymentOperationDetailID, 12345)
    }
    
    // MARK: paymentsStepC2B source C2B
    
    func test_paymentsStepC2B_shouldReturnParameters_amount_qrcId_onStepZero() async throws {
        
        let getScenarioData = getScenarioQRDataStub(
            parameters: anyParameterAmount()
        )
        
        let sut = makeSUT(serverStub: getScenarioData)
        let operation = c2bOperationWithParameter()
        
        // TODO: обновить тест с учетом HTTPClient
        /*let paymentsStepC2B = try await sut.paymentsStepC2B(operation, for: 0)
          
        XCTAssertNoDiff(paymentsStepC2B.parametersIds, [
            "ru.forabank.sense.amount",
            "qrcId"
        ])*/
    }
    
    func test_paymentsStepC2B_withAmountParameterNil_shouldReturnParameter_c2bIsAmountComplete() async throws {
        
        let getScenarioData = getScenarioQRDataStub(
            parameters: anyParameterAmount(amount: nil)
        )
        
        let sut = makeSUT(serverStub: getScenarioData)
        let operation = c2bOperationWithParameter()
        
        // TODO: обновить тест с учетом HTTPClient
        /*let paymentsStepC2B = try await sut.paymentsStepC2B(operation, for: 0)
       
        XCTAssertNoDiff(paymentsStepC2B.parametersIds, [
            "ru.forabank.sense.amount",
            "qrcId",
            "c2bIsAmountComplete"
        ])*/
    }
    
    // MARK: - Helpers
    
    private func c2bQrcIdMockParameter() -> Payments.ParameterMock {
    
        Payments.ParameterMock(
            id: Payments.Parameter.Identifier.c2bQrcId.rawValue,
            value: "qrcId"
        )
    }
    
    private func anyParameterAmount(
        amount: Decimal? = Decimal(10)
    ) -> [AnyPaymentParameter] {
        
        [ .init(PaymentParameterAmount(
            id: Payments.Parameter.Identifier.amount.rawValue,
            value: amount,
            title: "title"
        ))
        ]
    }
    
    private func c2bPaymentCardStub() -> [ServerAgentTestStub.Stub] {
        
        [.c2bPaymentCard(.success(.init(
            statusCode: .ok,
            errorMessage: nil,
            data: .init(parameters: [
                .init(PaymentParameterInfo(
                    id: Payments.Parameter.Identifier.successOperationDetailID.rawValue,
                    value: "12345",
                    title: "",
                    icon: .init(type: .local, value: "")
                ))
            ]))))]
    }
    
    private func getScenarioQRDataStub(
        parameters: [AnyPaymentParameter]
    ) -> [ServerAgentTestStub.Stub] {
        
        [.getScenarioQRData(.success(.init(
            statusCode: .ok,
            errorMessage: nil,
            data: .init(
                qrcId: "qrcId",
                parameters: parameters,
                required: []
            )
        )))]
    }
    
    private func makeSUT(
        serverStub: [ServerAgentTestStub.Stub],
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sessionAgent = ActiveSessionAgentStub()
        let serverAgent = ServerAgentTestStub(serverStub)
        
        let sut: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent
        )
        
        sut.products.value = [.card : [.cardStub()]]
        
        // TODO: restore memory leak tracking after Model fix
        //        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

// MARK: - DSL

private extension Payments.Success {
    
    var hasDetailId: Bool {
        
        parameters.hasValue(forIdentifier: .successOperationDetailID)
    }
}
