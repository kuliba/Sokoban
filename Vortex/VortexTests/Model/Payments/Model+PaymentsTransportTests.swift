//
//  Model+PaymentsTransportTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.06.2023.
//

@testable import ForaBank
import XCTest

final class Model_PaymentsTransportTests: XCTestCase {
    
    func test_paymentsService_shouldThrowOnEmptyTemplatesList() throws {
        
        let model: Model = .mockWithEmptyExcept()
        let paymentTemplateId = 54321
        let source: Payments.Operation.Source = .template(paymentTemplateId)
        
        XCTAssertThrowsError(
            _ = try model.paymentsService(for: source)
        )
        XCTAssertEqual(model.paymentTemplates.value, [])
    }
    
    func test_paymentsService_shouldReturnTransport_forTransportTemplate() throws {
        
        let model: Model = .mockWithEmptyExcept()
        let paymentTemplateId = 54321
        model.stubPaymentTemplates(
            paymentTemplateId: paymentTemplateId,
            for: .transport
        )
        let source: Payments.Operation.Source = .template(paymentTemplateId)
        
        let service = try model.paymentsService(for: source)
        
        XCTAssertEqual(service, .transport)
        XCTAssertEqual(
            model.paymentTemplates.value.map(\.type),
            [.transport]
        )
    }
    
    func test_paymentsService_shouldThrowOnEmptyLatestPayments() throws {
        
        let model: Model = .mockWithEmptyExcept()
        let source: Payments.Operation.Source = .latestPayment(0)
        
        XCTAssertThrowsError(
            _ = try model.paymentsService(for: source)
        )
        XCTAssertTrue(model.latestPayments.value.isEmpty)
    }
    
    func test_paymentsService_shouldReturnTransport_forTransportLatestPayments() throws {
        
        let model: Model = .mockWithEmptyExcept()
        let latestPaymentID = model.stubLatestPayments(
            for: .transport
        )
        let source: Payments.Operation.Source = .latestPayment(latestPaymentID)
        
        let service = try model.paymentsService(for: source)
        
        XCTAssertEqual(service, .transport)
        XCTAssertEqual(
            model.latestPayments.value.map(\.type),
            [.transport]
        )
    }
    
    /// Prove that transport is processed like `utility` and `internet` using `paymentsProcessLocalStepServices`
    /// - Note: this test is testing implementation details - this is known and intentional until there is a modular and testable components.
    func test_paymentsPaymentsProcessLocalStep_transport_shouldProcessAs_paymentsProcessLocalStepServices() async throws {
        
        let model: Model = .mockWithEmptyExcept()
        let operation: Payments.Operation = .init(service: .transport)
        
        do {
            _ = try await model.paymentsProcessLocalStep(operation: operation, stepIndex: 0)
            XCTFail("Expected `missingSource` error")
        } catch Payments.Error.missingSource(.transport) {}
    }
    
    /// Prove that transport is processed like `utility` and `internet` using `paymentsProcessLocalStepServices`
    /// - Note: this test is testing implementation details - this is known and intentional until there is a modular and testable components.
    func test_paymentsProcessLocalStep_transport_shouldProcessAs_paymentsProcessLocalStepServices() async throws {
        
        let model: Model = .mockWithEmptyExcept()
        let operation: Payments.Operation = .init(service: .transport)
        
        do {
            _ = try await model.paymentsProcessLocalStep(operation: operation, stepIndex: 0)
            XCTFail("Expected `missingSource` error")
        } catch Payments.Error.missingSource(.transport) {}
    }
    
    /// Prove that transport is processed like `utility` and `internet` using `paymentsProcessLocalStepServices`
    /// - Note: this test is testing implementation details - this is known and intentional until there is a modular and testable components.
    func test_paymentsProcessRemoteStep_transport_shouldProcessAs_paymentsTransferPaymentsServicesStepParameters() async throws {
        
        let model: Model = .mockWithEmptyExcept()
        let operation: Payments.Operation = .init(service: .transport)
        
        let step = try await model.paymentsProcessRemoteStep(operation: operation, response: TransferAnywayResponseData.makeDummy(finalStep: false))

        XCTAssertEqual(step.parametersIds, [])
    }
    
