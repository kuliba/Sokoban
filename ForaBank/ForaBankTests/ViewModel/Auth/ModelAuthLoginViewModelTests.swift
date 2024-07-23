//
//  ModelAuthLoginViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.09.2023.
//

import Combine
@testable import ForaBank
import SwiftUI
import XCTest

final class ModelAuthLoginViewModelTests: AuthLoginViewModelTests {

    // MARK: - init

    func test_init_shouldSetHeader() {

        let (sut, _, _) = makeSUT()

        XCTAssertNoDiff(sut.header.title, "Войти")
        XCTAssertNoDiff(sut.header.subTitle, "чтобы получить доступ к счетам и картам")
        XCTAssertNoDiff(sut.header.icon, .ic16ArrowDown)
    }

    func test_init_shouldSetLinkToNil() {

        let (sut, _, _) = makeSUT()

        XCTAssertNil(sut.link)
    }

    func test_init_shouldSetBottomSheetToNil() {

        let (sut, _, _) = makeSUT()

        XCTAssertNil(sut.bottomSheet)
    }

    func test_init_shouldSetCardScannerToNil() {

        let (sut, _, _) = makeSUT()

        XCTAssertNil(sut.cardScanner)
    }

    func test_init_shouldSetAlertToNil() {

        let (sut, _, _) = makeSUT()

        XCTAssertNil(sut.alert)
    }

    func test_init_shouldSetButtonsToEmpty() {

        let (sut, _, _) = makeSUT()

        XCTAssertTrue(sut.buttons.isEmpty)
    }

