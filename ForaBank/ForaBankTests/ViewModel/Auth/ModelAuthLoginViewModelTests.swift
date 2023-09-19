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

final class ModelAuthLoginViewModelTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetHeader() {
        
        let (sut, _) = makeSUT()
        
        XCTAssertNoDiff(sut.header.title, "Войти")
        XCTAssertNoDiff(sut.header.subTitle, "чтобы получить доступ к счетам и картам")
        XCTAssertNoDiff(sut.header.icon, .ic16ArrowDown)
    }
    
    func test_init_shouldSetLinkToNil() {
        
        let (sut, _) = makeSUT()
        
        XCTAssertNil(sut.link)
    }
    
    func test_init_shouldSetBottomSheetToNil() {
        
        let (sut, _) = makeSUT()
        
        XCTAssertNil(sut.bottomSheet)
    }
    
    func test_init_shouldSetCardScannerToNil() {
        
        let (sut, _) = makeSUT()
        
        XCTAssertNil(sut.cardScanner)
    }
    
    func test_init_shouldSetAlertToNil() {
        
        let (sut, _) = makeSUT()
        
        XCTAssertNil(sut.alert)
    }
    
    func test_init_shouldSetButtonsToEmpty() {
        
        let (sut, _) = makeSUT()
        
        XCTAssertTrue(sut.buttons.isEmpty)
    }
    
    // MARK: - Events: clientInform alert: nil ClientInformData
    
    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedFalse_nilClientInformData() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(nil)
        
        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_nilClientInformData() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(nil)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    // MARK: - Events: clientInform alert: emptyAuthorized_nilNotAuthorized
    
    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedFalse_emptyAuthorized_nilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(.emptyAuthorized_nilNotAuthorized)
        
        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_emptyAuthorized_nilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(.emptyAuthorized_nilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    // MARK: - Events: clientInform alert: emptyAuthorized_notNilNotAuthorized
    
    func test_clientInform_shouldShowClientInformAlert_isShowNotAuthorizedFalse_emptyAuthorized_notNilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(.emptyAuthorized_notNilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil, .alert(message: "notAuthorized")])
    }
    
    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_emptyAuthorized_notNilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(.emptyAuthorized_notNilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    // MARK: - Events: clientInform alert: notEmptyAuthorized_nilNotAuthorized
    
    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedFalse_notEmptyAuthorized_nilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(.notEmptyAuthorized_nilNotAuthorized)
        
        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_notEmptyAuthorized_nilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(.notEmptyAuthorized_nilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    // MARK: - Events: clientInform alert: notEmptyAuthorized_notNilNotAuthorized
    
    func test_clientInform_shouldShowClientInformAlert_isShowNotAuthorizedFalse_notEmptyAuthorized_notNilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(.notEmptyAuthorized_notNilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil, .alert(message: "notAuthorized")])
    }
    
    func test_clientInform_shouldNotShowClientInformAlert_isShowNotAuthorizedTrue_notEmptyAuthorized_notNilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        model.clientInformStatus.isShowNotAuthorized = true
        
        XCTAssertNoDiff(spy.values, [nil])
        
        model.sendClientInform(.notEmptyAuthorized_notNilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    // MARK: - Events: clientInform model property change: nil ClientInformData
    
    func test_clientInform_shouldNotChangeClientInformStatus_isShowNotAuthorizedFalse_nilClientInformData() {
        
        let (_, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        
        model.sendClientInform(nil)
        
        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(model.clientInformStatus, clientInformStatus)
    }
    
    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_nilClientInformData() {
        
        let (_, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true
        
        model.sendClientInform(nil)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
    }
    
    // MARK: - Events: clientInform model property change: emptyAuthorized_nilNotAuthorized
    
    func test_clientInform_shouldNotChangeClientInformStatus_isShowNotAuthorizedFalse_emptyAuthorized_nilNotAuthorized() {
        
        let (_, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        
        model.sendClientInform(.emptyAuthorized_nilNotAuthorized)
        
        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(model.clientInformStatus, clientInformStatus)
    }
    
    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_emptyAuthorized_nilNotAuthorized() {
        
        let (_, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true
        
        model.sendClientInform(.emptyAuthorized_nilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
    }
    
    // MARK: - Events: clientInform model property change: emptyAuthorized_notNilNotAuthorized
    
    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedFalse_emptyAuthorized_notNilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        
        model.sendClientInform(.emptyAuthorized_notNilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
        XCTAssertNotNil(sut)
    }
    
    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_emptyAuthorized_notNilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true
        
        model.sendClientInform(.emptyAuthorized_notNilNotAuthorized, timeout: 0.05)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Events: clientInform model property change: notEmptyAuthorized_nilNotAuthorized
    
    func test_clientInform_shouldNotChangeClientInformStatus_isShowNotAuthorizedFalse_notEmptyAuthorized_nilNotAuthorized() {
        
        let (_, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        
        model.sendClientInform(.notEmptyAuthorized_nilNotAuthorized)
        
        XCTAssertFalse(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNoDiff(model.clientInformStatus, clientInformStatus)
    }
    
    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_notEmptyAuthorized_nilNotAuthorized() {
        
        let (_, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true
        
        model.sendClientInform(.notEmptyAuthorized_nilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
    }
    
    // MARK: - Events: clientInform model property change: notEmptyAuthorized_notNilNotAuthorized
    
    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedFalse_notEmptyAuthorized_notNilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        
        model.sendClientInform(.notEmptyAuthorized_notNilNotAuthorized)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
        XCTAssertNotNil(sut)
    }
    
    func test_clientInform_shouldChangeClientInformStatus_isShowNotAuthorizedTrue_notEmptyAuthorized_notNilNotAuthorized() {
        
        let (sut, model) = makeSUT()
        let clientInformStatus = model.clientInformStatus
        model.clientInformStatus.isShowNotAuthorized = true
        
        model.sendClientInform(.notEmptyAuthorized_notNilNotAuthorized, timeout: 0.05)
        
        XCTAssertTrue(model.clientInformStatus.isShowNotAuthorized)
        XCTAssertNotEqual(model.clientInformStatus, clientInformStatus)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Events: Auth.CheckClient.Response
    
    func test_authCheckClientResponse_shouldHideSpinner_onResponseSuccess() {
        
        let (sut, model) = makeSUT()
        let spinnerSpy = ValueSpy(sut.hideSpinnerPublisher)
        
        XCTAssertTrue(spinnerSpy.values.isEmpty)
        
        model.checkClientSuccess(phone: "phone")
        
        XCTAssertFalse(spinnerSpy.values.isEmpty)
    }
    
    func test_authCheckClientResponse_shouldHideSpinner_onResponseFailure() {
        
        let (sut, model) = makeSUT()
        let spinnerSpy = ValueSpy(sut.hideSpinnerPublisher)
        
        XCTAssertTrue(spinnerSpy.values.isEmpty)
        
        model.checkClientFailure(message: "failure message")
        
        XCTAssertFalse(spinnerSpy.values.isEmpty)
    }
    
    func test_authCheckClientResponse_shouldSetLink_onResponseSuccess() {
        
        let (sut, model) = makeSUT()
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
        
        let (sut, model) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        
        XCTAssertNoDiff(alertSpy.values, [nil])
        
        model.checkClientFailure(message: "failure message")
        
        XCTAssertNoDiff(alertSpy.values, [
            nil,
            .alert(message: "failure message")
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Register
    
    func test_authLoginViewModelActionRegister_shouldCheckClient() {
        
        let (sut, model) = makeSUT()
        let checkClientSpy = ValueSpy(model.action.compactMap { $0 as? ModelAction.Auth.CheckClient.Request }.map(\.number))
        
        XCTAssertTrue(checkClientSpy.values.isEmpty)
        
        sut.register(cardNumber: "1234-5678")
        
        XCTAssertNoDiff(checkClientSpy.values, ["1234-5678"])
    }
    
    func test_authLoginViewModelActionRegister_shouldShowSpinner() {
        
        let (sut, _) = makeSUT()
        let spinnerSpy = ValueSpy(sut.showSpinnerPublisher)
        
        XCTAssertTrue(spinnerSpy.values.isEmpty)
        
        sut.register(cardNumber: "1234-5678")
        
        XCTAssertFalse(spinnerSpy.values.isEmpty)
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Show.Products
    
    func test_authLoginViewModelActionShowProducts_shouldSetLinkToProductsWithEmptyProductListOnEmptyModelCatalogProducts() {
        
        let (sut, model) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showProductsAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .products(titles: [])
        ])
        XCTAssertTrue(model.catalogProducts.value.isEmpty)
    }
    
    func test_authLoginViewModelActionShowProducts_shouldSetLinkToProductsWithProductListOnNonEmptyModelCatalogProducts() {
        
        let (sut, model) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        model.catalogProducts.send([.sample])
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showProductsAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .products(titles: ["Sample"])
        ])
        XCTAssertFalse(model.catalogProducts.value.isEmpty)
    }
    
    func test_authLoginViewModelActionShowProducts_shouldSetButtonToOrderSelectedProduct() throws {
        
        let (sut, model) = makeSUT()
        let orderProductSpy = ValueSpy(sut.orderProductPublisher)
        model.catalogProducts.send([.sample])
        
        sut.showProductsAndWait()
        
        XCTAssertTrue(orderProductSpy.values.isEmpty)
        
        sut.order(.sample)
        
        XCTAssertNoDiff(orderProductSpy.values, [.sample])
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Show.Transfers
    
    func test_authLoginViewModelActionShowTransfers_shouldSetLinkToTransfers() {
        
        let (sut, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showTransfersAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .transfers
        ])
    }
    
    func test_authLoginViewModelActionShowTransfers_shouldReceiveCloseLinkActionOnDirectionDetailOrderTap() {
        
        let (sut, _) = makeSUT()
        let closeLinkSpy = ValueSpy(sut.closeLinkPublisher)
        
        XCTAssertTrue(closeLinkSpy.values.isEmpty)
        
        sut.showTransfersAndWait()
        sut.orderDestination()
        
        XCTAssertFalse(closeLinkSpy.values.isEmpty)
    }
    
    func test_authLoginViewModelActionShowTransfers_shouldShowProductsOnDelay() {
        
        let (sut, _) = makeSUT()
        let showProductsSpy = ValueSpy(sut.showProductsPublisher)
        
        XCTAssertTrue(showProductsSpy.values.isEmpty)
        
        sut.showTransfersAndWait()
        sut.orderDestination()
        
        XCTAssertNoDiff(showProductsSpy.values, [])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 1)

        XCTAssertNoDiff(showProductsSpy.values, [.product])
    }
    
    func test_authLoginViewModelActionShowTransfers_shouldReceiveCloseLinkActionOnDirectionDetailTransfersTap() {
        
        let (sut, _) = makeSUT()
        let closeLinkSpy = ValueSpy(sut.closeLinkPublisher)
        
        XCTAssertTrue(closeLinkSpy.values.isEmpty)
        
        sut.showTransfersAndWait()
        sut.tapTransfer()
        
        XCTAssertFalse(closeLinkSpy.values.isEmpty)
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Show.Scaner
    
    func test_authLoginViewModelActionShowScanner_shouldSetCardScanner() {
        
        let (sut, _) = makeSUT()
        
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil])
        
        sut.showScanner()
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner])
    }
        
    func test_authLoginViewModelActionCloseScanner_shouldSetCardScannerToNil_nilScanValue() {
        
        let scanValue: String? = nil
        let (sut, _) = makeSUT()
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner, nil])
    }
        
    func test_authLoginViewModelActionCloseScanner_shouldSetCardScannerToNil_nonNilScanValue() {
        
        let scanValue: String? = "abc123"
        let (sut, _) = makeSUT()
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner, nil])
    }
        
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToNil_nilScanValue() {
        
        let scanValue: String? = nil
        let (sut, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, nil)
    }
        
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToEmpty_emptyScanValue() {
        
        let scanValue: String? = ""
        let (sut, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, "")
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToEmpty_invalidScanValue() {
        
        let scanValue: String? = "abc"
        let (sut, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, "")
    }
        
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToMasked_scanValueWithDigits() {
        
        let scanValue: String? = "abc12345"
        let (sut, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, "1234 5")
    }
        
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToMasked_validScanValue() {
        
        let scanValue: String? = "1234567812345678"
        let (sut, _) = makeSUT()
        
        sut.showScanner()
        sut.closeScanner(scanValue)
        
        XCTAssertNoDiff(sut.card.textField.text, "1234 5678 1234 5678")
    }
        
    // MARK: - Events: catalogProducts & transferAbroad
    
    func test_catalogProducts_transferAbroad_shouldChangeButtonsOnUpdate() {
        
        let (sut, model) = makeSUT()
        let buttonsSpy = ValueSpy(sut.$buttons.map { $0.map(\.view) })
        
        XCTAssertTrue(model.catalogProducts.value.isEmpty)
        XCTAssertNoDiff(buttonsSpy.values, [
            []
        ])
        
        model.catalogProducts.send(.sample)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(buttonsSpy.values, [
            [],
            [],
            [.orderCard]
        ])
        
        model.transferAbroad.send(.sample())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(buttonsSpy.values, [
            [],
            [],
            [.orderCard],
            [.transfer, .orderCard,]
        ])
    }
    
    // MARK: - Events: cardState & sessionState & fcmToken
    
    func test_cardState_sessionState_fcmToken_shouldChangeCardButton() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.card.$nextButton.map(\.?.icon))
        
        sut.card.state = .editing
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, nil, nil])
        
        sut.card.state = .ready("1234")
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, nil, nil, nil])
        
        model.sessionAgent.sessionState.send(.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy)))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, nil, nil, nil, nil])
        
        model.fcmToken.send(nil)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, nil, nil, nil, nil, nil])
        
        model.fcmToken.send("fcmToken")
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, nil, nil, nil, nil, nil, .ic24ArrowRight])
    }
    
    func test_cardState_shouldSetCardButton() {
        
        let (sut, model) = makeSUT()
        let spy = ValueSpy(sut.card.$nextButton.map(\.?.icon))
        
        model.fcmToken.send("fcmToken")
        sut.card.state = .ready("1234")
        model.sessionAgent.sessionState.send(.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy)))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(spy.values, [nil, nil, nil, nil, .ic24ArrowRight])
    }
    
    func test_cardState_shouldSendRegisterCardNumberOnCardNextButtonAction() {
        
        let (sut, model) = makeSUT()
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
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: AuthLoginViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = AuthLoginViewModel(model, rootActions: .emptyMock)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: return memory leak tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
}