    /// Prove that transport is processed like `utility` and `internet` using `paymentsTransferPaymentsServicesProcess`
    /// - Note: this test is testing implementation details - this is known and intentional until there is a modular and testable components.
    func test_paymentsProcessRemoteNext_transport_shouldProcessAs_paymentsTransferPaymentsServicesProcess() async throws {
        
        let model: Model = .mockWithEmptyExcept()
        let operation: Payments.Operation = .init(service: .transport)
        
        do {
            _ = try await model.paymentsProcessRemoteNext([], operation)
            XCTFail("Expected `notAuthorized` error")
        } catch Payments.Error.notAuthorized {}
    }
    
    /// Prove that transport is processed like `utility` and `internet` using `paymentsProcessRemoteServicesComplete`
    /// - Note: this test is testing implementation details - this is known and intentional until there is a modular and testable components.
    func test_paymentsProcessRemoteConfirm_transport_shouldProcessAs_paymentsProcessRemoteServicesComplete() async throws {
        
        let model: Model = .mockWithEmptyExcept()
        let operation: Payments.Operation = .emptyWithParameterCode()
        
        do {
            _ = try await model.paymentsProcessRemoteConfirm([], operation)
            XCTFail("Expected `notAuthorized` error")
        } catch Payments.Error.notAuthorized {}
    }
    
    /// Prove that transport is processed like `utility` and `internet`.
    /// - Note: this test is testing implementation details - this is known and intentional until there is a modular and testable components.
    func test_paymentsProcessSourceReducer_transport_shouldProcess_template()  {
        
        let model: Model = .mockWithEmptyExcept()
        let paymentTemplateId = 54321
        model.stubPaymentTemplates(
            paymentTemplateId: paymentTemplateId,
            for: .transport
        )
        let source: Payments.Operation.Source = .template(paymentTemplateId)

        let value = model.paymentsProcessSourceReducer(service: .transport, source: source, parameterId: "??")
        
        XCTAssertEqual(value, nil)
    }
}

// MARK: - Helpers

extension Payments.Operation {
    
    static func emptyWithParameterCode() -> Self {
        
        let parameterCode: Payments.ParameterCode = .dummy()
        let step: Payments.Operation.Step = .init(
            parameters: [parameterCode],
            front: .empty(),
            back: .empty()
        )
        let steps: [Payments.Operation.Step] = [step]
        let operation: Payments.Operation = .init(
            service: .transport,
            source: nil,
            steps: steps ,
            visible: []
        )
        
        return operation
    }
}

extension Payments.Operation.Step.Front {
    
    static func empty(
        isCompleted: Bool = true
    ) -> Self {
        
        .init(visible: [], isCompleted: isCompleted)
    }
}

extension Payments.Operation.Step.Back {
    
    static func empty(
        stage: Payments.Operation.Stage = .local,
        required: [Payments.Parameter.ID] = [],
        processed: [Payments.Parameter]? = nil
    ) -> Self {
        
        .init(stage: stage, required: required, processed: processed)
    }
}

extension Model {
    
    func stubLatestPayments(
        date: Date = .distantPast,
        paymentDate: String = "0203",
        for type: LatestPaymentData.Kind
    ) -> LatestPaymentData.ID {
        
        let latestPayment = LatestPaymentData(
            date: date,
            paymentDate: paymentDate,
            type: type
        )
        
        latestPayments.value = [latestPayment]
        
        return latestPayment.id
    }
}

extension Payments.ParameterCode {
    
    static func dummy(
        value: Payments.Parameter.Value = "123456",
        icon: ImageData = .empty,
        title: String = "any title",
        timerDelay: TimeInterval = 1,
        errorMessage: String = "any error",
        validator: Validator = .init(length: 6)
    ) -> Self {
        
        
        self.init(
            value: value,
            icon: icon,
            title: title,
            timerDelay: timerDelay,
            errorMessage: errorMessage,
            validator: validator
        )
    }
}

extension TransferAnywayResponseData {
    
