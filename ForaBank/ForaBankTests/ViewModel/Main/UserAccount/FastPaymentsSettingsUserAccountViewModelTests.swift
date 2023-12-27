//
//  FastPaymentsSettingsUserAccountViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
@testable import ForaBank
import XCTest

final class FastPaymentsSettingsUserAccountViewModelTests: XCTestCase {
    
    func test_init_shouldSetFPSCFLResponseToNil() {
        
        let (_,_, responseSpy, _) = makeSUT()
        
        XCTAssertNoDiff(responseSpy.values, [nil])
    }
    
    func test_init_shouldCallGetFastPaymentContractFindList() {
        
        let (_, findListSpy, _,_) = makeSUT()
        
        XCTAssertNoDiff(findListSpy.callCount, 1)
    }
    
    func test_shouldSetFPSCFLResponse() {
        
        let (_, findListSpy, responseSpy, _) = makeSUT()
        
        findListSpy.emitAndWait(.active("abcd123"))
        
        XCTAssertNoDiff(responseSpy.values, [
            nil,
            .active("abcd123"),
        ])
        
        findListSpy.emitAndWait(.inactive("321dcba"))
        
        XCTAssertNoDiff(responseSpy.values, [
            nil,
            .active("abcd123"),
            .inactive("321dcba"),
        ])
        
        findListSpy.emitAndWait(.missing)
        
        XCTAssertNoDiff(responseSpy.values, [
            nil,
            .active("abcd123"),
            .inactive("321dcba"),
            .missing,
        ])
        
        findListSpy.emitAndWait(.fixedError)
        
        XCTAssertNoDiff(responseSpy.values, [
            nil,
            .active("abcd123"),
            .inactive("321dcba"),
            .missing,
            .fixedError,
        ])
    }
    
    func test_init_shouldNotCallGetDefaultAndConsent() throws {
        
        let (_, _,_, getDefaultAndConsentSpy) = makeSUT()
        
        XCTAssertNoDiff(getDefaultAndConsentSpy.messages.count, 0)
    }
    
    func test_tapFastPaymentsSettings_shouldCallGetDefaultAndConsentOnActiveFPSCFLResponse() throws {
        
        let phone = "abc123"
        let (sut, findListSpy, _, getDefaultAndConsentSpy) = makeSUT()
        findListSpy.emitAndWait(.active(.init(phone)))
        
        try sut.tapFastPaymentsSettingsAndWait()
        
        XCTAssertNoDiff(getDefaultAndConsentSpy.messages.map(\.payload), [.init(phone)])
    }
    
    func test_tapFastPaymentsSettings_shouldCallGetDefaultAndConsentOnInactiveFPSCFLResponse() throws {
        
        let phone = "abc123"
        let (sut, findListSpy, _, getDefaultAndConsentSpy) = makeSUT()
        findListSpy.emitAndWait(.inactive(.init(phone)))
        
        try sut.tapFastPaymentsSettingsAndWait()
        
        XCTAssertNoDiff(getDefaultAndConsentSpy.messages.map(\.payload), [.init(phone)])
    }
    
    func test_tapFastPaymentsSettings_shouldNotCallGetDefaultAndConsentOnMissingFPSCFLResponse() throws {
        
        let (sut, findListSpy, _, getDefaultAndConsentSpy) = makeSUT()
        findListSpy.emitAndWait(.missing)
        
        try sut.tapFastPaymentsSettingsAndWait()
        
        XCTAssertNoDiff(getDefaultAndConsentSpy.messages.count, 0)
    }
    
    func test_tapFastPaymentsSettings_shouldNotCallGetDefaultAndConsentOnErrorFPSCFLResponse() throws {
        
        let (sut, findListSpy, _, getDefaultAndConsentSpy) = makeSUT()
        findListSpy.emitAndWait(.fixedError)
        XCTAssertNoDiff(getDefaultAndConsentSpy.messages.count, 0)
        
        try sut.tapFastPaymentsSettingsAndWait()
        
        XCTAssertNoDiff(getDefaultAndConsentSpy.messages.count, 0)
    }
        
    func test_init_shouldNotSetDestination() throws {
        
        let (sut, _,_,_) = makeSUT()
        let destinationSpy = ValueSpy(sut.$link)

        XCTAssertNoDiff(destinationSpy.values, [nil])
    }
    