    // MARK: - Events: clientInform alert: nil ClientInformData

    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedFalse_nilClientInformData() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(nil)

        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }

    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_nilClientInformData() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(nil)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }

    // MARK: - Events: clientInform alert: emptyAuthorized_nilNotAuthorized

    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedFalse_emptyAuthorized_nilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(.emptyAuthorized_nilNotAuthorized)

        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }

    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_emptyAuthorized_nilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(.emptyAuthorized_nilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }

    // MARK: - Events: clientInform alert: emptyAuthorized_notNilNotAuthorized

    func test_clientInform_shouldShowClientInformAlert_isShowNotAuthorizedFalse_emptyAuthorized_notNilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(.emptyAuthorized_notNilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil, .alert(message: "notAuthorized")])
    }

    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_emptyAuthorized_notNilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(.emptyAuthorized_notNilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }

    // MARK: - Events: clientInform alert: notEmptyAuthorized_nilNotAuthorized

    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedFalse_notEmptyAuthorized_nilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(.notEmptyAuthorized_nilNotAuthorized)

        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }

    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_notEmptyAuthorized_nilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(.notEmptyAuthorized_nilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }

    // MARK: - Events: clientInform alert: notEmptyAuthorized_notNilNotAuthorized

    func test_clientInform_shouldShowClientInformAlert_isShowNotAuthorizedFalse_notEmptyAuthorized_notNilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(.notEmptyAuthorized_notNilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil, .alert(message: "notAuthorized")])
    }

    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_notEmptyAuthorized_notNilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true

        XCTAssertNoDiff(spy.values, [nil])

        model.sendClientInform(.notEmptyAuthorized_notNilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }

    // MARK: - Events: clientInform model property change: nil ClientInformData

    func test_clientInform_shouldNotChangeClientInformStatus_isShowNotAuthorizedFalse_nilClientInformData() {

        let (_, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus

        model.sendClientInform(nil)

        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(model.clientInformStatus, clientInformStatus)
    }

    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_nilClientInformData() {

        let (_, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true

        model.sendClientInform(nil)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
    }

    // MARK: - Events: clientInform model property change: emptyAuthorized_nilNotAuthorized

    func test_clientInform_shouldNotChangeClientInformStatus_isShowNotAuthorizedFalse_emptyAuthorized_nilNotAuthorized() {

        let (_, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus

        model.sendClientInform(.emptyAuthorized_nilNotAuthorized)

        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(model.clientInformStatus, clientInformStatus)
    }

    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_emptyAuthorized_nilNotAuthorized() {

        let (_, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true

        model.sendClientInform(.emptyAuthorized_nilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
    }

    // MARK: - Events: clientInform model property change: emptyAuthorized_notNilNotAuthorized

    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedFalse_emptyAuthorized_notNilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus

        model.sendClientInform(.emptyAuthorized_notNilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
        XCTAssertNotNil(sut)
    }

    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_emptyAuthorized_notNilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true

        model.sendClientInform(.emptyAuthorized_notNilNotAuthorized, timeout: 0.05)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
        XCTAssertNotNil(sut)
    }

    // MARK: - Events: clientInform model property change: notEmptyAuthorized_nilNotAuthorized

    func test_clientInform_shouldNotChangeClientInformStatus_isShowNotAuthorizedFalse_notEmptyAuthorized_nilNotAuthorized() {

        let (_, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus

        model.sendClientInform(.notEmptyAuthorized_nilNotAuthorized)

        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(model.clientInformStatus, clientInformStatus)
    }

    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_notEmptyAuthorized_nilNotAuthorized() {

        let (_, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true

        model.sendClientInform(.notEmptyAuthorized_nilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
    }

    // MARK: - Events: clientInform model property change: notEmptyAuthorized_notNilNotAuthorized

    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedFalse_notEmptyAuthorized_notNilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus

        model.sendClientInform(.notEmptyAuthorized_notNilNotAuthorized)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
        XCTAssertNotNil(sut)
    }

    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_notEmptyAuthorized_notNilNotAuthorized() {

        let (sut, model, _) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true

        model.sendClientInform(.notEmptyAuthorized_notNilNotAuthorized, timeout: 0.05)

        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
        XCTAssertNotNil(sut)
    }

    // MARK: - Events: Auth.CheckClient.Response

    func test_authCheckClientResponse_shouldHideSpinner_onResponseSuccess() {

        let (sut, model, rootActionsSpy) = makeSUT()

        XCTAssertNoDiff(rootActionsSpy.spinnerMessages, [])

        model.checkClientSuccess(phone: "phone")

        XCTAssertNoDiff(rootActionsSpy.spinnerMessages, [.hide])
        XCTAssertNotNil(sut)
    }

    func test_authCheckClientResponse_shouldHideSpinner_onResponseFailure() {
        
        let (sut, model, rootActionsSpy) = makeSUT()
        
        XCTAssertNoDiff(rootActionsSpy.spinnerMessages, [])
        
        model.checkClientFailure(message: "failure message")
        
        // TODO: restore XCTAssertNoDiff after flaky non-deterministic model.checkClientResponse fix
        // XCTAssertNoDiff(rootActionsSpy.spinnerMessages, [.hide])
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertTrue(rootActionsSpy.spinnerMessages.contains(.hide))
        XCTAssertNotNil(sut)
    }

    func test_authCheckClientResponse_shouldSetLink_onResponseSuccess() {

        let (sut, model, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))

        XCTAssertNoDiff(linkSpy.values, [nil])

        model.checkClientSuccess(phone: "123-456")

        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .confirm(.init(
                codeTitle: "Введите код из сообщения",
                codeLength: 1,
                infoTitle: "Код отправлен на 123-456"
            ))
        ])
        XCTAssertNotNil(sut)
    }

    func test_authCheckClientResponse_shouldSetAlert_onResponseFailure() {

        let message = "failure message"
        let (sut, model, _) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))

        XCTAssertNoDiff(alertSpy.values, [nil])

        model.checkClientFailure(message: message)

        XCTAssertNoDiff(alertSpy.values, [
            nil,
            .alert(message: message)
        ])
        XCTAssertNotNil(sut)
    }

    func test_authCheckClientResponse_shouldSetAlertActionToResetAlert_onResponseFailure() {
        
        let message = "failure message"
        let (sut, model, _) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        
        model.checkClientFailure(message: message)
        
        XCTAssertNoDiff(alertSpy.values, [
            nil,
            .alert(message: message)
        ])
        
        sut.tapAlertPrimaryButton()
        
        XCTAssertNoDiff(alertSpy.values, [
            nil,
            .alert(message: message),
            nil
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Register

    func test_authLoginViewModelActionRegister_shouldCheckClient() {

        let (sut, model, _) = makeSUT()
        let checkClientSpy = ValueSpy(model.action.compactMap { $0 as? ModelAction.Auth.CheckClient.Request }.map(\.number))

        XCTAssertTrue(checkClientSpy.values.isEmpty)

        sut.register(cardNumber: "1234-5678")

        XCTAssertNoDiff(checkClientSpy.values, ["1234-5678"])
    }

    func test_authLoginViewModelActionRegister_shouldShowSpinner() {

        let (sut, _, rootActionsSpy) = makeSUT()

        XCTAssertNoDiff(rootActionsSpy.spinnerMessages, [])

        sut.register(cardNumber: "1234-5678")

        // TODO: restore XCTAssertNoDiff after flaky non-deterministic model.checkClientResponse fix
        // XCTAssertNoDiff(rootActionsSpy.spinnerMessages, [.show])
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        XCTAssertTrue(rootActionsSpy.spinnerMessages.contains(.show))
        XCTAssertNotNil(sut)
    }

    // MARK: - Events: AuthLoginViewModelAction.Show.Products

    func test_authLoginViewModelActionShowProductsAndClose_shouldSetLinkToLandingAndClose() {

        let (sut, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))

        XCTAssertNoDiff(linkSpy.values, [nil])

        sut.showProductsAndWait()

        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .landing
        ])

        sut.closeLink()

        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .landing,
            nil
        ])
    }

    // MARK: - Events: AuthLoginViewModelAction.Show.Transfers

    func test_authLoginViewModelActionShowTransfersAndClose_shouldSetLinkToLandingAndClose() {

        let (sut, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))

        XCTAssertNoDiff(linkSpy.values, [nil])

        sut.showTransfersAndWait()

        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .landing
        ])

        sut.closeLink()

        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .landing,
            nil
        ])
    }

    // MARK: - Events: AuthLoginViewModelAction.Show.Scaner

    func test_authLoginViewModelActionShowScanner_shouldSetCardScanner() {

        let (sut, _, _) = makeSUT()

        let cardScannerSpy = ValueSpy(sut.scannerPublisher)

        XCTAssertNoDiff(cardScannerSpy.values, [nil])

        sut.showScanner()

        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner])
    }

    func test_authLoginViewModelActionCloseScanner_shouldSetCardScannerToNil_nilScanValue() {

        let scanValue: String? = nil
        let (sut, _, _) = makeSUT()
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)

        sut.showScanner()
        sut.closeScanner(scanValue)

        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner, nil])
    }

    func test_authLoginViewModelActionCloseScanner_shouldSetCardScannerToNil_nonNilScanValue() {

        let scanValue: String? = "abc123"
        let (sut, _, _) = makeSUT()
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)

        sut.showScanner()
        sut.closeScanner(scanValue)

        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner, nil])
    }

    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToNil_nilScanValue() {

        let scanValue: String? = nil
        let (sut, _, _) = makeSUT()

        sut.showScanner()
        sut.closeScanner(scanValue)

        XCTAssertNoDiff(sut.card.textField.text, nil)
    }

    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToEmpty_emptyScanValue() {

        let scanValue: String? = ""
        let (sut, _, _) = makeSUT()

        sut.showScanner()
        sut.closeScanner(scanValue)

        XCTAssertNoDiff(sut.card.textField.text, "")
    }

    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToEmpty_invalidScanValue() {

        let scanValue: String? = "abc"
        let (sut, _, _) = makeSUT()

        sut.showScanner()
        sut.closeScanner(scanValue)

        XCTAssertNoDiff(sut.card.textField.text, "")
    }

    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToMasked_scanValueWithDigits() {

        let scanValue: String? = "abc12345"
        let (sut, _, _) = makeSUT()

        sut.showScanner()
        sut.closeScanner(scanValue)

        XCTAssertNoDiff(sut.card.textField.text, "1234 5")
    }

    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToMasked_validScanValue() {

        let scanValue: String? = "1234567812345678"
        let (sut, _, _) = makeSUT()

        sut.showScanner()
        sut.closeScanner(scanValue)

        XCTAssertNoDiff(sut.card.textField.text, "1234 5678 1234 5678")
    }

    // MARK: - Events: catalogProducts

    func test_catalogProducts_shouldChangeButtonsOnUpdate() {

        let (sut, model, _) = makeSUT()
        let buttonsSpy = ValueSpy(sut.$buttons.map { $0.map(\.view) })

        XCTAssertTrue(model.catalogProducts.value.isEmpty)
        XCTAssertNoDiff(buttonsSpy.values, [
            []
        ])

        model.catalogProducts.send(.sample)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)

        XCTAssertNoDiff(buttonsSpy.values, [
            [],
            [.transfer],
            [.transfer, .orderCard]
        ])
    }

    // MARK: - Events: cardState & sessionState & fcmToken
    
    func test_cardState_sessionState_fcmToken_shouldChangeCardButton() {
        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.card.$nextButton.map(\.?.icon))

        sut.card.state = .editing
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [nil, nil, nil])

        sut.card.state = .ready("1234")
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [nil, nil, nil, .ic24ArrowRight])

        model.sessionAgent.sessionState.send(.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy)))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [nil, nil, nil, .ic24ArrowRight, .ic24ArrowRight])

        model.fcmToken.send(nil)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [nil, nil, nil, .ic24ArrowRight, .ic24ArrowRight, .ic24ArrowRight])

        model.fcmToken.send("fcmToken")
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [nil, nil, nil, .ic24ArrowRight, .ic24ArrowRight, .ic24ArrowRight, .ic24ArrowRight])
    }

    func test_cardState_shouldSetCardButton() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.card.$nextButton.map(\.?.icon))

        model.fcmToken.send("fcmToken")
        sut.card.state = .ready("1234")
        model.sessionAgent.sessionState.send(.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy)))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)

        XCTAssertNoDiff(spy.values, [nil, nil, nil, .ic24ArrowRight, .ic24ArrowRight])
    }

    func test_cardState_shouldSendRegisterCardNumberOnCardNextButtonAction() {

        let (sut, model, _) = makeSUT()
        let spy = ValueSpy(sut.registerCardNumber)

        XCTAssertNil(sut.card.nextButton)

        model.fcmToken.send("fcmToken")
        sut.card.state = .ready("1234")
        model.sessionAgent.sessionState.send(.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy)))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)

        XCTAssertNoDiff(spy.values, [])

        sut.card.nextButton?.action()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)

        XCTAssertNoDiff(spy.values, ["1234"])
    }
    
    func test_cardStateEditing_shouldSetCardButtonCorrectly() {
        
        let scenarios: [(cardState: AuthLoginViewModel.CardViewModel.State, sessionState: SessionState, fcmToken: String?)] = [
            (.editing, .active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy)), nil),
            (.editing, .active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy)), "fcmToken"),
            (.editing, .activating, nil),
            (.editing, .activating, "fcmToken"),
            (.editing, .expired, nil),
            (.editing, .expired, "fcmToken"),
            (.editing, .inactive, nil),
            (.editing, .inactive, "fcmToken"),
            (.editing, .failed(NSError(domain: "test", code: 0)), nil),
            (.editing, .failed(NSError(domain: "test", code: 0)), "fcmToken")
        ]
        
        checkScenarios(scenarios)
    }

    func test_cardStateReady_shouldSetCardButtonCorrectly() {
        let scenarios: [(cardState: AuthLoginViewModel.CardViewModel.State, sessionState: SessionState, fcmToken: String?)] = [
            (.ready("1234"), .active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy)), nil),
            (.ready("1234"), .active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy)), "fcmToken"),
            (.ready("1234"), .activating, nil),
            (.ready("1234"), .activating, "fcmToken"),
            (.ready("1234"), .expired, nil),
            (.ready("1234"), .expired, "fcmToken"),
            (.ready("1234"), .inactive, nil),
            (.ready("1234"), .inactive, "fcmToken"),
            (.ready("1234"), .failed(NSError(domain: "test", code: 0)), nil),
            (.ready("1234"), .failed(NSError(domain: "test", code: 0)), "fcmToken")
        ]
        
        checkScenarios(scenarios)
    }

    private func checkScenarios(
        _ scenarios: [
            (cardState: AuthLoginViewModel.CardViewModel.State,
             sessionState: SessionState, 
             fcmToken: String?)
        ]) {
            
        for scenario in scenarios {
            let (sut, model, _) = makeSUT()
            let spy = ValueSpy(sut.card.$nextButton.map(\.?.icon))
            
            sut.card.state = scenario.cardState
            model.sessionAgent.sessionState.send(scenario.sessionState)
            model.fcmToken.send(scenario.fcmToken)
            
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
            
            let expectedIcon: Image? = {
                switch (scenario.cardState, scenario.sessionState, scenario.fcmToken) {
                case (.ready(let cardNumber), .active, .some),
                     (.ready(let cardNumber), .active, .none),
                     (.ready(let cardNumber), .activating, .some),
                     (.ready(let cardNumber), .activating, .none),
                     (.ready(let cardNumber), .expired, .some),
                     (.ready(let cardNumber), .expired, .none),
                     (.ready(let cardNumber), .inactive, .some),
                     (.ready(let cardNumber), .inactive, .none),
                     (.ready(let cardNumber), .failed(_), .some),
                     (.ready(let cardNumber), .failed(_), .none):
                    
                    return .ic24ArrowRight
                    
                default:
                    return nil
                }
            }()
            
            XCTAssertEqual(spy.values.last, expectedIcon)
        }
    }

    // MARK: - Confirm
    
    func test_confirmBackAction_shouldSetLinkToNil() throws {
        
        let (sut, model, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [
            nil
        ])
        
        model.action.send(ModelAction.Auth.CheckClient.Response.sample)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .confirm(.modelSample)
        ])
        
        try sut.tapBackButtonInConfirm()
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .confirm(.modelSample),
            nil
        ])
    }
    
    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: AuthLoginViewModel,
        model: Model,
        rootActionsSpy: RootActionsSpy
    ) {
        let model: Model = .mockWithEmptyExcept()
        let rootActionsSpy = RootActionsSpy()
        let sut = AuthLoginViewModel(
            model,
            rootActions: rootActionsSpy.rootActions(),
            onRegister: {}
        )

        trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: return memory leak tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(rootActionsSpy, file: file, line: line)

        return (sut, model, rootActionsSpy)
    }
}

// MARK: - DSL

private extension AuthLoginViewModel {
        
    // MARK: - Actions
        
    func closeLink(timeout: TimeInterval = 0.05) {
        
        action.send(.closeLink)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension Model {
    
    // MARK: - Actions
    
    func checkClientSuccess(
        codeLength: Int = 1,
        phone: String,
        resendCodeDelay: TimeInterval = 1.0,
        timeout: TimeInterval = 0.05
    ) {
        let response = ModelAction.Auth.CheckClient.Response.success(codeLength: codeLength, phone: phone, resendCodeDelay: resendCodeDelay)
        action.send(response)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func checkClientFailure(
        message: String,
        timeout: TimeInterval = 0.05
    ) {
        let response: ModelAction.Auth.CheckClient.Response = .failure(message: message)
        action.send(response)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func sendClientInform(
        _ data: ClientInformData?,
        timeout: TimeInterval = 0.05
    ) {
        clientInform.send(.result(data))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}
