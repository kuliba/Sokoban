//
//  WaitingAuthLoginViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.09.2023.
//

import Combine
@testable import Vortex
import SwiftUI
import XCTest
import LandingUIComponent

final class WaitingAuthLoginViewModelTests: AuthLoginViewModelTests {
    
    // MARK: - init
    
    func test_init_shouldSetHeader() {
        
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNoDiff(sut.header.title, "Войти")
        XCTAssertNoDiff(sut.header.subTitle, "чтобы получить доступ к счетам и картам")
        XCTAssertNoDiff(sut.header.icon, .ic16ArrowDown)
    }
    
    func test_init_shouldSetLinkToNil() {
        
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNil(sut.link)
    }
    
    func test_init_shouldSetBottomSheetToNil() {
        
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNil(sut.bottomSheet)
    }
    
    func test_init_shouldSetCardScannerToNil() {
        
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNil(sut.cardScanner)
    }
    
    func test_init_shouldSetAlertToNil() {
        
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNil(sut.alert)
    }
    
    func test_init_shouldSetButtonsToEmpty() {
        
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertTrue(sut.buttons.isEmpty)
    }
    
    // MARK: - LandingWrapperComponent action: orderCard
    
    func test_landing_orderCard_shouldCallOrderCard() {
        
        let (sut, _, _, _, _, _, factory, _) = makeSUT()
        
        XCTAssertNoDiff(factory.cardOrders, [])
        
        sut.showProductsAndWait()
        sut.orderCard(cardTarif: 123, cardType: 321)
        
        XCTAssertNoDiff(factory.cardOrders, [
            .init(cardTarif: 123, cardType: 321)
        ])
    }
    
    // MARK: - LandingWrapperComponent action: goToMain
    
    func test_landing_goToMain_shouldCallGoToMain() {
        
        let (sut, _, _, _, _, _, factory, _) = makeSUT()
        
        XCTAssertNoDiff(factory.goToMainCount, 0)
        
        sut.showProductsAndWait()
        sut.goToMain()
        
        XCTAssertNoDiff(factory.goToMainCount, 1)
    }
    
    // MARK: - Events: clientInform
    
    func test_alertManager_shouldReturnFalseOnUpdatePermissionFalse() {
        
        let alertManager = NotAuthorizedAlertManager()
        let updatePermission = alertManager.updatePermissionPublisher
        let spy = ValueSpy(updatePermission)

        XCTAssertNoDiff(spy.values, [true])
        
        sendUpdatePermission(alertManager, shouldUpdate: false)
        
        XCTAssertNoDiff(spy.values, [true, false])
    }
    
    func test_alertManager_shouldReturnTrueOnUpdatePermissionTrue() {
        
        let alertManager = NotAuthorizedAlertManager()
        let updatePermission = alertManager.updatePermissionPublisher
        let spy = ValueSpy(updatePermission)

        XCTAssertNoDiff(spy.values, [true])
        
        sendUpdatePermission(alertManager, shouldUpdate: true)
        
        XCTAssertNoDiff(spy.values, [true, true])
    }
    
    func test_clientInform_shouldShowClientInformAlertWithMessage() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        let alert = makeClientInformAlert(
            informAlerts: [makeInformAlertItem()],
            updateAlert: makeUpdateAlertItem()
        )
        XCTAssertNoDiff(spy.values, [])
        
        send(alertManager, alerts: alert)
        
