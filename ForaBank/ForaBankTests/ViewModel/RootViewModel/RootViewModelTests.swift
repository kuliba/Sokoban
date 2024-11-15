//
//  RootViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 23.09.2023.
//

@testable import ForaBank
import CombineSchedulers
import LandingUIComponent
import SberQR
import XCTest

final class RootViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialValues() {
        
        let (sut, _,_,_) = makeSUT()
        
        XCTAssertNoDiff(sut.selected, .main)
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.link)
        XCTAssertNil(sut.coverPresented)
    }
    
    func test_resetLink_shouldSetLinkToNil() {
        
        let (sut, model, linkSpy, _) = makeSUT()
        model.sendC2bDeepLink(timeout: 0.31)
        
        XCTAssertNoDiff(linkSpy.values, [nil, .payments])
        
        sut.resetLink()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .payments, nil])
    }
    
    // MARK: - DeepLink
    
    func test_deepLink_c2b_shouldSetLinkToPayments() {
        
        let (sut, model, linkSpy, _) = makeSUT()
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        model.sendC2bDeepLink(timeout: 0.31)
        
        XCTAssertNoDiff(linkSpy.values, [nil, .payments])
        XCTAssertNotNil(sut)
    }
    
    func test_deepLink_c2bSubscribe_shouldSetLinkToPayments() {
        
        let (sut, model, linkSpy, _) = makeSUT()
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        model.sendC2bSubscribeDeepLink()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .payments])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - ModelAction.Notification.Transition.Process
    
    func test_transition_history_shouldSetLinkToMessages() {
        
        let (sut, model, linkSpy, _) = makeSUT()
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        model.sendTransitionHistory(timeout: 1)
        
        XCTAssertNoDiff(linkSpy.values, [nil, .messages])
        XCTAssertNotNil(sut)
    }
    
    // TODO: restore after fix of sigletons in AppDelegate.swift:17
    //    func test_transition_me2me_shouldSetLinkToMessages() {
    //
    //        let (sut, model, linkSpy, _) = makeSUT()
    //
    //        XCTAssertNoDiff(linkSpy.values, [nil])
    //
    //        model.sendTransitionMe2me()
    //
    //        XCTAssertNoDiff(linkSpy.values, [nil, .me2me])
    //        XCTAssertNotNil(sut)
    //    }
    
    // MARK: - ModelAction.Consent.Me2MeDebit.Response
    
    // TODO: restore after fix of sigletons in AppDelegate.swift:17
    //    func test_consent_me2MeDebit_shouldSetLinkToMeToMe() {
    //
    //        let (sut, model, linkSpy, _) = makeSUT()
    //
    //        XCTAssertNoDiff(linkSpy.values, [nil])
    //
    //        model.sendConsentMe2MeDebit(timeout: 0.35)
    //
    //        XCTAssertNoDiff(linkSpy.values, [nil, .me2me])
    //        XCTAssertNotNil(sut)
    //        _ = model
    //    }
    
    // MARK: - ShowUserProfile
    
    func test_showUserProfile_shouldSetLinkToUserAccount_onNonNilClientInfo() {
        
        let (sut, model, linkSpy, _) = makeSUT()
        model.clientInfo.value = .sample
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showUserProfile()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .userAccount])
        XCTAssertNotNil(model.clientInfo.value)
    }
    
    func test_showUserProfile_shouldNotSetLinkToUserAccount_onNilClientInfo() {
        
        let (sut, model, linkSpy, _) = makeSUT()
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.showUserProfile()
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        XCTAssertNil(model.clientInfo.value)
    }
    
    // MARK: - CloseLink
    
    func test_closeLink_shouldSetLinkToNil() {
        
        let (sut, model, linkSpy, _) = makeSUT()
        model.sendTransitionHistory(timeout: 1)
        XCTAssertNoDiff(linkSpy.values, [nil, .messages])
        
        sut.closeLink()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .messages, nil])
    }
    
    // MARK: - AppVersion
    
    func test_appVersion_shouldSetAlert_onSuccessNewVersion() {
        
        let (sut, model, _, alertSpy) = makeSUT()
        XCTAssertNoDiff(alertSpy.values, [nil])
        
        model.sendAppVersion(version: "2")
        
        XCTAssertNoDiff(alertSpy.values, [nil, .newVersion])
        XCTAssertNotNil(sut)
    }
    
    func test_appVersion_shouldNotSetAlert_onSuccessOldVersion() {
        
        let (sut, model, _, alertSpy) = makeSUT()
        XCTAssertNoDiff(alertSpy.values, [nil])
        
        model.sendAppVersion(version: "0")
        
        XCTAssertNoDiff(alertSpy.values, [nil])
        XCTAssertNotNil(sut)
    }
    
    func test_appVersion_shouldNotSetAlert_onSuccessNilInfo() {
        
        let (sut, model, _, alertSpy) = makeSUT(appVersion: nil)
        XCTAssertNoDiff(alertSpy.values, [nil])
        
        model.sendAppVersion(version: "0")
        
        XCTAssertNoDiff(alertSpy.values, [nil])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - CloseAlert
    
    func test_closeAlert_shouldSetAlertToNil() {
        
        let (sut, model, _, alertSpy) = makeSUT()
        model.sendAppVersion(version: "2")
        XCTAssertNoDiff(alertSpy.values, [nil, .newVersion])
        
        sut.closeAlert()
        
        XCTAssertNoDiff(alertSpy.values, [nil, .newVersion, nil])
    }
    
    // MARK: - OpenCard

    func test_openCard_shouldSetLinkToOpenCard() {
        
        let (sut, model, linkSpy, _) = makeSUT()
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.openCard()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .openCard])
    }
    
    // MARK: - OrderSticker

    func test_orderSticker_noCard_shouldSetAlertToNeedOrderCard() {
        
        let (sut, _, _, alertSpy) = makeSUT()
        
        XCTAssertNoDiff(alertSpy.values, [nil])
        
        sut.orderSticker()
        
        XCTAssertNoDiff(alertSpy.values, [nil, .needOrderCard])
    }
    
    func test_orderSticker_onlyCorporateCard_shouldSetAlertToDisableForCorporateCard() {
        
        let (sut, _, _, alertSpy) = makeSUT(
            product: makeCardProduct(cardType: .individualBusinessman), selected: .market)
        
        XCTAssertNoDiff(alertSpy.values, [nil])
        
        sut.orderSticker()
        
        XCTAssertNoDiff(alertSpy.values, [nil, .disableForCorporateCard])
    }

    func test_orderSticker_withCard_shouldSetLinkToPaymentSticker() {
        
        let (sut, scheduler, linkSpy, _) = makeSUT(product: .cardActiveMainDebitOnlyRub, selected: .market)
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.orderSticker()
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(linkSpy.values, [nil, .paymentSticker])
    }

    // MARK: - OpenOrderCard

    func test_openOrderCard_shouldSetLinkToOpenCard() {
        
        let (sut, scheduler, linkSpy, _) = makeSUT(product: .cardActiveMainDebitOnlyRub, selected: .market)
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.openOrderCard()
        scheduler.advance(by: .milliseconds(100))

        XCTAssertNoDiff(linkSpy.values, [nil, .openCard])
    }
    
    // MARK: - handleOutside

    func test_handleOutside_landing_shouldSetLinkToLanding() {
        
        let (sut, scheduler, linkSpy, _) = makeSUT(product: .cardActiveMainDebitOnlyRub, selected: .main)
        let type = anyMessage()
        
        sut.selected = .market
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.handleOutside(.landing(type))
        scheduler.advance(by: .milliseconds(310))
        
        XCTAssertNoDiff(linkSpy.values, [nil, .landing])
        
        sut.resetLink()
    }
    
    func test_handleOutside_goToMain_shouldSetSelectedToMain() {
        
        let (sut, _, _, _) = makeSUT(product: .cardActiveMainDebitOnlyRub, selected: .market)
        
        sut.handleOutside(.main)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)
        
        XCTAssertNil(sut.link)
        XCTAssertNoDiff(sut.selected, .main)
    }

    // MARK: - cardAction

    func test_handleOutside_landing_cardActionGoToMain_shouldSelectedToMain() {
        
        let (sut, scheduler, linkSpy, _) = makeSUT(product: .cardActiveMainDebitOnlyRub, selected: .market)
        let type = anyMessage()
        
        sut.handleOutside(.landing(type))
        scheduler.advance(by: .milliseconds(310))
        sut.landingViewModel?.action(.card(.goToMain))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)

        XCTAssertNoDiff(linkSpy.values, [nil, .landing, nil])
        XCTAssertNoDiff(sut.selected, .main)
    }
    
    // MARK: - stickerAction

    func test_handleOutside_landing_stickerActionGoToMain_shouldSelectedToMain() {

        let (sut, scheduler, linkSpy, _) = makeSUT(product: .cardActiveMainDebitOnlyRub, selected: .market)
        let type = anyMessage()
        
        sut.handleOutside(.landing(type))
        scheduler.advance(by: .milliseconds(310))
        
        sut.landingViewModel?.action(.sticker(.goToMain))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)

        XCTAssertNoDiff(linkSpy.values, [nil, .landing, nil])

        XCTAssertNoDiff(sut.selected, .main)
    }

    func test_handleOutside_landing_stickerActionOrder_shouldLinkToPaymentSticker() {

        let (sut, scheduler, linkSpy, _) = makeSUT(product: .cardActiveMainDebitOnlyRub, selected: .market)
        let type = anyMessage()
        
        XCTAssertNoDiff(linkSpy.values, [nil])

        sut.handleOutside(.landing(type))
        scheduler.advance(by: .milliseconds(400))

        sut.landingViewModel?.action(.sticker(.order))
        scheduler.advance(by: .milliseconds(400))

        XCTAssertNoDiff(linkSpy.values, [nil, .landing, .paymentSticker])
    }

    // MARK: - goToBack
    
    func test_handleOutside_landing_goToBack_shouldSelectedToBack() {
        
        let (sut, scheduler, _, _) = makeSUT(product: .cardActiveMainDebitOnlyRub, selected: .market)
        let type = anyMessage()
        
        sut.handleOutside(.landing(type))
        scheduler.advance(by: .milliseconds(400))

        sut.landingViewModel?.action(.goToBack)
        
        XCTAssertNil(sut.link)
        XCTAssertNoDiff(sut.selected, .market)
    }
    
    // MARK: - openPayment

    func test_openPayment_housingAndCommumalService_shouldSelectedPayment() {
        
        let (sut, _, linkSpy, _) = makeSUT(product: .cardActiveMainDebitOnlyRub, selected: .market)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        sut.openPayment(.housingAndCommumalService)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertNoDiff(linkSpy.values, [nil])
        XCTAssertNoDiff(sut.selected, .payments)
    }

    func test_openPayment_housingAndCommumalService_onlyCorporate_shouldShowAlertDisableForCorporateCard() {
        
        let (sut, _, _, alertSpy) = makeSUT(product: makeCardProduct(cardType: .individualBusinessman), selected: .market)

        XCTAssertNoDiff(alertSpy.values, [nil])
        
        sut.openPayment(.housingAndCommumalService)
                
        XCTAssertNoDiff(alertSpy.values, [nil, .disableForCorporateCard])
    }

    // MARK: - Helpers
    
    private func makeSUT(
        appVersion: String? = "1",
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RootViewModel,
        model: Model,
        linkSpy: ValueSpy<RootViewModel.Link.Case?>,
        alertSpy: ValueSpy<Alert.ViewModel.View?>
    ) {
        let model: Model = .mockWithEmptyExcept()
        let infoDictionary: [String : Any]? = appVersion.map {
            ["CFBundleShortVersionString": $0]
        }
        let sut = RootViewModel(
            fastPaymentsFactory: .legacy, 
            stickerViewFactory: .preview,
            navigationStateManager: .preview,
            productNavigationStateManager: .preview,
            tabsViewModel: .init(
                mainViewModel: .init(
                    model,
                    makeProductProfileViewModel: { _,_,_,_  in nil },
                    navigationStateManager: .preview,
                    sberQRServices: .empty(),
                    qrViewModelFactory: .preview(),
                    landingServices: .empty(),
                    paymentsTransfersFactory: .preview,
                    updateInfoStatusFlag: .inactive,
                    onRegister: {},
                    bannersBinder: .preview
                ),
                paymentsModel: .legacy(.init(
                    model: model,
                    makeFlowManager: { _ in .preview },
                    userAccountNavigationStateManager: .preview,
                    sberQRServices: .empty(),
                    qrViewModelFactory: .preview(),
                    paymentsTransfersFactory: .preview
                )),
                chatViewModel: .init(),
                marketShowcaseBinder: .preview
            ),
            informerViewModel: .init(model),
            infoDictionary: infoDictionary, 
            model,
            showLoginAction: { _ in
                
                    .init(viewModel: .init(authLoginViewModel: .preview))
            }, 
            landingServices: .empty(),
            mainScheduler: .immediate
        )
        
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        // TODO: restore model memory tracking after model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        trackForMemoryLeaks(linkSpy, file: file, line: line)
        trackForMemoryLeaks(alertSpy, file: file, line: line)
        
        return (sut, model, linkSpy, alertSpy)
    }
    
    private func makeSUT(
        product: ProductData? = nil,
        selected: RootViewModel.TabType,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RootViewModel,
        scheduler: TestSchedulerOf<DispatchQueue>,
        linkSpy: ValueSpy<RootViewModel.Link.Case?>,
        alertSpy: ValueSpy<Alert.ViewModel.View?>
    ) {
        let model: Model = .mockWithEmptyExcept()
        if let product {
            
            model.products.value.append(element: product, toValueOfKey: product.productType)
        }

        let scheduler = DispatchQueue.test

        let sut = RootViewModel(
            fastPaymentsFactory: .legacy, 
            stickerViewFactory: .preview,
            navigationStateManager: .preview,
            productNavigationStateManager: .preview,
            tabsViewModel: .init(
                mainViewModel: .init(
                    model,
                    makeProductProfileViewModel: { _,_,_,_  in nil },
                    navigationStateManager: .preview,
                    sberQRServices: .empty(),
                    qrViewModelFactory: .preview(),
                    landingServices: .empty(),
                    paymentsTransfersFactory: .preview,
                    updateInfoStatusFlag: .inactive,
                    onRegister: {},
                    bannersBinder: .preview
                ),
                paymentsModel: .legacy(.init(
                    model: model,
                    makeFlowManager: { _ in .preview },
                    userAccountNavigationStateManager: .preview,
                    sberQRServices: .empty(),
                    qrViewModelFactory: .preview(),
                    paymentsTransfersFactory: .preview
                )),
                chatViewModel: .init(),
                marketShowcaseBinder: .preview
            ),
            informerViewModel: .init(model),
            infoDictionary: nil,
            model,
            showLoginAction: { _ in
                
                    .init(viewModel: .init(authLoginViewModel: .preview))
            },
            landingServices: .empty(),
            mainScheduler: scheduler.eraseToAnyScheduler()
        )
        
        sut.selected = selected
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        let alertSpy = ValueSpy(sut.$alert.map(\.?.view))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        // TODO: restore model memory tracking after model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        trackForMemoryLeaks(linkSpy, file: file, line: line)
        trackForMemoryLeaks(alertSpy, file: file, line: line)
        
        return (sut, scheduler, linkSpy, alertSpy)
    }
    
    private func makeCardProduct(
        cardType: ProductCardData.CardType,
        status: ProductCardData.StatusCard = .active
    ) -> ProductCardData {
        
        .init(
            id: 1,
            productType: .card,
            number: "1111",
            numberMasked: "****",
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "RUB",
            mainField: "Card",
            additionalField: nil,
            customName: nil,
            productName: "Card",
            openDate: nil,
            ownerId: 0,
            branchId: 0,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: .test,
            largeDesign: .test,
            mediumDesign: .test,
            smallDesign: .test,
            fontDesignColor: .init(description: ""),
            background: [],
            accountId: nil,
            cardId: 0,
            name: "CARD",
            validThru: Date(),
            status: .active,
            expireDate: "01/01/01",
            holderName: "Иванов",
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: nil,
            statusPc: nil,
            isMain: nil,
            externalId: nil,
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            statusCard: status,
            cardType: cardType,
            idParent: nil
        )
    }
}

