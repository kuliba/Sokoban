//
//  RootViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 23.09.2023.
//

@testable import ForaBank
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
        model.sendC2bDeepLink()
        XCTAssertNoDiff(linkSpy.values, [nil, .payments])
        
        sut.resetLink()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .payments, nil])
    }
    
    // MARK: - DeepLink
    
    func test_deepLink_c2b_shouldSetLinkToPayments() {
        
        let (sut, model, linkSpy, _) = makeSUT()
        
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        model.sendC2bDeepLink()
        
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
            navigationStateManager: .preview,
            mainViewModel: .init(
                model,
                makeProductProfileViewModel: { _,_,_ in nil },
                navigationStateManager: .preview,
                sberQRServices: .empty(),
                qrViewModelFactory: .preview(),
                paymentsTransfersFactory: .preview,
                onRegister: {}
            ),
            paymentsViewModel: .init(
                model: model,
                flowManager: .preview,
                userAccountNavigationStateManager: .preview,
                sberQRServices: .empty(),
                qrViewModelFactory: .preview(), 
                paymentsTransfersFactory: .preview
            ),
            chatViewModel: .init(),
            informerViewModel: .init(model),
            infoDictionary: infoDictionary,
            model,
            showLoginAction: { _ in
                
                    .init(viewModel: .init(authLoginViewModel: .preview))
            }
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
        }
    }
    
    enum Case {
        
        case messages, me2me, userAccount, payments
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
}