        XCTAssertNoDiff(spy.values, [alert])
    }
    
    func test_swiftUIAlert_forClientInformAlerts_ShouldNotDeliverAlertsOnNil() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        XCTAssertNoDiff(spy.values, [])
        
        send(alertManager, alerts: nil)
        
        XCTAssertNoDiff(spy.values, [])
    }
    
    func test_swiftUIAlert_forClientInformAlerts_withEmptyArrayAndNilUpdateAlert() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        let alert = makeClientInformAlert(informAlerts: [], updateAlert: nil)
        XCTAssertNoDiff(spy.values, [])
        
        send(alertManager, alerts: alert)
        
        XCTAssertNoDiff(spy.values, [alert])
    }
    
    func test_swiftUIAlert_forClientInformAlerts_withOneInformElementArrayAndNilUpdateAlert() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        let alert = makeClientInformAlert(
            informAlerts: [makeInformAlertItem()],
            updateAlert: nil
        )
        XCTAssertNoDiff(spy.values, [])
        
        send(alertManager, alerts: alert)
        
        XCTAssertNoDiff(spy.values, [alert])
    }
    
    func test_swiftUIAlert_forClientInformAlerts_withTwoInformElementsArrayAndNilUpdateAlert() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        let alert = makeClientInformAlert(
            informAlerts: [makeInformAlertItem(), makeInformAlertItem()],
            updateAlert: nil
        )
        XCTAssertNoDiff(spy.values, [])
        
        send(alertManager, alerts: alert)
        
        XCTAssertNoDiff(spy.values, [alert])
    }
    
    func test_swiftUIAlert_forClientInformAlerts_withEmptyArrayAndUpdateAlert() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        let alert = makeClientInformAlert(
            informAlerts: [],
            updateAlert: makeUpdateAlertItem()
        )
        XCTAssertNoDiff(spy.values, [])
        
        send(alertManager, alerts: alert)
        
        XCTAssertNoDiff(spy.values, [alert])
    }
    
    func test_swiftUIAlert_forClientInformAlerts_withAuthBlockingAlert() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        let alert = makeClientInformAlert(
            informAlerts: [],
            updateAlert: makeAuthBlockingAlertItem()
        )
        XCTAssertNoDiff(spy.values, [])
        
        send(alertManager, alerts: alert)
        
        XCTAssertNoDiff(spy.values, [alert])
    }
    
    func test_swiftUIAlert_forClientInformAlerts_withOneInformElementsArrayAndUpdateAlert() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        let alert = makeClientInformAlert(
            informAlerts: [makeInformAlertItem()],
            updateAlert: makeUpdateAlertItem()
        )
        XCTAssertNoDiff(spy.values, [])
        
        send(alertManager, alerts: alert)
        
        XCTAssertNoDiff(spy.values, [alert])
    }
    
    func test_swiftUIAlert_forClientInformAlerts_withTwoInformElementsArrayAndUpdateAlert() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        let alert = makeClientInformAlert(
            informAlerts: [makeInformAlertItem(), makeInformAlertItem()],
            updateAlert: makeUpdateAlertItem()
        )
        XCTAssertNoDiff(spy.values, [])
        
        send(alertManager, alerts: alert)
        
        XCTAssertNoDiff(spy.values, [alert])
    }
    
    func test_swiftUIAlert_forClientInformAlerts_mixedResponse() {
        
        let (sut, alertManager, _,_,_,_,_,_) = makeSUT()
        let spy = ValueSpy(sut.clientInformAlertPublisher)
        let oneElementInformArrayAndUpdateAlert = makeClientInformAlert(
            informAlerts: [makeInformAlertItem()],
            updateAlert: makeUpdateAlertItem()
        )
        XCTAssertNoDiff(spy.values, [])
        
        let twoElementInformArrayAndUpdateAlert = makeClientInformAlert(
            informAlerts: [makeInformAlertItem(), makeInformAlertItem()],
            updateAlert: makeUpdateAlertItem()
        )
        send(alertManager, alerts: nil)
        send(alertManager, alerts: oneElementInformArrayAndUpdateAlert)
        send(alertManager, alerts: nil)
        send(alertManager, alerts: nil)
        send(alertManager, alerts: twoElementInformArrayAndUpdateAlert)
        send(alertManager, alerts: nil)
        
        XCTAssertNoDiff(spy.values, [
            oneElementInformArrayAndUpdateAlert,
            twoElementInformArrayAndUpdateAlert
        ])
    }
        
    // MARK: - Events: Auth.CheckClient.Response
    
    func test_authCheckClientResponse_shouldHideSpinner_onResponseSuccess() {
        
        let (sut, _, checkClientResponse, _, _, _, _, rootActionSpy) = makeSUT()
        
        checkClientResponse.send(.sample)
        XCTAssertNoDiff(rootActionSpy.spinnerMessages, [])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(rootActionSpy.spinnerMessages, [.hide])
        XCTAssertNotNil(sut)
    }
    
    func test_authCheckClientResponse_shouldHideSpinner_onResponseFailure() {
        
        let message = "message"
        let (sut, _, checkClientResponse, _, _, _, _, rootActionSpy) = makeSUT()
        
        checkClientResponse.send(.failure(message: message))
        XCTAssertNoDiff(rootActionSpy.spinnerMessages, [])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(rootActionSpy.spinnerMessages, [.hide])
        XCTAssertNotNil(sut)
    }
    
    func test_authCheckClientResponse_shouldSetLink_onResponseSuccess() {
        
        let (sut, _, checkClientResponse, _, _, _, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        
        checkClientResponse.send(.sample)
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .confirm(.sample)
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_authCheckClientResponse_shouldSetAlert_onResponseFailure() {
        
        let message = "failure message"
        let (sut, _, checkClientResponse, _, _, _, _, _) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        
        checkClientResponse.send(.failure(message: message))
        XCTAssertNoDiff(alertSpy.values, [nil])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(alertSpy.values, [
            nil,
            .alert(message: message)
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_authCheckClientResponse_shouldSetAlertActionToResetAlert_onResponseFailure() {
        
        let message = "failure message"
        let (sut, _, checkClientResponse, _, _, _, _, _) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        
        checkClientResponse.send(.failure(message: message))
        XCTAssertNoDiff(alertSpy.values, [nil])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
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
        
        let (sut, _, _, _, _, registerCardNumberSpy, _, _) = makeSUT()
        
        XCTAssertTrue(registerCardNumberSpy.values.isEmpty)
        
        sut.register(cardNumber: "1234-5678")
        
        XCTAssertNoDiff(registerCardNumberSpy.values, ["1234-5678"])
    }
    
    func test_authLoginViewModelActionRegister_shouldShowSpinner() {
        
        let (sut, _, _, _, _, _, _, rootActionsSpy) = makeSUT()
        
        XCTAssertNoDiff(rootActionsSpy.spinnerMessages, [])
        
        sut.register(cardNumber: "1234-5678")
        
        XCTAssertNoDiff(rootActionsSpy.spinnerMessages, [.show])
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Show.Products
    
    func test_authLoginViewModelActionShowProducts_shouldSetLinkToLanding() {
        
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showProductsAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .landing
        ])
    }
    
    func test_showProducts_shouldCreateLandingWithOrderCardAbroadType() {
        
        let (sut, _, _, _, _, _, factory, _) = makeSUT()
        
        XCTAssertNoDiff(factory.abroadType, nil)
        
        sut.showProductsAndWait()
        
        XCTAssertNoDiff(factory.abroadType, .orderCard)
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Show.Transfers
    
    func test_authLoginViewModelActionShowTransfers_shouldSetLinkToLanding() {
        
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showTransfersAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .landing
        ])
    }
    
    func test_showTransfers_shouldCreateLandingWithTransferAbroadType() {
        
        let (sut, _, _, _, _, _, factory, _) = makeSUT()
        
        XCTAssertNoDiff(factory.abroadType, nil)
        
        sut.showTransfersAndWait()
        
        XCTAssertNoDiff(factory.abroadType, .transfer)
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Show.Scaner
    
    func test_authLoginViewModelActionShowScanner_shouldSetCardScanner() {
        
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil])
        
        sut.showScanner()
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner])
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardScannerToNil_nilScanValue() {
        
        let scanValue: String? = nil
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner, nil])
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardScannerToNil_nonNilScanValue() {
        
        let scanValue: String? = "abc123"
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner, nil])
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToNil_nilScanValue() {
        
        let scanValue: String? = nil
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, nil)
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToEmpty_emptyScanValue() {
        
        let scanValue: String? = ""
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, "")
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToEmpty_invalidScanValue() {
        
        let scanValue: String? = "abc"
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, "")
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToMasked_scanValueWithDigits() {
        
        let scanValue: String? = "abc12345"
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, "1234 5")
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToMasked_validScanValue() {
        
        let scanValue: String? = "1234567812345678"
        let (sut, _, _, _, _, _, _, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, "1234 5678 1234 5678")
    }
    
    // MARK: - Events: catalogProducts & transferAbroad
    
    func test_catalogProducts_transferAbroad_shouldChangeButtonsOnUpdate() {
        
        let (sut, _, _, catalogProducts, _, _, _, _) = makeSUT(catalogProductDataStub: .sample)
        let buttonsSpy = ValueSpy(sut.$buttons.map { $0.map(\.view) })
        
        XCTAssertNoDiff(buttonsSpy.values, [
            []
        ])
        
        catalogProducts.send((.sample))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(buttonsSpy.values, [
            [],
            [.transfer, .orderCard]
        ])
    }
    
    // MARK: - Events: cardState & sessionState & fcmToken
    
    func test_cardState_sessionState_fcmToken_shouldChangeCardButton() {
        
        let (sut, _, _, _, sessionStateFcmToken, _, _, _) = makeSUT()
        let spy = ValueSpy(sut.card.$nextButton.map(\.?.icon))
        
        sut.card.state = .editing
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil])
        
        sut.card.state = .ready("1234")
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil])
        
        sessionStateFcmToken.send(((.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy))), nil))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, .ic24ArrowRight])
        
        sessionStateFcmToken.send(((.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy))), "fcmToken"))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, .ic24ArrowRight, .ic24ArrowRight])
    }
    
    func test_cardState_shouldSetCardButton() {
        
        let (sut, _, _, _, sessionStateFcmToken, _, _, _) = makeSUT()
        let spy = ValueSpy(sut.card.$nextButton.map(\.?.icon))
        
        sessionStateFcmToken.send(((.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy))), "fcmToken"))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, nil])
        
        sut.card.state = .ready("1234")
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, nil, .ic24ArrowRight])
    }
    
    func test_cardState_shouldSendRegisterCardNumberOnCardNextButtonAction() {
        
        let (sut, _, _, _, sessionStateFcmToken, _, _, _) = makeSUT()
        let spy = ValueSpy(sut.registerCardNumber)
        
        XCTAssertNil(sut.card.nextButton)
        
        sessionStateFcmToken.send(((.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy))), "fcmToken"))
        sut.card.state = .ready("1234")
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [])
        
        sut.card.nextButton?.action()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, ["1234"])
    }
    
    // MARK: - Buttons
    
    func test_transfersButton_shouldSetLinkToLandingOnAction() throws {
        
        let (sut, _, _, catalogProducts, _, _, factorySpy, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        XCTAssertNil(factorySpy.abroadType)
        
        try tapTransferButton(sut, catalogProducts)
        
        XCTAssertNoDiff(linkSpy.values, [nil, .landing])
        XCTAssertNoDiff(factorySpy.abroadType, .transfer)
    }
    
    func test_orderCardButton_shouldSetLinkToLandingOnAction() throws {
        
        let (sut, _, _, catalogProducts, _, _, factorySpy, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        XCTAssertNil(factorySpy.abroadType)
        
        try tapOrderCardButton(sut, catalogProducts)
        
        XCTAssertNoDiff(linkSpy.values, [nil, .landing])
        XCTAssertNoDiff(factorySpy.abroadType, .orderCard)
    }
    
    // MARK: - Confirm
    
    func test_confirmBackAction_shouldSetLinkToNil() throws {
        
        let (sut, _, checkClientResponse, _, _, _, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [
            nil
        ])
        
        checkClientResponse.send(.sample)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .confirm(.sample)
        ])
        
        try sut.tapBackButtonInConfirm()
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .confirm(.sample),
            nil
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        catalogProductDataStub: CatalogProductData? = nil,
        shouldUpdateVersion: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: AuthLoginViewModel,
        clientInformAlertManager: AlertManagerSpy,
        checkClientResponse: CheckClientResponse,
        catalogProducts: CatalogProducts,
        sessionStateFcmToken: SessionStateFcmToken,
        registerCardNumberSpy: RegisterCardNumberSpy,
        factory: AuthLoginViewModelFactorySpy,
        rootActionsSpy: RootActionsSpy
    ) {
        let checkClientResponse = CheckClientResponse()
        let catalogProducts = CatalogProducts()
        let sessionStateFcmToken = SessionStateFcmToken()
        
        let clientInformAlertManager = AlertManagerSpy()
        
        let eventPublishers = AuthLoginViewModel.EventPublishers(
            checkClientResponse: checkClientResponse.eraseToAnyPublisher(),
            catalogProducts: catalogProducts.eraseToAnyPublisher(),
            sessionStateFcmToken: sessionStateFcmToken.eraseToAnyPublisher()
        )
        
        let registerCardNumberSpy = RegisterCardNumberSpy()
        let rootActionsSpy = RootActionsSpy()
        
        let eventHandlers = AuthLoginViewModel.EventHandlers(
            onRegisterCardNumber: registerCardNumberSpy.registerCardNumber,
            catalogProduct: { _ in catalogProductDataStub },
            showSpinner: rootActionsSpy.rootActions().spinner.show,
            hideSpinner: rootActionsSpy.rootActions().spinner.hide
        )
        
        let factory = AuthLoginViewModelFactorySpy(
            products: [catalogProductDataStub].compactMap { $0 }
        )
        
        let sut = AuthLoginViewModel(
            clientInformAlertsManager: clientInformAlertManager,
            eventPublishers: eventPublishers,
            eventHandlers: eventHandlers,
            factory: factory,
            onRegister: {},
            shouldUpdateVersion: { _ in shouldUpdateVersion }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(factory, file: file, line: line)
        trackForMemoryLeaks(rootActionsSpy, file: file, line: line)
        
        return (sut, clientInformAlertManager, checkClientResponse, catalogProducts, sessionStateFcmToken, registerCardNumberSpy, factory, rootActionsSpy)
    }
    
    private func tapTransferButton(
        _ sut: AuthLoginViewModel,
        _ catalogProducts: CatalogProducts,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        catalogProducts.send((.sample))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        let transferButton = try XCTUnwrap(sut.buttons.first(where: { $0.id == .abroad }), "Expected to have transfer button but got nil.", file: file, line: line)
        
        transferButton.action()
    }
    
    private func tapOrderCardButton(
        _ sut: AuthLoginViewModel,
        _ catalogProducts: CatalogProducts,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        catalogProducts.send((.sample))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        let orderCardButton = try XCTUnwrap(sut.buttons.first(where: { $0.id == .card }), "Expected to have order card button but got nil.", file: file, line: line)
        
        orderCardButton.action()
    }
    
    private func send(
        _ alertManager: AlertManagerSpy,
        alerts: ClientInformAlerts?,
        timeout: TimeInterval = 0.05
    ) {
        alertManager.emit(alerts)
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    private func sendUpdatePermission(
        _ alertManager: NotAuthorizedAlertManager,
        shouldUpdate: Bool,
        timeout: TimeInterval = 0.05
    ) {
        alertManager.setUpdatePermission(shouldUpdate)
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }

    private func makeInformAlertItem(
        informTitle: String = anyMessage(),
        informText: String = anyMessage()
    ) -> ClientInformAlerts.InformAlert {
        
        .init(id: .init(), title: informTitle, text: informText)
    }
    
    private func makeAuthBlockingAlertItem(
        updateTitle: String = anyMessage(),
        updateText: String = anyMessage(),
        updateLink: String = anyMessage(),
        updateVersion: String = anyMessage()
    )  -> ClientInformAlerts.UpdateAlert {
        
        .init(
            id: .init(),
            title: updateTitle,
            text: updateText,
            link: updateLink,
            version: updateVersion,
            actionType: .authBlocking
        )
    }

    private func makeUpdateAlertItem(
        updateTitle: String = anyMessage(),
        updateText: String = anyMessage(),
        updateLink: String = anyMessage(),
        updateVersion: String = anyMessage()
    )  -> ClientInformAlerts.UpdateAlert {
        
        .init(
            id: .init(),
            title: updateTitle,
            text: updateText,
            link: updateLink,
            version: updateVersion,
            actionType: .required
        )
    }
    
    private func makeClientInformAlert(
        id: UUID = .init(),
        informAlerts: [ClientInformAlerts.InformAlert],
        updateAlert: ClientInformAlerts.UpdateAlert?
    ) -> ClientInformAlerts {
        
        ClientInformAlerts(
            id: id,
            informAlerts: informAlerts,
            updateAlert: updateAlert
        )
    }
}
