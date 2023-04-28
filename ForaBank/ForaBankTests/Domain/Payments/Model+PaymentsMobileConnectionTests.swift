//
//  Model+PaymentsMobileConnectionTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 20.02.2023.
//

@testable import ForaBank
import XCTest

final class Model_PaymentsMobileConnectionTests: XCTestCase {
    
    func test_init_mobileConnectionPaymentsService() throws {
        
        let mobileConnection = try XCTUnwrap(Payments.Service(rawValue: "mobileConnection"))
        
        XCTAssertEqual(mobileConnection, .mobileConnection)
    }
    
    func test_init_mobileConnectionPaymentsOperator() throws {
        
        let mobileConnection = try XCTUnwrap(Payments.Operator(rawValue: "mobileConnection"))
        
        XCTAssertEqual(mobileConnection, .mobileConnection)
    }
    
    func test_mobileConnection_isGeneralPaymentsCategory() {
        
        let category = Payments.Category.category(for: .mobileConnection)
        
        XCTAssertEqual(category, .general)
        XCTAssert(Payments.Category.general.services.contains(.mobileConnection))
    }
    
    func test_mobileConnection_shouldHavePaymentsOperators() {
        
        let service: Payments.Service = .mobileConnection
        
        XCTAssertEqual(service.operators, [.mobileConnection])
    }
    
    func test_mobileConnection_shouldHavePaymentsOperationTransferType() {
        
        let service: Payments.Service = .mobileConnection
        
        XCTAssertEqual(service.transferType, .mobileConnection)
    }
    
    func test_localStep_shouldThrowForUnknownStepIndex() async {
        
        for step in [-1, 1] {
            do {
                _ = try await makeLocalStep(stepIndex: step)
                XCTFail("Expected error for step \(step) but got value instead.")
            } catch {}
        }
    }
    
    // MARK: - Local Step 0
    
    func test_localStep0_shouldThrowOnEmptyProducts() async throws {
        
        do {
            let step = try await makeLocalStep(
                [],
                currencies: [.rub],
                stepIndex: 0
            )
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    func test_localStep0_shouldThrowOnEmptyCurrencies() async throws {
        
        do {
            let step = try await makeLocalStep(
                currencies: [],
                stepIndex: 0
            )
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    func test_localStep0_shouldSetFrontIsCompletedToFalse() async throws {
        
        let step = try await makeLocalStep(stepIndex: 0)
        
        XCTAssertEqual(step.front.isCompleted, false)
    }
    
    func test_localStep0_shouldSetBackStageToRemoteStart() async throws {
        
        let step = try await makeLocalStep(stepIndex: 0)
        
        XCTAssertEqual(step.back.stage, .remote(.start))
    }
    
    func test_localStep0_shouldSetBackProcessedToNil() async throws {
        
        let step = try await makeLocalStep(stepIndex: 0)
        
        XCTAssertNil(step.back.processed)
    }
    
    func test_localStep0_shouldSetParameters() async throws {
        
        let step = try await makeLocalStep(stepIndex: 0)
        let expectedIDs: [Payments.Parameter.Identifier] = [
            .operator,
            .header,
            .mobileConnectionPhone,
            .product,
            .amount
        ]
        
        XCTAssertEqual(step.parameters.map(\.id), expectedIDs.map(\.rawValue))
    }
    
    func test_localStep0_shouldSetFrontVisible() async throws {
        
        let step = try await makeLocalStep(stepIndex: 0)
        let expectedIDs: [Payments.Parameter.Identifier] = [
            .header,
            .mobileConnectionPhone,
            .product,
            .amount
        ]
        
        XCTAssertEqual(step.front.visible, expectedIDs.map(\.rawValue))
    }
    
    func test_localStep0_shouldSetBackRequired() async throws {
        
        let step = try await makeLocalStep(stepIndex: 0)
        let expectedIDs: [Payments.Parameter.Identifier] = [
            .mobileConnectionPhone,
            .product,
            .amount
        ]
        
        XCTAssertEqual(step.back.required, expectedIDs.map(\.rawValue))
    }
    
    func test_localStep0_shouldSetAmountParameterLast() async throws {
        
        let step = try await makeLocalStep(stepIndex: 0)
        let last = try XCTUnwrap(step.parameters.last)
        let amountParameter = try XCTUnwrap(last as? Payments.ParameterAmount)
        
        XCTAssertEqual(amountParameter.amount, 0)
        XCTAssertEqual(amountParameter.title, "Сумма перевода")
    }
    
    // MARK: - getPhoneInfo Helper
    
    func test_getPhoneInfo_shouldThrowOnMissingPhoneParameter() async throws {
        
        let parameters: [PaymentsParameterRepresentable] = [
            Payments.ParameterHeader(title: "")
        ]
        let token = UUID().uuidString
        
        do {
            _ = try await getPhoneInfo(parameters: parameters, token: token)
            XCTFail("Expected error, got result instead.")
        } catch {
            
            let id = Payments.Parameter.Identifier.mobileConnectionPhone
            XCTAssertEqual(
                error as NSError,
                Payments.Error.missingParameter(id.rawValue) as NSError
            )
        }
    }
    
    func test_getPhoneInfo_shouldThrowOnEmptyPhone() async throws {
        
        let parameters = [makePhoneParameter(value: nil)]
        let token = UUID().uuidString
        
        do {
            _ = try await getPhoneInfo(parameters: parameters, token: token)
            XCTFail("Expected error, got result instead.")
        } catch {

            let id = Payments.Parameter.Identifier.mobileConnectionPhone
            XCTAssertEqual(
                error as NSError,
                Payments.Error.missingParameter(id.rawValue) as NSError
            )
        }
    }
    
    func test_getPhoneInfo_shouldCreatePayloadWithPhoneNumber() async throws {

        let parameters = [makePhoneParameter()]
        let token = UUID().uuidString
        
        let command = try await getPhoneInfo(parameters: parameters, token: token)

        XCTAssertEqual(command.payload?.phoneNumbersList, ["1234567890"])
    }
    
    // MARK: - Helpers
    
    private func makeLocalStep(
        _ counts: ProductTypeCounts = [(.card, 1)],
        currencies: [CurrencyData] = [.rub],
        stepIndex: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Payments.Operation.Step {
        
        let sut: Model = .emptyMock
        sut.products.value = makeProductsData(counts)
        sut.currencyList.value = currencies

        let operation = Payments.Operation(service: .mobileConnection)
        
        return try await sut.paymentsProcessLocalStepMobileConnection(
            operation,
            for: stepIndex
        )
    }
    
    private func getPhoneInfo(
        parameters: [PaymentsParameterRepresentable],
        token: String
    ) async throws -> ServerCommands.DaDataController.GetPhoneInfo {
        
        let sut: Model = .emptyMock

        return try await sut.getPhoneInfo(
            token: token,
            parameters: parameters
        )
    }
    
    private func makePhoneParameter(
        value: String? = "+7123 456-78-90"
    ) -> Payments.ParameterInputPhone {
        let phoneParameterId = Payments.Parameter.Identifier.mobileConnectionPhone.rawValue
        
        return Payments.ParameterInputPhone(
            .init(id: phoneParameterId, value: value),
            title: "Номер телефона"
        )
    }
}
