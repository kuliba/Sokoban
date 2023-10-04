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
