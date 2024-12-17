//
//  ProductProfileNavigationEffectHandlerTests.swift
//
//
//  Created by Andryusina Nataly on 14.02.2024.
//

@testable import ProductProfile
import ForaTools
import ProductProfileComponents
import RxViewModel
import UIPrimitives
import XCTest

extension ProductProfileNavigationEffectHandler: EffectHandler {}

final class ProductProfileNavigationEffectHandlerTests: XCTestCase {
    
    // MARK: test showAlert
    
    func test_showCVVAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()
        
        let id = UUID()
        let alert = AlertModelOf.alertCVV(id)
        
        expect(sut, with: .delayAlert(alert, .milliseconds(300)), toDeliver: .showAlert(alert))
    }
    
    func test_showCardBlockedAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()
        
        let id = UUID()
        let alert = AlertModelOf.alertCardBlocked(id)
        
        expect(sut, with: .delayAlert(alert, .milliseconds(300)), toDeliver: .showAlert(alert))
    }
    
    func test_showBlockCardAlert_shouldDeliverShowAlert() {
        
        let sut = makeSUT()
        
        let id = UUID()
        let alert = AlertModelOf.alertBlockCard(.card(), id)
        
        expect(sut, with: .delayAlert(alert, .seconds(1)), toDeliver: .showAlert(alert))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ProductProfileNavigationEffectHandler
    private typealias EventNavigation = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias MakeCardGuardianViewModel = (AnySchedulerOfDispatchQueue) -> CardGuardianViewModel
     
    private typealias MakeTopUpCardViewModel = (AnySchedulerOfDispatchQueue) -> TopUpCardViewModel
    
    private typealias MakeAccountInfoPanelViewModel = (AnySchedulerOfDispatchQueue) -> AccountInfoPanelViewModel

    private typealias MakeProductDetailsViewModel = (AnySchedulerOfDispatchQueue) -> ProductDetailsViewModel
    private typealias MakeProductDetailsSheetViewModel = (AnySchedulerOfDispatchQueue) -> ProductDetailsSheetViewModel

    private typealias OpenPanelSpy = () -> Void
    
    private func makeSUT(
        buttons: [CardGuardianState._Button] = .preview,
        topUpCardButtons: [TopUpCardState.PanelButton] = .previewRegular,
        accountInfoPanelButtons: [AccountInfoPanelState.PanelButton] = .previewRegular,
        accountDetails: [ListItem] = .accountItems,
        cardDetails: [ListItem] = .cardItems,
        sheetButtons: [ProductDetailsSheetState.PanelButton] = .previewRegular,
        event: CardGuardianEvent? = nil,
        guardianCard: @escaping SUT.GuardCard = {_ in },
        toggleVisibilityOnMain: @escaping SUT.ToggleVisibilityOnMain = {_ in },
        showContacts: @escaping SUT.ShowContacts = {},
        changePin: @escaping SUT.GuardCard = {_ in },
        topUpCardFromOurBank: @escaping SUT.TopUpCardFromOurBank = {_ in },
        topUpCardFromOtherBank: @escaping SUT.TopUpCardFromOtherBank = {_ in },
        accountDetailsAction: @escaping SUT.AccountDetails = {_ in },
        accountStatementAction: @escaping SUT.AccountStatement = {_ in },
        longPress: @escaping SUT.LongPress = {_,_ in },
        cvvTapped: @escaping SUT.CvvTapped = { "" },
        shareInfo: @escaping ([String]) -> Void = {_ in },
        scheduler: AnySchedulerOfDispatchQueue = .immediate,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let cardGuardianReduce = CardGuardianReducer()
        
        let cardGuardianHandleEffect = CardGuardianEffectHandler()
        
        let makeCardGuardianViewModel: MakeCardGuardianViewModel =  {
            
            .init(
                initialState: .init(buttons: buttons),
                reduce: cardGuardianReduce.reduce(_:_:),
                handleEffect: cardGuardianHandleEffect.handleEffect(_:_:),
                scheduler: $0
            )
        }
        
        let topUpCardReduce = TopUpCardReducer()
        
        let topUpCardHandleEffect = TopUpCardEffectHandler()
        
        let makeTopUpCardViewModel: MakeTopUpCardViewModel =  {
            
            .init(
                initialState: .init(buttons: topUpCardButtons),
                reduce: topUpCardReduce.reduce(_:_:),
                handleEffect: topUpCardHandleEffect.handleEffect(_:_:),
                scheduler: $0
            )
        }
        
        let accountInfoPanelReduce = AccountInfoPanelReducer()
        
        let accountInfoPanelHandleEffect = AccountInfoPanelEffectHandler()
        
        let makeAccountInfoPanelViewModel: MakeAccountInfoPanelViewModel =  {
            
            .init(
                initialState: .init(buttons: accountInfoPanelButtons),
                reduce: accountInfoPanelReduce.reduce(_:_:),
                handleEffect: accountInfoPanelHandleEffect.handleEffect(_:_:),
                scheduler: $0
            )
        }
        
        let detailsReduce = ProductDetailsReducer(shareInfo: shareInfo)
        let detailsHandleEffect = ProductDetailsEffectHandler()
        let makeProductDetailsViewModel: MakeProductDetailsViewModel =  {
            .init(
                initialState: .init(
                    accountDetails: accountDetails,
                    cardDetails: cardDetails),
                reduce: detailsReduce.reduce(_:_:),
                handleEffect: detailsHandleEffect.handleEffect(_:_:),
                scheduler: $0
            )
        }
        
        let sheetReduce = ProductDetailsSheetReducer()
        let sheetHandleEffect = ProductDetailsSheetEffectHandler()
        let makeProductDetailsSheetViewModel: MakeProductDetailsSheetViewModel =  {
            .init(
                initialState: .init(buttons: sheetButtons),
                reduce: sheetReduce.reduce(_:_:),
                handleEffect: sheetHandleEffect.handleEffect(_:_:),
                scheduler: $0
            )
        }

        let sut = SUT(
            makeCardGuardianViewModel: makeCardGuardianViewModel,
            cardGuardianActions: .init(
                guardCard: guardianCard,
                toggleVisibilityOnMain: toggleVisibilityOnMain,
                showContacts: showContacts,
                changePin: changePin
            ),
            makeTopUpCardViewModel: makeTopUpCardViewModel,
            topUpCardActions: .init(
                topUpCardFromOtherBank: topUpCardFromOtherBank,
                topUpCardFromOurBank: topUpCardFromOurBank
            ),
            makeAccountInfoPanelViewModel: makeAccountInfoPanelViewModel,
            accountInfoPanelActions: .init(
                accountDetails: accountDetailsAction,
                accountStatement: accountStatementAction
            ),
            makeProductDetailsViewModel: makeProductDetailsViewModel,
            productDetailsActions: .init(
                longPress: longPress,
                cvvTap: cvvTapped),
            makeProductDetailsSheetViewModel: makeProductDetailsSheetViewModel,
            scheduler: scheduler
        )
        
        trackForMemoryLeaks(cardGuardianReduce, file: file, line: line)
        trackForMemoryLeaks(cardGuardianHandleEffect, file: file, line: line)
        trackForMemoryLeaks(topUpCardReduce, file: file, line: line)
        trackForMemoryLeaks(topUpCardHandleEffect, file: file, line: line)
        trackForMemoryLeaks(accountInfoPanelReduce, file: file, line: line)
        trackForMemoryLeaks(accountInfoPanelHandleEffect, file: file, line: line)
        trackForMemoryLeaks(detailsReduce, file: file, line: line)
        trackForMemoryLeaks(detailsHandleEffect, file: file, line: line)
        trackForMemoryLeaks(sheetReduce, file: file, line: line)
        trackForMemoryLeaks(sheetHandleEffect, file: file, line: line)

        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension CardGuardianUI.Card {
    
    static func card(
        status: CardGuardianStatus = .active
    ) -> CardGuardianUI.Card {
        
        .init(
            cardId: 1,
            cardNumber: "111",
            cardGuardianStatus: status
        )
    }
}

private extension Product {
    
    static let product: Self = .init(
        productID: 1,
        visibility: false)
}
