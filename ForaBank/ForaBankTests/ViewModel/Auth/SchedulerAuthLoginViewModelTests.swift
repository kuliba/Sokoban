//
//  SchedulerAuthLoginViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.09.2023.
//

import Combine
@testable import ForaBank
import SwiftUI
import XCTest

final class SchedulerAuthLoginViewModelTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetHeader() {
        
        let (sut, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNoDiff(sut.header.title, "Войти")
        XCTAssertNoDiff(sut.header.subTitle, "чтобы получить доступ к счетам и картам")
        XCTAssertNoDiff(sut.header.icon, .ic16ArrowDown)
    }
    
    func test_init_shouldSetLinkToNil() {
        
        let (sut, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNil(sut.link)
    }
    
    func test_init_shouldSetBottomSheetToNil() {
        
        let (sut, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNil(sut.bottomSheet)
    }
    
    func test_init_shouldSetCardScannerToNil() {
        
        let (sut, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNil(sut.cardScanner)
    }
    
    func test_init_shouldSetAlertToNil() {
        
        let (sut, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertNil(sut.alert)
    }
    
    func test_init_shouldSetButtonsToEmpty() {
        
        let (sut, _, _, _, _, _, _) = makeSUT()
        
        XCTAssertTrue(sut.buttons.isEmpty)
    }
    
    // MARK: - Events: clientInform
    
    func test_clientInform_shouldShowClientInformAlertWithMesssage() {
        
        let message = "message"
        let (sut, scheduler, clientInformMessage, _, _, _, _) = makeSUT()
        let spy = ValueSpy(sut.alertPublisher)
        
        clientInformMessage.send(message)
        XCTAssertNoDiff(spy.values, [nil])
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [nil, .alert(message: message)])
    }
    
    // MARK: - Events: Auth.CheckClient.Response
    
    func test_authCheckClientResponse_shouldHideSpinner_onResponseSuccess() {
        
        let (sut, scheduler, _, checkClientResponse, _, _, _) = makeSUT()
        let spinnerSpy = ValueSpy(sut.hideSpinnerPublisher)
        
        checkClientResponse.send(.success(codeLength: 1, phone: "123-456", resendCodeDelay: 1))
        XCTAssertTrue(spinnerSpy.values.isEmpty)
        
        scheduler.advance()
        
        XCTAssertFalse(spinnerSpy.values.isEmpty)
    }
    
    func test_authCheckClientResponse_shouldHideSpinner_onResponseFailure() {
        
        let message = "message"
        let (sut, scheduler, _, checkClientResponse, _, _, _) = makeSUT()
        let spinnerSpy = ValueSpy(sut.hideSpinnerPublisher)
        
        checkClientResponse.send(.failure(message: message))
        XCTAssertTrue(spinnerSpy.values.isEmpty)
        
        scheduler.advance()
        
        XCTAssertFalse(spinnerSpy.values.isEmpty)
    }
    
    func test_authCheckClientResponse_shouldSetLink_onResponseSuccess() {
        
        let (sut, scheduler, _, checkClientResponse, _, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        
        checkClientResponse.send(.success(codeLength: 1, phone: "123-456", resendCodeDelay: 1))
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        scheduler.advance()
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .confirm(.init(
                codeTitle: "Введите код из сообщения",
                codeLength: 1,
                infoTitle: "123-456"
            ))
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_authCheckClientResponse_shouldSetAlert_onResponseFailure() {
        
        let message = "failure message"
        let (sut, scheduler, _, checkClientResponse, _, _, _) = makeSUT()
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        
        checkClientResponse.send(.failure(message: message))
        XCTAssertNoDiff(alertSpy.values, [nil])
        
        scheduler.advance()
        
        XCTAssertNoDiff(alertSpy.values, [
            nil,
            .alert(message: message)
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Register
    
    func test_authLoginViewModelActionRegister_shouldCheckClient() {
        
        let (sut, scheduler, _, _, _, _, registerCardNumberSpy) = makeSUT()
        
        XCTAssertTrue(registerCardNumberSpy.values.isEmpty)
        
        sut.register(cardNumber: "1234-5678", on: scheduler)
        
        XCTAssertNoDiff(registerCardNumberSpy.values, ["1234-5678"])
    }
    
    func test_authLoginViewModelActionRegister_shouldShowSpinner() {
        
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        let spinnerSpy = ValueSpy(sut.showSpinnerPublisher)
        
        XCTAssertTrue(spinnerSpy.values.isEmpty)
        
        sut.register(cardNumber: "1234-5678", on: scheduler)
        
        XCTAssertFalse(spinnerSpy.values.isEmpty)
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Show.Products
    
    func test_authLoginViewModelActionShowProducts_shouldSetLinkToProductsWithEmptyProductListOnEmptyModelCatalogProducts() {
        
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showProductsAndWait(on: scheduler)
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .products(titles: [])
        ])
        //XCTAssertTrue(model.catalogProducts.value.isEmpty)
    }
    
    func test_authLoginViewModelActionShowProducts_shouldSetLinkToProductsWithProductListOnNonEmptyModelCatalogProducts() {
        
        let (sut, scheduler, _, _, _, _, _) = makeSUT(catalogProductDataStub: .sample)
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showProductsAndWait(on: scheduler)
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .products(titles: ["Sample"])
        ])
    }
    
    func test_authLoginViewModelActionShowProducts_shouldSetButtonToOrderSelectedProduct() throws {
        
        let (sut, scheduler, _, _, _, _, _) = makeSUT(catalogProductDataStub: .sample)
        let orderProductSpy = ValueSpy(sut.orderProductPublisher)
        
        sut.showProductsAndWait(on: scheduler)
        
        XCTAssertTrue(orderProductSpy.values.isEmpty)
        
        sut.order(.sample, on: scheduler)
        
        XCTAssertNoDiff(orderProductSpy.values, [.sample])
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Show.Transfers
    
    func test_authLoginViewModelActionShowTransfers_shouldSetLinkToTransfers() {
        
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showTransfersAndWait(on: scheduler)
        
        XCTAssertNoDiff(linkSpy.values, [
            nil,
            .transfers
        ])
    }
    
    func test_authLoginViewModelActionShowTransfers_shouldReceiveCloseLinkActionOnDirectionDetailOrderTap() {
        
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        let closeLinkSpy = ValueSpy(sut.closeLinkPublisher)
        
        XCTAssertTrue(closeLinkSpy.values.isEmpty)
        
        sut.showTransfersAndWait(on: scheduler)
        sut.orderDestination(on: scheduler)

        scheduler.advance(by: 1)
        XCTAssertFalse(closeLinkSpy.values.isEmpty)
    }
    
    func test_authLoginViewModelActionShowTransfers_shouldShowProductsOnDelay() {
        
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        let showProductsSpy = ValueSpy(sut.showProductsPublisher)
        
        XCTAssertTrue(showProductsSpy.values.isEmpty)
        
        sut.showTransfersAndWait(on: scheduler)
        sut.orderDestination(on: scheduler)
                
        scheduler.advance(by: 1)
        XCTAssertNoDiff(showProductsSpy.values, [.product])
    }
    
    func test_authLoginViewModelActionShowTransfers_shouldReceiveCloseLinkActionOnDirectionDetailTransfersTap() {
        
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        let closeLinkSpy = ValueSpy(sut.closeLinkPublisher)
        
        XCTAssertTrue(closeLinkSpy.values.isEmpty)
        
        sut.showTransfersAndWait(on: scheduler)
        sut.tapTransfer(on: scheduler)
        
        XCTAssertFalse(closeLinkSpy.values.isEmpty)
    }
    
    // MARK: - Events: AuthLoginViewModelAction.Show.Scaner
    
    func test_authLoginViewModelActionShowScanner_shouldSetCardScanner() {
        
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil])
        
        sut.showScanner(on: scheduler)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner])
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardScannerToNil_nilScanValue() {
        
        let scanValue: String? = nil
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)
        
        sut.showScanner(on: scheduler)
        sut.closeScanner(scanValue, on: scheduler)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner, nil])
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardScannerToNil_nonNilScanValue() {
        
        let scanValue: String? = "abc123"
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        let cardScannerSpy = ValueSpy(sut.scannerPublisher)
        
        sut.showScanner(on: scheduler)
        sut.closeScanner(scanValue, on: scheduler)
        
        XCTAssertNoDiff(cardScannerSpy.values, [nil, .scanner, nil])
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToNil_nilScanValue() {
        
        let scanValue: String? = nil
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        
        sut.showScanner(on: scheduler)
        sut.closeScanner(scanValue, on: scheduler)
        
        XCTAssertNoDiff(sut.card.textField.text, nil)
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToEmpty_emptyScanValue() {
        
        let scanValue: String? = ""
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        
        sut.showScanner(on: scheduler)
        sut.closeScanner(scanValue, on: scheduler)
        
        XCTAssertNoDiff(sut.card.textField.text, "")
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToEmpty_invalidScanValue() {
        
        let scanValue: String? = "abc"
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        
        sut.showScanner(on: scheduler)
        sut.closeScanner(scanValue, on: scheduler)
        
        XCTAssertNoDiff(sut.card.textField.text, "")
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToMasked_scanValueWithDigits() {
        
        let scanValue: String? = "abc12345"
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        
        sut.showScanner(on: scheduler)
        sut.closeScanner(scanValue, on: scheduler)
        
        XCTAssertNoDiff(sut.card.textField.text, "1234 5")
    }
    
    func test_authLoginViewModelActionCloseScanner_shouldSetCardTextToMasked_validScanValue() {
        
        let scanValue: String? = "1234567812345678"
        let (sut, scheduler, _, _, _, _, _) = makeSUT()
        
        sut.showScanner(on: scheduler)
        sut.closeScanner(scanValue, on: scheduler)
        
        XCTAssertNoDiff(sut.card.textField.text, "1234 5678 1234 5678")
    }
    
    // MARK: - Events: catalogProducts & transferAbroad
    
    func test_catalogProducts_transferAbroad_shouldChangeButtonsOnUpdate() {
        
        let (sut, scheduler, _, _, catalogProductsTransferAbroad, _, _) = makeSUT(catalogProductDataStub: .sample)
        let buttonsSpy = ValueSpy(sut.$buttons.map { $0.map(\.view) })
        
        XCTAssertNoDiff(buttonsSpy.values, [
            []
        ])
        
        catalogProductsTransferAbroad.send((.sample, nil))
        scheduler.advance()
        
        XCTAssertNoDiff(buttonsSpy.values, [
            [],
            [.orderCard]
        ])
        
        catalogProductsTransferAbroad.send((.sample, .sample()))
        scheduler.advance()
        
        XCTAssertNoDiff(buttonsSpy.values, [
            [],
            [.orderCard],
            [.transfer, .orderCard,]
        ])
    }
    
    // MARK: - Events: cardState & sessionState & fcmToken
    
    func test_cardState_sessionState_fcmToken_shouldChangeCardButton() {
        
        let (sut, scheduler, _, _, _, sessionStateFcmToken, _) = makeSUT()
        let spy = ValueSpy(sut.card.$nextButton.map(\.?.icon))
        
        sut.card.state = .editing
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [nil])
        
        sut.card.state = .ready("1234")
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [nil])
        
        sessionStateFcmToken.send(((.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy))), nil))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [nil, nil])
        
        sessionStateFcmToken.send(((.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy))), "fcmToken"))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [nil, nil, .ic24ArrowRight])
    }
    
    func test_cardState_shouldSetCardButton() {
        
        let (sut, scheduler, _, _, _, sessionStateFcmToken, _) = makeSUT()
        let spy = ValueSpy(sut.card.$nextButton.map(\.?.icon))
        
        sessionStateFcmToken.send(((.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy))), "fcmToken"))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [nil, nil])
        
        sut.card.state = .ready("1234")
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [nil, nil, .ic24ArrowRight])
    }
    
    func test_cardState_shouldSendRegisterCardNumberOnCardNextButtonAction() {
        
        let (sut, scheduler, _, _, _, sessionStateFcmToken, _) = makeSUT()
        let spy = ValueSpy(sut.registerCardNumber)
        
        XCTAssertNil(sut.card.nextButton)
        
        sessionStateFcmToken.send(((.active(start: 0, credentials: .init(token: "abc", csrfAgent: CSRFAgentDummy.dummy))), "fcmToken"))
        sut.card.state = .ready("1234")
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [])
        
        sut.card.nextButton?.action()
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, ["1234"])
    }
    
    // MARK: - Helpers
    
    typealias ClientInformMessage = PassthroughSubject<String, Never>
    typealias CheckClientResponse = PassthroughSubject<ModelAction.Auth.CheckClient.Response, Never>
    typealias CatalogProductsTransferAbroad = PassthroughSubject<([CatalogProductData], TransferAbroadResponseData?), Never>
    typealias SessionStateFcmToken = PassthroughSubject<(SessionState, String?), Never>
    
    private func makeSUT(
        catalogProductDataStub: CatalogProductData? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: AuthLoginViewModel,
        scheduler: TestSchedulerOfDispatchQueue,
        clientInformMessage: ClientInformMessage,
        checkClientResponse: CheckClientResponse,
        catalogProductsTransferAbroad: CatalogProductsTransferAbroad,
        sessionStateFcmToken: SessionStateFcmToken,
        registerCardNumberSpy: RegisterCardNumberSpy
    ) {
        let clientInformMessage = ClientInformMessage()
        let checkClientResponse = CheckClientResponse()
        let catalogProductsTransferAbroad = CatalogProductsTransferAbroad()
        let sessionStateFcmToken = SessionStateFcmToken()
        
        let eventPublishers = AuthLoginViewModel.EventPublishers(
            clientInformMessage: clientInformMessage.eraseToAnyPublisher(),
            checkClientResponse: checkClientResponse.eraseToAnyPublisher(),
            catalogProductsTransferAbroad: catalogProductsTransferAbroad.eraseToAnyPublisher(),
            sessionStateFcmToken: sessionStateFcmToken.eraseToAnyPublisher()
        )
        
        let registerCardNumberSpy = RegisterCardNumberSpy()
        
        let eventHandlers = AuthLoginViewModel.EventHandlers(
            onRegisterCardNumber: registerCardNumberSpy.registerCardNumber,
            catalogProductForID: { _ in catalogProductDataStub }
        )
        
        let factory = AuthLoginViewModelFactorySpy(
            products: [catalogProductDataStub].compactMap { $0 }
        )
        
        let scheduler = DispatchQueue.test
        
        let sut = AuthLoginViewModel(
            eventPublishers: eventPublishers,
            eventHandlers: eventHandlers,
            factory: factory,
            rootActions: .emptyMock,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, scheduler, clientInformMessage, checkClientResponse, catalogProductsTransferAbroad, sessionStateFcmToken, registerCardNumberSpy)
    }
    
    private final class RegisterCardNumberSpy {
        
        private(set) var values = [String]()
        
        func registerCardNumber(_ cardNumber: String) {
            
            values.append(cardNumber)
        }
    }
    
    private final class AuthLoginViewModelFactorySpy: AuthLoginViewModelFactory {
        
        private let products: [CatalogProductData]
        
        init(products: [CatalogProductData]) {
            
            self.products = products
        }
        
        func makeAuthConfirmViewModel(
            confirmCodeLength: Int,
            phoneNumber: String,
            resendCodeDelay: TimeInterval,
            backAction: @escaping () -> Void,
            rootActions: RootViewModel.RootActions
        ) -> AuthConfirmViewModel {
            
            let codeViewModel = AuthConfirmViewModel.CodeViewModel(
                title: "Введите код из сообщения",
                lenght: confirmCodeLength,
                state: .openening
            )
            let infoViewModel = AuthConfirmViewModel.InfoViewModel(
                title: phoneNumber,
                subtitle: "Повторно отправить можно через:",
                state: .button(.init(action: {}))
            )
            
            return .init(
                navigationBar: .init(action: backAction),
                code: codeViewModel,
                info: infoViewModel,
                isPincodeViewPresented: false,
                model: .emptyMock,
                showingAlert: false,
                phoneNumber: phoneNumber,
                resendCodeDelay: resendCodeDelay,
                backAction: {},
                rootActions: .emptyMock
            )
        }
        
        func makeAuthProductsViewModel(
            action: @escaping (Int) -> Void,
            dismissAction: @escaping () -> Void
        ) -> AuthProductsViewModel {
            
            .init(.emptyMock, products: products, action: action, dismissAction: dismissAction)
        }
        
        func makeAuthTransfersViewModel(
            closeAction: @escaping () -> Void
        ) -> AuthTransfersViewModel {
            
            .sample
        }
        
        func makeOrderProductViewModel(
            productData: CatalogProductData
        ) -> OrderProductView.ViewModel {
            
            .init(.mockWithEmptyExcept(), productData: .sample)
        }
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
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        action.send(.register(cardNumber: cardNumber))
        scheduler.advance()
    }
    
    func showProductsAndWait(
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        showProducts()
        scheduler.advance()
    }
    
    func showTransfersAndWait(
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        showTransfers()
        scheduler.advance()
    }
    
    func showScanner(
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        action.send(.show(.scanner))
        scheduler.advance()
    }
    
    func closeScanner(
        _ scanValue: String?,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        cardScanner?.closeAction(scanValue)
        scheduler.advance()
    }
    
    func order(
        _ productData: CatalogProductData,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        orderAuthButton?.action(productData.id)
        scheduler.advance()
    }
    
    func orderDestination(
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        link?.authTransfersViewModel?.action.send(
            .transfersSection(.order)
        )
        scheduler.advance()
    }
    
    func tapTransfer(
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        link?.authTransfersViewModel?.action.send(
            .transfersSection(.transfers)
        )
        scheduler.advance()
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