// MARK: - DSL

private extension AuthLoginViewModel {
    
    // MARK: - Publishers
    
    var hideSpinnerPublisher: AnyPublisher<Void, Never> {
        
        action
            .compactMap {
                
                if case .spinner(.hide) = $0 {
                    return ()
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    var showSpinnerPublisher: AnyPublisher<Void, Never> {
        
        action
            .compactMap {
                
                if case .spinner(.show) = $0 {
                    return ()
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    var orderProductPublisher: AnyPublisher<CatalogProductData, Never> {
        
        action
            .compactMap { (action) -> CatalogProductData? in
                
                if case let .show(.orderProduct(catalogProductData)) = action {
                    return catalogProductData
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    var closeLinkPublisher: AnyPublisher<Void, Never> {
        
        action
            .compactMap {
                
                if case .closeLink = $0 {
                    return ()
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    var showProductsPublisher: AnyPublisher<Spy?, Never> {
        
        action
            .compactMap {
                
                if case .show(.products) = $0 {
                    return .product
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    var alertPublisher: AnyPublisher<Alert.ViewModel.View?, Never> {
        
        $alert
            .map(\.?.view)
            .eraseToAnyPublisher()
    }
    
    var registerCardNumber: AnyPublisher<String, Never> {
        
        action
            .compactMap {
                
                if case let .register(cardNumber: cardNumber) = $0 {
                    return cardNumber
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    var scannerPublisher: AnyPublisher<Spy?, Never> {
        
        $cardScanner.map {
            
            $0.map { _ in Spy.scanner } ?? nil
        }
        .eraseToAnyPublisher()
    }
    
    enum Spy: Equatable {
        
        case product
        case scanner
    }
    
    // MARK: - Properties
    
    var orderAuthButton: AuthProductsViewModel.ProductCardViewModel.OrderAuthButton? {
        
        link?
            .authProductsViewModel?
            .productCards.first?
            .orderButtonType
            .orderAuthButton
    }
    
    // MARK: - Actions
    
    func register(
        cardNumber: String,
        timeout: TimeInterval = 0.05
    ) {
        action.send(.register(cardNumber: cardNumber))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func showProductsAndWait(timeout: TimeInterval = 0.05) {
        
        showProducts()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func showTransfersAndWait(timeout: TimeInterval = 0.05) {
        
        showTransfers()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func showScanner(timeout: TimeInterval = 0.05) {
        
        action.send(.show(.scanner))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func closeScanner(
        _ scanValue: String?,
        timeout: TimeInterval = 0.05
    ) {
        cardScanner?.closeAction(scanValue)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
    }
    
    func order(
        _ productData: CatalogProductData,
        timeout: TimeInterval = 0.05
    ) {
        orderAuthButton?.action(productData.id)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func orderDestination(timeout: TimeInterval = 0.05) {
        
        let order = AuthTransfersAction.transfersSection(.order)
        link?.authTransfersViewModel?.action.send(order)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func tapTransfer(timeout: TimeInterval = 0.05) {
        
        let transfers = AuthTransfersAction.transfersSection(.transfers)
        link?.authTransfersViewModel?.action.send(transfers)
        
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

// MARK: - Helpers

private extension ClientInformData {
    
    static let emptyAuthorized_nilNotAuthorized: Self = .init(serial: "serial", authorized: [], notAuthorized: nil)
    static let emptyAuthorized_notNilNotAuthorized: Self = .init(serial: "serial", authorized: [], notAuthorized: "notAuthorized")
    static let notEmptyAuthorized_nilNotAuthorized: Self = .init(serial: "serial", authorized: ["authorized"], notAuthorized: nil)
    static let notEmptyAuthorized_notNilNotAuthorized: Self = .init(serial: "serial", authorized: ["authorized"], notAuthorized: "notAuthorized")
}

private extension AuthLoginViewModel.Link {
    
    var authProductsViewModel: AuthProductsViewModel? {
        
        if case let .products(authProductsViewModel) = self {
            return authProductsViewModel
        } else {
            return nil
        }
    }
    
    var authTransfersViewModel: AuthTransfersViewModel? {
        
        if case let .transfers(authTransfersViewModel) = self {
            return authTransfersViewModel
        } else {
            return nil
        }
    }
    
    var `case`: Case {
        
        switch self {
        case let .confirm(viewModel):
            return .confirm(viewModel.view)

        case .transfers:
            return .transfers

        case let .products(viewModel):
            return .products(titles: viewModel.productCards.map(\.title))
        }
    }
    
    enum Case: Equatable {
        
        case confirm(AuthConfirmViewModel.View)
        case transfers
        case products(titles: [String])
    }
}

private extension AuthConfirmViewModel {
    
    var view: View {
        
        .init(
            codeTitle: code.title,
            codeLength: code.codeLenght,
            infoTitle: info?.title
        )
    }
    
    struct View: Equatable {
        
        let codeTitle: String
        let codeLength: Int
        let infoTitle: String?
    }
}

private extension Alert.ViewModel {
    
    var view: View {
        
        .init(
            title: title,
            message: message,
            primary: .init(
                kind: primary.type.kind,
                title: primary.title
            ),
            secondary: secondary.map {
                .init(
                    kind: $0.type.kind,
                    title: $0.title
                )
            }
        )
    }
    
    struct View: Equatable {
        
        let title: String
        let message: String?
        let primary: ButtonViewModel
        let secondary: ButtonViewModel?
        
        struct ButtonViewModel: Equatable {
            
            let kind: Kind
            let title: String
            
            enum Kind {
                
                case `default`
                case distructive
                case cancel
            }
            
            static let `default`: Self = .init(kind: .default, title: "Ok")
        }
        
        static func alert(
            title: String = "Ошибка",
            message: String,
            primary: ButtonViewModel = .default,
            secondary: ButtonViewModel? = nil
        ) -> Self {
            
            .init(title: title, message: message, primary: primary, secondary: secondary)
        }
    }
}

private extension Alert.ViewModel.ButtonViewModel.Kind {
    
    var kind: Alert.ViewModel.View.ButtonViewModel.Kind {
        
        switch self {
            
        case .default:     return .default
        case .distructive: return .distructive
        case .cancel:      return .cancel
        }
    }
}

private extension Array where Element == CatalogProductData {
    
    static let sample: Self = [
        .sample
    ]
}

extension CatalogProductData {
    
    static let sample: Self = .init(
        name: "Sample",
        description: ["Sample", "Product"],
        imageEndpoint: "",
        infoURL: .init(string: "infoURL")!,
        orderURL: .init(string: "orderURL")!,
        tariff: 1,
        productType: 1
    )
}

private extension AuthProductsViewModel.ProductCardViewModel.OrderButtonType {
    
    var orderAuthButton: AuthProductsViewModel.ProductCardViewModel.OrderAuthButton? {
        
        if case let .auth(orderAuthButton) = self {
            return orderAuthButton
        } else {
            return nil
        }
    }
}

private extension ButtonAuthView.ViewModel {
    
    var view: View {
        
        .init(
            id: id,
            title: title,
            subTitle: subTitle
        )
    }
    
    struct View: Equatable {
        
        let id: ButtonAuthView.ViewModel.ButtonType
        let title: String
        let subTitle: String
    }
}

private extension ButtonAuthView.ViewModel.View {
    
    static let orderCard: Self = .init(
        id: .card,
        title: "Нет карты?",
        subTitle: "Доставим в любую точку"
    )
    static let transfer: Self = .init(
        id: .abroad,
        title: "Переводы за рубеж",
        subTitle: "Быстро и безопасно"
    )
}

private extension TransferAbroadResponseData {
    
    static func sample(
        serial: String = "serial-123",
        main: MainTransferData = .sample(),
        directionsDetailList: [DirectionDetailData] = [],
        bannersDetailList: [BannerDetailData] = [],
        countriesDetailList: CountryDetailData = .sample()
    ) -> Self {
        
        .init(
            serial: serial,
            main: main,
            directionsDetailList: directionsDetailList,
            bannersDetailList: bannersDetailList,
            countriesDetailList: countriesDetailList
        )
    }
}

private extension TransferAbroadResponseData.MainTransferData {
    
    static func sample(
        title: String = "title",
        subTitle: String = "subTitle",
        legalTitle: String = "legalTitle",
        promotion: [TransferAbroadResponseData.PromotionTransferData] = [],
        directions: TransferAbroadResponseData.DirectionTransferData = .sample(),
        bannerCatalogList: [BannerCatalogListData] = [],
        info: TransferAbroadResponseData.InfoTransferData = .sample(),
        countriesList: TransferAbroadResponseData.CountriesListData = .sample(),
        advantages: TransferAbroadResponseData.AdvantageTransferData = .sample(),
        questions: TransferAbroadResponseData.QuestionTransferData = .sample(),
        support: TransferAbroadResponseData.SupportTransferData = .sample()
    ) -> Self {
        
        .init(
            title: title,
            subTitle: subTitle,
            legalTitle: legalTitle,
            promotion: promotion,
            directions: directions,
            bannerCatalogList: bannerCatalogList,
            info: info,
            countriesList: countriesList,
            advantages: advantages,
            questions: questions,
            support: support
        )
    }
}

private extension TransferAbroadResponseData.CountryDetailData {
    
    static func sample(
        title: String = "title",
        codeList: [String] = ["code"]
    ) -> Self {
        
        .init(
            title: title,
            codeList: codeList
        )
    }
}

private extension TransferAbroadResponseData.DirectionTransferData {
    
    static func sample(
        title: String = "title",
        countriesList: [CountriesList] = []
    ) -> Self {
        
        .init(
            title: title,
            countriesList: countriesList
        )
    }
}

private extension TransferAbroadResponseData.InfoTransferData {
    
    static func sample(
        md5hash: String = "md5hash",
        title: String = "title"
    ) -> Self {
        
        .init(
            md5hash: md5hash,
            title: title
        )
    }
}

private extension TransferAbroadResponseData.CountriesListData {
    
    static func sample(
        title: String = "title",
        codeList: [String] = ["code"]
    ) -> Self {
        
        .init(
            title: title,
            codeList: codeList
        )
    }
}

private extension TransferAbroadResponseData.AdvantageTransferData {
    
    static func sample(
        title: String = "title",
        content: [ContentData] = []
    ) -> Self {
        
        .init(
            title: title,
            content: content
        )
    }
}

private extension TransferAbroadResponseData.QuestionTransferData {
    
    static func sample(
        title: String = "title",
        content: [ContentData] = []
    ) -> Self {
        
        .init(
            title: title,
            content: content
        )
    }
}

private extension TransferAbroadResponseData.SupportTransferData {
    
    static func sample(
        title: String = "title",
        content: [ContentData] = []
    ) -> Self {
        
        .init(
            title: title,
            content: content
        )
    }
}
