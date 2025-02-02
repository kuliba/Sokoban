//
//  RootViewModel_Tests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 18.11.2024.
//

@testable import Vortex
import PayHub
import XCTest
import CollateralLoanLandingGetShowcaseUI
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import UIPrimitives
import Combine

class RootViewModel_Tests: XCTestCase {
    
    // MARK: - Helpers
    
    typealias SUT = RootViewModel
    typealias Spy = ValueSpy<RootEvent>
    typealias Witnesses = ContentWitnesses<RootViewModel, RootViewSelect>
    
    func makeSUT(
        paymentsModel: RootViewModel.PaymentsModel? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RootViewModel,
        spy: Spy
    ) {
        let model: Model = .mockWithEmptyExcept()
        let paymentsModel = paymentsModel ?? .legacy(.init(
            model: model,
            makeFlowManager: { _ in .preview },
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            paymentsTransfersFactory: .preview
        ))
        let sut = RootViewModel(
            fastPaymentsFactory: .legacy,
            stickerViewFactory: .preview,
            navigationStateManager: .preview,
            productNavigationStateManager: .preview,
            tabsViewModel: .init(
                mainViewModel: .init(
                    model,
                    navigationStateManager: .preview,
                    sberQRServices: .empty(),
                    landingServices: .empty(),
                    paymentsTransfersFactory: .preview,
                    updateInfoStatusFlag: .inactive,
                    onRegister: {},
                    sections: makeSections(),
                    bindersFactory: .init(
                        bannersBinder: .preview,
                        makeCollateralLoanShowcaseBinder: { .preview },
                        makeCollateralLoanLandingBinder: { _ in .preview },
                        makeCreateDraftCollateralLoanApplicationBinder: { _ in .preview },
                        makeSavingsAccountBinders: .preview
                    ),
                    viewModelsFactory: .preview,
                    makeOpenNewProductButtons: { _ in [] }
                ),
                paymentsModel: paymentsModel,
                chatViewModel: .init(),
                marketShowcaseBinder: .preview
            ),
            informerViewModel: .init(model),
            model,
            showLoginAction: { _ in
                
                    .init(viewModel: .init(authLoginViewModel: .preview))
            },
            landingServices: .empty(),
            mainScheduler: .immediate
        )
        
        let spy = Spy(sut.rootEventPublisher)
        
        // FIXME: fie Model memory leaks
        // trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
     
    private func makeSections() -> [MainSectionViewModel] {
        
        [
            MainSectionProductsView.ViewModel.sample,
            MainSectionFastOperationView.ViewModel(),
            MainSectionPromoView.ViewModel.sample,
            MainSectionCurrencyMetallView.ViewModel.sample,
            MainSectionOpenProductView.ViewModel.sample,
            MainSectionAtmView.ViewModel.initial
        ]
    }
    
    func mainViewSections(
        _ sut: SUT
    ) -> [MainSectionViewModel] {
        
        sut.mainViewSections
    }
    
    func emit(
        _ event: RootEvent,
        from section: MainSectionViewModel
    ) {
        section.emit(event)
    }
    
    func tapMainViewFastSectionQRButton(
        _ sut: SUT
    ) throws {
        
        try sut.tapMainViewFastSectionQRButton()
    }
    
    func tapMainViewFastSectionTemplatesButton(
        _ sut: SUT
    ) throws {
        
        try sut.tapMainViewFastSectionTemplatesButton()
    }
    
    func tapMainViewFastSectionStandardPaymentButton(
        _ sut: SUT
    ) throws {
        
        try sut.tapMainViewFastSectionStandardPaymentButton()
    }
    
    func tapLegacyPaymentsSectionQRButton(
        _ sut: SUT
    ) throws {
        
        try sut.tapLegacyPaymentsSectionQRButton()
    }
}

// MARK: - GetCollateralLandingDomain.Binder preview

private extension GetCollateralLandingDomain.Binder {
    
    static let preview = GetCollateralLandingDomain.Binder(
        content: .preview,
        flow: .preview,
        bind: { _,_ in [] }
    )
}

private extension GetCollateralLandingDomain.Content {
    