    static func makeDummy(
        amount: Double? = nil,
        creditAmount: Double? = nil,
        currencyAmount: Currency? = nil,
        currencyPayee: Currency? = nil,
        currencyPayer: Currency? = nil,
        currencyRate: Double? = nil,
        debitAmount: Double? = nil,
        fee: Double? = nil,
        needMake: Bool? = nil,
        needOTP: Bool? = nil,
        payeeName: String? = nil,
        documentStatus: TransferResponseBaseData.DocumentStatus? = nil,
        paymentOperationDetailId: Int = 1,
        additionalList: [TransferAnywayResponseData.AdditionalData] = [],
        finalStep: Bool,
        infoMessage: String? = nil,
        needSum: Bool = false,
        printFormType: String? = nil,
        parameterListForNextStep: [ParameterData] = []
    ) -> TransferAnywayResponseData {
        
        TransferAnywayResponseData(
            amount: amount,
            creditAmount: creditAmount,
            currencyAmount: currencyAmount,
            currencyPayee: currencyPayee,
            currencyPayer: currencyPayer,
            currencyRate: currencyRate,
            debitAmount: debitAmount,
            fee: fee,
            needMake: needMake,
            needOTP: needOTP,
            payeeName: payeeName,
            documentStatus: documentStatus,
            paymentOperationDetailId: paymentOperationDetailId,
            additionalList: additionalList,
            finalStep: finalStep,
            infoMessage: infoMessage,
            needSum: needSum,
            printFormType: printFormType,
            parameterListForNextStep: parameterListForNextStep,
            scenario: .ok
        )
    }
}

extension TransferResponseData {
    
    static func makeDummyTransferAnywayResponseData(
        amount: Double? = nil,
        creditAmount: Double? = nil,
        currencyAmount: Currency? = nil,
        currencyPayee: Currency? = nil,
        currencyPayer: Currency? = nil,
        currencyRate: Double? = nil,
        debitAmount: Double? = nil,
        fee: Double? = nil,
        needMake: Bool? = nil,
        needOTP: Bool? = nil,
        payeeName: String? = nil,
        documentStatus: TransferResponseBaseData.DocumentStatus? = nil,
        paymentOperationDetailId: Int = 1,
        additionalList: [TransferAnywayResponseData.AdditionalData] = [],
        finalStep: Bool,
        infoMessage: String? = nil,
        needSum: Bool = true,
        printFormType: String? = nil,
        parameterListForNextStep: [ParameterData] = []
    ) -> TransferAnywayResponseData {
        
        TransferAnywayResponseData.makeDummy(
            amount: amount,
            creditAmount: creditAmount,
            currencyAmount: currencyAmount,
            currencyPayee: currencyPayee,
            currencyPayer: currencyPayer,
            currencyRate: currencyRate,
            debitAmount: debitAmount,
            fee: fee,
            needMake: needMake,
            needOTP: needOTP,
            payeeName: payeeName,
            documentStatus: documentStatus,
            paymentOperationDetailId: paymentOperationDetailId,
            additionalList: additionalList,
            finalStep: finalStep,
            infoMessage: infoMessage,
            needSum: needSum,
            printFormType: printFormType,
            parameterListForNextStep: parameterListForNextStep
        )
    }
    
    static func makeDummy(
        amount: Double? = nil,
        creditAmount: Double? = nil,
        currencyAmount: Currency? = nil,
        currencyPayee: Currency? = nil,
        currencyPayer: Currency? = nil,
        currencyRate: Double? = nil,
        debitAmount: Double? = nil,
        fee: Double? = nil,
        needMake: Bool? = nil,
        needOTP: Bool? = nil,
        payeeName: String? = nil,
        documentStatus: TransferResponseBaseData.DocumentStatus? = nil,
        paymentOperationDetailId: Int = 1,
        scenario: AntiFraudScenario = .ok
    ) -> TransferResponseData {
        
        TransferResponseData(
            amount: amount,
            creditAmount: creditAmount,
            currencyAmount: currencyAmount,
            currencyPayee: currencyPayee,
            currencyPayer: currencyPayer,
            currencyRate: currencyRate,
            debitAmount: debitAmount,
            fee: fee,
            needMake: needMake,
            needOTP: needOTP,
            payeeName: payeeName,
            documentStatus: documentStatus,
            paymentOperationDetailId: paymentOperationDetailId,
            scenario: scenario
        )
    }
}