    func test_tapFastPaymentsSettings_shouldSetAlertWithDissmissAlertPrimaryButtonOnActiveFPSCFLResponseGetDefaultAndConsentFailure() throws {
        
        let (sut, findListSpy, _, getDefaultAndConsentSpy) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        findListSpy.emitAndWait(anyActive())
        
        try sut.tapFastPaymentsSettingsAndWait()
        getDefaultAndConsentSpy.completeAndWait(with: .failure(anyError()))
        
        try sut.tapPrimaryAlertButtonAndWait()
        
        XCTAssertNoDiff(alertSpy.values.map(\.?.message), [
            nil,
            "Превышено время ожидания.\nПопробуйте позже.",
            nil
        ])
    }
    
    func test_tapFastPaymentsSettings_shouldSetDestinationOnActiveFPSCFLResponseGetDefaultAndConsentSuccess() throws {
        
        let (sut, findListSpy, _, getDefaultAndConsentSpy) = makeSUT()
        let destinationSpy = ValueSpy(sut.$link)
        findListSpy.emitAndWait(anyActive())
        
        try sut.tapFastPaymentsSettingsAndWait()
        getDefaultAndConsentSpy.completeAndWait(with: .success(true))
        
        XCTAssertNoDiff(destinationSpy.values.map(\.?.id), [
            nil,
            .fastPaymentSettings
        ])
    }
    
    func test_tapFastPaymentsSettings_shouldSetAlertWithDissmissAlertPrimaryButtonOnInactiveFPSCFLResponseGetDefaultAndConsentFailure() throws {
        
        let (sut, findListSpy, _, getDefaultAndConsentSpy) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        findListSpy.emitAndWait(anyInactive())
        
        try sut.tapFastPaymentsSettingsAndWait()
        getDefaultAndConsentSpy.completeAndWait(with: .failure(anyError()))
        
        try sut.tapPrimaryAlertButtonAndWait()
        
        XCTAssertNoDiff(alertSpy.values.map(\.?.message), [
            nil,
            "Превышено время ожидания.\nПопробуйте позже.",
            nil
        ])
    }
    
    func test_tapFastPaymentsSettings_shouldSetDestinationOnInactiveFPSCFLResponseGetDefaultAndConsentSuccess() throws {
        
        let (sut, findListSpy, _, getDefaultAndConsentSpy) = makeSUT()
        let destinationSpy = ValueSpy(sut.$link)
        findListSpy.emitAndWait(anyInactive())
        
        try sut.tapFastPaymentsSettingsAndWait()
        getDefaultAndConsentSpy.completeAndWait(with: .success(true))
        
        XCTAssertNoDiff(destinationSpy.values.map(\.?.id), [
            nil,
            .fastPaymentSettings
        ])
    }
    
    func test_tapFastPaymentsSettings_shouldSetDestinationOnMissingFPSCFLResponse() throws {
        
        let (sut, findListSpy, _,_) = makeSUT()
        let destinationSpy = ValueSpy(sut.$link)
        findListSpy.emitAndWait(.missing)
        
        #warning("long timeout")
        try sut.tapFastPaymentsSettingsAndWait(timeout: 3)
        
        XCTAssertNoDiff(destinationSpy.values.map(\.?.id), [
            nil,
            .fastPaymentSettings
        ])
    }
    
    func test_init_shouldNotSetAlert() throws {
        
        let (sut, _,_,_) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        
        XCTAssertNoDiff(alertSpy.values, [nil])
    }
    