    static let preview = GetCollateralLandingDomain.Content(
        initialState: .init(landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE"),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

private extension GetCollateralLandingDomain.Flow {
    
    static let preview = GetCollateralLandingDomain.Flow(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

// MARK: - GetShowcaseDomain.Binder preview

private extension GetShowcaseDomain.Binder {
    
    static let preview = GetShowcaseDomain.Binder(
        content: .preview,
        flow: .preview,
        bind: { _,_ in [] }
    )
}

private extension GetShowcaseDomain.Flow {
    
    static let preview = GetShowcaseDomain.Flow(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

private extension GetShowcaseDomain.Content {
    
    static let preview = GetShowcaseDomain.Content(
        initialState: .init(),
        reduce: GetShowcaseDomain.Reducer().reduce(_:_:),
        handleEffect: GetShowcaseDomain.EffectHandler(load: { _ in }).handleEffect(_:dispatch:)
    )
}

// MARK: - CreateDraftCollateralLoanApplicationDomain.Binder preview

private extension CreateDraftCollateralLoanApplicationDomain.Binder {
    
    static let preview = CreateDraftCollateralLoanApplicationDomain.Binder(
        content: .preview,
        flow: .preview,
        bind: { _,_ in [] }
    )
}

private extension CreateDraftCollateralLoanApplicationDomain.Content {
    
    static let preview = CreateDraftCollateralLoanApplicationDomain.Content(
        initialState: .init(data: .preview),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

private extension CreateDraftCollateralLoanApplicationDomain.Flow {
    
    static let preview = CreateDraftCollateralLoanApplicationDomain.Flow(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
    )
}

// MARK: - DSL

private extension RootViewModel {
    
    var mainViewModel: MainViewModel {
        
        return tabsViewModel.mainViewModel
    }
    
    var mainViewSections: [MainSectionViewModel] {
        
        return mainViewModel.sections
    }
    
    func tapMainViewFastSectionQRButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try mainViewModel.tapFastSectionButton(type: .qr, file: file, line: line)
    }
    
    func tapMainViewFastSectionStandardPaymentButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try mainViewModel.tapFastSectionButton(type: .utility, file: file, line: line)
    }
    
    func tapMainViewFastSectionTemplatesButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try mainViewModel.tapFastSectionButton(type: .templates, file: file, line: line)
    }
    
    func legacyPaymentsTransfers() throws -> PaymentsTransfersViewModel {
        
        switch tabsViewModel.paymentsModel {
        case let .legacy(paymentsTransfers):
            return paymentsTransfers
            
        default:
            throw NSError(domain: "Expected Legacy PaymentsTransfers", code: -1)
        }
    }
    
    func tapLegacyPaymentsSectionQRButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try legacyPaymentsTransfers().tapPaymentsSectionQRButton(file: file, line: line)
    }
}

private extension MainSectionViewModel {
    
    func emit(_ event: RootEvent) {
        
        action.send(event)
    }
}

private extension MainViewModel {
    
    typealias FastSection = MainSectionFastOperationView.ViewModel
    typealias FastSectionButton = ButtonIconTextView.ViewModel
    typealias FastSectionButtons = [FastSectionButton]
    
    func fastSectionButtons(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> FastSectionButtons {
        
        let sections = sections.compactMap { $0 as? FastSection }
        
        return try XCTUnwrap(sections.first?.items, "Expected to have Fast Section.", file: file, line: line)
    }
    
    enum FastSectionButtonType: String {
        
        case qr = "Оплата по QR"
        case templates = "Шаблоны"
        case byPhone = "Перевод по телефону"
        case utility = "Оплата ЖКУ"
    }
    
    func fastSectionButton(
        type: FastSectionButtonType,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> FastSectionButton {
        
        let buttons = try fastSectionButtons(file: file, line: line)
        
        return try XCTUnwrap(buttons.first(where: { $0.title.text == type.rawValue }), "Expected to have \(type.rawValue) Button, but got nil instead.", file: file, line: line)
    }
    
    func tapFastSectionButton(
        type: FastSectionButtonType,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try fastSectionButton(type: type, file: file, line: line).action()
    }
}

private extension PaymentsTransfersViewModel {
    
    typealias PaymentsSection = PTSectionPaymentsView.ViewModel
    
    func paymentsSection(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsSection {
        
        let sections = sections.compactMap { $0 as? PaymentsSection }
        
        return try XCTUnwrap(sections.first, "Expected to have Payments Section", file: file, line: line)
    }
    
    func paymentsSectionQRButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsSection.PaymentButtonVM {
        
        let buttons = try paymentsSection(file: file, line: line).paymentButtons
            .filter { $0.type == .qrPayment }
        
        return try XCTUnwrap(buttons.first, "Expected to have QR Button in Payments Section", file: file, line: line)
    }
    
    func tapPaymentsSectionQRButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try paymentsSectionQRButton(file: file, line: line).action()
    }
}
