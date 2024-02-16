//
//  Model+AntifraudDataTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 14.11.2023.
//

@testable import ForaBank
import XCTest

final class Model_AntifraudDataTests: XCTestCase {
    
    // MARK: - paymentsAntifraudData
    
    func test_paymentsAntifraudData_serviceNotSfp_shouldReturnNil() {
        
        let operation: Payments.Operation = .init(service: .avtodor)
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudNil_shouldReturnNil() {
        
        let operation: Payments.Operation = .init(service: .sfp)
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueG_shouldReturnNil() {
        
        let operation = operation(parameters: [paramSfpAntifraudG])
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueNotGWithoutAmount_shouldReturnNil() {
        
        let operation = operation(parameters: [paramSfpAntifraud, paramPhone, paramRecipient])
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueNotGWithoutPhone_shouldReturnNil() {
        
        let operation = operation(parameters: [paramSfpAntifraud, paramAmount, paramPhone])
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueNotGWithoutRecipient_shouldReturnNil() {
        
        let operation = operation(parameters: [paramSfpAntifraud, paramAmount, paramRecipient])
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueNotGWithAllParameters_shouldReturnData() {
        
        let operation = operation(parameters: [
            paramSfpAntifraud,
            paramAmount,
            paramPhone,
            paramRecipient
        ])
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        let antifraudData: Payments.AntifraudData? = .init(
            payeeName: "Иванов",
            phone: "+7 963 000-00-00",
            amount: "- 1231"
        )
        
        try XCTAssertNoDiff(XCTUnwrap(result?.equatable), antifraudData?.equatable)
    }
    
    func test_paymentAntifraudData_serviceRequisites_shouldReturnAntifraudData() {
        
        let operation = operation(
            service: .requisites,
            parameters: [
                paramAntifraudSuspect,
                paramRequisitesAmount,
                paramRequisitesName,
            ]
        )
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        let antifraudData: Payments.AntifraudData? = .init(
            payeeName: "Иван",
            phone: "",
            amount: "- 1234"
        )
        
        try XCTAssertNoDiff(XCTUnwrap(result?.equatable), antifraudData?.equatable)
    }
    
    func test_paymentAntifraudData_serviceRequisites_withCompany_shouldReturnAntifraudData() {
        
        let operation = operation(
            service: .requisites,
            parameters: [
                paramAntifraudSuspect,
                paramRequisitesAmount,
                paramRequisitesCompany,
            ]
        )
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        let antifraudData: Payments.AntifraudData? = .init(
            payeeName: "ООО Ромашка",
            phone: "",
            amount: "- 1234"
        )
        
        try XCTAssertNoDiff(XCTUnwrap(result?.equatable), antifraudData?.equatable)
    }
    
    
    //MARK: Abroad
    func test_paymentAntifraudData_serviceAbroad_shouldReturnAntifraudData() {
        
        let operation = operation(
            service: .abroad,
            parameters: [
                paramAntifraudSuspect,
                countryPayee,
                amount,
                p1,
                countryCurrencyAmount
            ]
        )
        let sut: Model = .mockWithEmptyExcept()
        sut.currencyList.value = [.rub]
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        let antifraudData: Payments.AntifraudData? = .init(
            payeeName: "p1",
            phone: "",
            amount: "- 1234"
        )
        
        try XCTAssertNoDiff(XCTUnwrap(result?.equatable), antifraudData?.equatable)
    }
    
    //MARK: Mobile
    func test_paymentAntifraudData_serviceMobile_shouldReturnAntifraudData() {
        
        let operation = operation(
            service: .mobileConnection,
            parameters: [
                paramAntifraudSuspect,
                mobileConnectionPhone,
                mobileConnectionAmount
            ]
        )
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        let antifraudData: Payments.AntifraudData? = .init(
            payeeName: "",
            phone: "+7 925 279-81-22",
            amount: "- 1234"
        )
        
        try XCTAssertNoDiff(XCTUnwrap(result?.equatable), antifraudData?.equatable)
    }
    
    //MARK: Utility
    func test_paymentAntifraudData_serviceUtility_shouldReturnAntifraudData() {
        
        let operation = operation(
            service: .utility,
            parameters: [
                paramAntifraudSuspect,
                header,
                amount
            ]
        )
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        let antifraudData: Payments.AntifraudData? = .init(
            payeeName: "Header",
            phone: "",
            amount: "- 1234 ₽"
        )
        
        try XCTAssertNoDiff(XCTUnwrap(result?.equatable), antifraudData?.equatable)
    }
    
    //MARK: To Another Card
    func test_paymentAntifraudData_serviceAnotherCard_shouldReturnAntifraudData() {
        
        let operation = operation(
            service: .toAnotherCard,
            parameters: [
                paramAntifraudSuspect,
                productTemplate,
                amount
            ]
        )
        let sut: Model = .mockWithEmptyExcept()
        sut.currencyList.value = [.rub]
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        let antifraudData: Payments.AntifraudData? = .init(
            payeeName: "34 **** **** 34",
            phone: "",
            amount: "- 1234"
        )
        
        try XCTAssertNoDiff(XCTUnwrap(result?.equatable), antifraudData?.equatable)
    }
    
    // MARK: - Helpers
    
    let paramAntifraudSuspect = Payments.ParameterMock(
        id: .sfpAntifraudId,
        value: "SUSPECT"
    )
    
    let paramSfpAntifraud = Payments.ParameterMock(
        id: .sfpAntifraudId,
        value: "G1"
    )
    
    let paramSfpAntifraudG = Payments.ParameterMock(
        id: .sfpAntifraudId,
        value: "G"
    )
    
    let paramAmount = Payments.ParameterMock(
        id: .amountParameterId,
        value: "1231"
    )
    
    let paramPhone = Payments.ParameterMock(
        id: .phoneParameterId,
        value: "79630000000"
    )
    
    let paramRecipient = Payments.ParameterMock(
        id: .recipientParameterId,
        value: "Иванов"
    )   
    
    let paramRequisitesName = Payments.ParameterMock(
        id: .requisitesName,
        value: "Иван"
    )  
    
    let paramRequisitesCompany = Payments.ParameterMock(
        id: .requisitesCompanyName,
        value: "ООО Ромашка"
    )    
    
    let paramRequisitesAmount = Payments.ParameterMock(
        id: .requisitesAmount,
        value: "1234"
    )
    
    let countryPayee = Payments.ParameterMock(
        id: .countryPayee,
        value: "countryPayee"
    )
    
    let amount = Payments.ParameterMock(
        id: .amount,
        value: "1234"
    )
    
    let p1 = Payments.ParameterMock(
        id: .p1,
        value: "p1"
    )
    
    let countryCurrencyAmount = Payments.ParameterMock(
        id: .countryCurrencyAmount,
        value: "RUB"
    )
    
    let mobileConnectionPhone = Payments.ParameterMock(
        id: .mobileConnectionPhone,
        value: "79252798122"
    )
    
    let mobileConnectionAmount = Payments.ParameterMock(
        id: .mobileConnectionAmount,
        value: "1234"
    )
    
    let productTemplate = Payments.ParameterMock(
        id: .productTemplate,
        value: "1234"
    )
    
    let header = Payments.ParameterHeader(title: "Header")
    
    func operation(
        service: Payments.Service = .sfp,
        parameters: [any PaymentsParameterRepresentable]
    ) -> Payments.Operation {
        
        let stepOne = Payments.Operation.Step(
            parameters: parameters,
            front: .empty(),
            back: .empty())
        
        return .init(
            service: service,
            source: nil,
            steps: [stepOne],
            visible: [])
    }
}

private extension String {
    
    static let amountParameterId: Self = Payments.Parameter.Identifier.sfpAmount.rawValue
    static let phoneParameterId: Self = Payments.Parameter.Identifier.sfpPhone.rawValue
    static let recipientParameterId: Self = Payments.Parameter.Identifier.sftRecipient.rawValue
    static let sfpAntifraudId: Self = Payments.Parameter.Identifier.sfpAntifraud.rawValue
    static let requisitesName: Self = Payments.Parameter.Identifier.requisitsName.rawValue
    static let requisitesCompanyName: Self = Payments.Parameter.Identifier.requisitsCompanyName.rawValue
    static let requisitesAmount: Self = Payments.Parameter.Identifier.requisitsAmount.rawValue
    static let countryPayee: Self = Payments.Parameter.Identifier.countryPayee.rawValue
    static let amount: Self = Payments.Parameter.Identifier.amount.rawValue
    static let p1: Self = Payments.Parameter.Identifier.p1.rawValue
    static let countryCurrencyAmount: Self = Payments.Parameter.Identifier.countryCurrencyAmount.rawValue
    static let mobileConnectionAmount: Self = Payments.Parameter.Identifier.mobileConnectionAmount.rawValue
    static let mobileConnectionPhone: Self = Payments.Parameter.Identifier.mobileConnectionPhone.rawValue
    static let productTemplate: Self = Payments.Parameter.Identifier.productTemplate.rawValue
    static let header: Self = Payments.Parameter.Identifier.header.rawValue
}

private extension Payments.AntifraudData {
    
    struct EquatableAntifraudData: Equatable {
        
        let payeeName: String
        let phone: String
        let amount: String
    }

    var equatable: EquatableAntifraudData {
        .init(
            payeeName: self.payeeName,
            phone: self.phone,
            amount: self.amount)
    }
}