    func test_tapFastPaymentsSettings_shouldSetAlertWithDissmissAlertPrimaryButtonOnErrorFPSCFLResponse() throws {
        
        let (sut, findListSpy, _, _) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        findListSpy.emitAndWait(.fixedError)
        
        try sut.tapFastPaymentsSettingsAndWait()
        try sut.tapPrimaryAlertButtonAndWait()
        
        XCTAssertNoDiff(alertSpy.values.map(\.?.message), [
            nil,
            "Превышено время ожидания.\nПопробуйте позже.",
            nil
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UserAccountViewModel
    private typealias FPSCFLResponse = FastPaymentsServices.FPSCFLResponse
    private typealias FindListSpy = GetSpy<FPSCFLResponse>
    private typealias ResponseSpy = ValueSpy<FPSCFLResponse?>
    private typealias GetDefaultAndConsentSpy = Spy<FastPaymentsServices.Phone, FastPaymentsServices.DefaultForaBank, Error>
    
    private func makeSUT(
        clientInfo: ClientInfoData = .stub(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        findListSpy: FindListSpy,
        responseSpy: ResponseSpy,
        getDefaultAndConsentSpy: GetDefaultAndConsentSpy
    ) {
        let sessionAgent = ActiveSessionAgentStub()
        let model: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent
        )
        model.clientInfo.value = clientInfo
        
        let findListSpy = FindListSpy()
        let getDefaultAndConsentSpy = GetDefaultAndConsentSpy()
        let sut = SUT(
            model: model,
            fastPaymentsFactory: .default,
            fastPaymentsServices: .init(
                getFastPaymentContractFindList: findListSpy.get,
                getDefaultAndConsent: getDefaultAndConsentSpy.process(_:completion:)
            ),
            clientInfo: .stub(),
            dismissAction: {}
        )
        let responseSpy = ValueSpy(sut.$fpsCFLResponse)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(findListSpy, file: file, line: line)
        trackForMemoryLeaks(responseSpy, file: file, line: line)
        trackForMemoryLeaks(getDefaultAndConsentSpy, file: file, line: line)
        
        return (sut, findListSpy, responseSpy, getDefaultAndConsentSpy)
    }
    
    private final class GetSpy<Value> {
        
        private(set) var callCount = 0
        private let subject = PassthroughSubject<Value, Never>()
        
        func get() -> AnyPublisher<Value, Never> {
            
            callCount += 1
            return subject.eraseToAnyPublisher()
        }
        
        func emitAndWait(_ value: Value) {
            
            subject.send(value)
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        }
    }
}

private func anyActive(
    _ value: String = UUID().uuidString
) -> FastPaymentsServices.FPSCFLResponse {
    
    .active(.init(value))
}

private func anyInactive(
    _ value: String = UUID().uuidString
) -> FastPaymentsServices.FPSCFLResponse {
    
    .inactive(.init(value))
}

private extension ClientInfoData {
    
    static func stub(
        id: Int = 98765,
        lastName: String = "LastName",
        firstName: String = "FirstName",
        patronymic: String? = "MiddleName",
        birthDay: String? = nil,
        regSeries: String? = nil,
        regNumber: String = "abcdef",
        birthPlace: String? = nil,
        dateOfIssue: String? = nil,
        codeDepartment: String? = nil,
        regDepartment: String? = nil,
        address: String = "Address",
        addressInfo: ClientInfoData.AddressInfo? = nil,
        addressResidential: String? = nil,
        addressResidentialInfo: ClientInfoData.AddressInfo? = nil,
        phone: String = "phone",
        phoneSMS: String? = nil,
        email: String? = nil,
        inn: String? = nil,
        customName: String? = nil
    ) -> Self {
        
        .init(
            id: id,
            lastName: lastName,
            firstName: firstName,
            patronymic: patronymic,
            birthDay: birthDay,
            regSeries: regSeries,
            regNumber: regNumber,
            birthPlace: birthPlace,
            dateOfIssue: dateOfIssue,
            codeDepartment: codeDepartment,
            regDepartment: regDepartment,
            address: address,
            addressInfo: addressInfo,
            addressResidential: addressResidential,
            addressResidentialInfo: addressResidentialInfo,
            phone: phone,
            phoneSMS: phoneSMS,
            email: email,
            inn: inn,
            customName: customName
        )
    }
}

// MARK: - DSL

private extension UserAccountViewModel {
    
    func tapPrimaryAlertButtonAndWait(
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let button = try XCTUnwrap(
            alert?.primary,
            "\nExpected to have Primary Alert Button but got nil instead.",
            file: file, line: line
        )
        button.action()
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func tapFastPaymentsSettingsAndWait(
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let button = try XCTUnwrap(
            fastPaymentSettingButton,
            "\nExpected to have Fast Payments Settings Button but got nil instead.",
            file: file, line: line
        )
        button.action()
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    var fastPaymentSettingButton: AccountCellButtonView.ButtonView.ViewModel? {
        
        let viewModel = sections
            .compactMap { $0 as? UserAccountPaymentsView.ViewModel }
            .flatMap(\.items)
            .compactMap { $0 as? AccountCellButtonView.ViewModel }
            .first { $0.content == "Система быстрых платежей" }
        
        return viewModel?.button
    }
    
    var fastPaymentsSettings: MeToMeSettingView.ViewModel? {
        
        guard case let .fastPaymentSettings(fastPaymentsSettings) = link
        else { return nil }
        
        return fastPaymentsSettings
    }
}

extension Spy {
    
    func completeAndWait(
        with result: Result,
        at index: Int = 0,
        timeout: TimeInterval = 0.05
    ) {
        complete(with: result, at: index)
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}