// MARK: - DSL

private extension RootViewModel {
    
    func showUserProfile(
        timeout: TimeInterval = 0.05
    ) {
        let showUserProfileAction = RootViewModelAction.ShowUserProfile(tokenIntent: "tokenIntent", conditions: [])
        action.send(showUserProfileAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func closeLink(
        timeout: TimeInterval = 0.05
    ) {
        let closeLinkAction = RootViewModelAction.CloseLink()
        action.send(closeLinkAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func closeAlert(
        timeout: TimeInterval = 0.05
    ) {
        let closeAlertAction = RootViewModelAction.CloseAlert()
        action.send(closeAlertAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    var landingViewModel: LandingWrapperViewModel? {
        
        switch link {
            
        case let .landing(viewModel, _):
            return viewModel
            
        default:
            return nil
        }
    }
}

private extension Model {
    
    func sendC2bDeepLink(
        timeout: TimeInterval = 0.05
    ) {
        let c2bDeepLink = ModelAction.DeepLink.Process(type: .c2b(anyURL()))
        action.send(c2bDeepLink)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func sendC2bSubscribeDeepLink(
        timeout: TimeInterval = 0.05
    ) {
        let c2bDeepLink = ModelAction.DeepLink.Process(type: .c2bSubscribe(anyURL()))
        action.send(c2bDeepLink)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func sendTransitionHistory(
        timeout: TimeInterval = 0.05
    ) {
        let transitionHistory = ModelAction.Notification.Transition.Process(transition: .history)
        action.send(transitionHistory)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func sendTransitionMe2me(
        timeout: TimeInterval = 0.05
    ) {
        let transitionHistory = ModelAction.Notification.Transition.Process(transition: .me2me(.init(bank: "")))
        action.send(transitionHistory)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func sendConsentMe2MeDebit(
        timeout: TimeInterval = 0.05
    ) {
        let consentMe2MeDebit = ModelAction.Consent.Me2MeDebit.Response(result: .success(.sample))
        action.send(consentMe2MeDebit)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func sendAppVersion(
        version: String = "2",
        trackViewUrl: String = "abc",
        timeout: TimeInterval = 0.05
    ) {
        let appVersion = ModelAction.AppVersion.Response(result: .success(.init(version: version, trackViewUrl: trackViewUrl)))
        action.send(appVersion)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

// MARK: - Helpers

private extension RootViewModel.Link {
    
    var `case`: Case {
        
        switch self {
            
        case .messages:
            return .messages
        case .me2me:
            return .me2me
        case .userAccount:
            return .userAccount
        case .payments:
            return .payments
        case .landing:
            return .landing
        case .openCard:
            return .openCard
        case .paymentSticker:
            return .paymentSticker
        }
    }
    
    enum Case {
        
        case messages, me2me, userAccount, payments
        case landing, openCard, paymentSticker
    }
}

private extension ConsentMe2MeDebitData {
    
    static let sample: Self = .init(
        accountId: nil,
        amount: 123,
        bankRecipientID: nil,
        cardId: nil,
        fee: 12,
        rcvrMsgId: nil,
        recipientID: nil,
        refTrnId: nil
    )
}

private extension ClientInfoData {
    
    static let sample: Self = .init(
        id: 1,
        lastName: "lastName",
        firstName: "firstName",
        patronymic: "patronymic",
        birthDay: "birthDay",
        regSeries: "regSeries",
        regNumber: "regNumber",
        birthPlace: "birthPlace",
        dateOfIssue: "dateOfIssue",
        codeDepartment: "codeDepartment",
        regDepartment: "regDepartment",
        address: "address",
        addressInfo: nil,
        addressResidential: "addressResidential",
        addressResidentialInfo: nil,
        phone: "phone",
        phoneSMS: "phoneSMS",
        email: "email",
        inn: "inn",
        customName: "customName"
    )
}

import SwiftUI

private extension Alert.ViewModel.View {
    
    static let newVersion: Self = .init(
        title: "Новая версия",
        message: "Доступна новая версия 2.",
        primary: .init(
            kind: .default,
            title: "Не сейчас"
        ),
        secondary: .init(
            kind: .default,
            title: "Обновить"
        )
    )
    
    static let needOrderCard: Self = Alert.ViewModel.needOrderCard(primaryAction: {}).view
    static let disableForCorporateCard: Self = Alert.ViewModel.disableForCorporateCard(primaryAction: {}).view
    
}

private extension String {
    
    static let housingAndCommumalService = "HOUSING_AND_COMMUNAL_SERVICE"
}
