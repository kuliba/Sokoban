//
//  MainViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 19.09.2023.
//

@testable import Vortex
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingGetShowcaseUI
import Combine
import CombineSchedulers
import LandingUIComponent
import SberQR
import UIPrimitives
import XCTest

final class MainViewModelTests: XCTestCase {
    
    func test_init_cacheNotContainsSticker_shouldSetStickerToNil()  {
        
        let (sut, _) = makeSUT()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNil(sut.sections.stickerViewModel)
    }
    
    func test_init_cacheContainsSticker_shouldSetSticker() throws {
        
        let (sut, model) = makeSUT()
        model.productListBannersWithSticker.value = [.init(productName: anyMessage(), link: anyMessage(), md5hash: anyMessage(), action: nil)]
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)

        
        XCTAssertNotNil(sut.sections.stickerViewModel)
    }
        
    func test_tapTemplates_shouldSetLinkToTemplates() {
        
        let (sut, _) = makeSUT(scheduler: .immediate)
        let linkSpy = ValueSpy(sut.$route.map(\.case))
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.fastPayment?.tapFastPaymentButton(type: .templates)
        
        XCTAssertNoDiff(linkSpy.values, [nil, .templates])
    }
    
    func test_tapTemplates_shouldNotSetLinkToNilOnTemplatesCloseUntilDelay() {
        
        let (sut, _) = makeSUT(scheduler: .immediate)
        let linkSpy = ValueSpy(sut.$route.map(\.case))
        sut.fastPayment?.tapFastPaymentButton(type: .templates)
        
        sut.templatesListViewModel?.closeAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .templates])
    }
    
    func test_tapUserAccount_shouldSendGetSubscriptionRequest() {
        
        let (sut, model) = makeModelWithServerAgentStub(
            getC2bResponseStub: getC2bResponseStub(),
            scheduler: .immediate
        )
        let spy = ValueSpy(model.action.compactMap { $0 as? ModelAction.C2B.GetC2BSubscription.Request })
        XCTAssertNoDiff(spy.values.count, 0)
        XCTAssertNoDiff(model.subscriptions.value, nil)
        
        sut.tapUserAccount()
        
        XCTAssertNoDiff(spy.values.count, 1)
        XCTAssertNoDiff(
            model.subscriptions.value,
            .init(
                title: "title",
                subscriptionType: .control,
                emptySearch: nil,
                emptyList: nil,
                list: nil
            )
        )
    }
    
    typealias mainSectionVMAction = MainSectionViewModelAction.Products
    
    func test_productCarouselStickerDidTapped()  {
        
        let (sut, spy) = makeSUTWithSpy()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
                
        XCTAssertNoDiff(spy.values, [])
        
        sut.productCarouselViewModel.showPromoProductAndWait(.sticker)
        
        XCTAssertNoDiff(spy.values, [.init(promo: .sticker)])
    }
    
    func test_orderSticker_showsAlert_whenNoCards() {
        
        let localAgentDataStubClear: [String: Data] = [
            "Array<OperatorGroupData>": .init(),
        ]
        let localAgent = LocalAgentStub(stub: localAgentDataStubClear)
        let model = Model.mockWithEmptyExcept(
            localAgent: localAgent
        )
        
        let qrViewModelFactory = QRViewModelFactory.preview()
        
        let sut = MainViewModel(
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
                makeSavingsAccountBinder: { fatalError() }
            ),
            viewModelsFactory: .preview,
            makeOpenNewProductButtons: { _ in [] }
        )
        
        sut.orderSticker()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNotNil(sut.route.modal?.alert)
    }
    
    func test_orderSticker_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT()
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        sut.orderSticker()
        
        XCTAssertNotNil(sut.route.modal?.alert)
    }
    
    func test_orderSticker_notOnlyCorporateCards_shouldSetLinkToPaymentSticker() {
        
        let (sut, model) = makeSUT()
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        let linkSpy = ValueSpy(sut.$route.map(\.case))
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.orderSticker()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .paymentSticker])
    }
    
    func test_productCarouselSavingsActionDidTapped()  {
        
        let (sut, spy) = makeSUTWithSpy()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertNoDiff(spy.values, [])
        
        sut.productCarouselViewModel.showPromoProductAndWait(.savingsAccount)

        XCTAssertNoDiff(spy.values, [.init(promo: .savingsAccount)])
    }

    func test_tapQr_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT()
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.modal)
        
        sut.fastPayment?.tapFastPaymentButtonAndWait(type: .byQr)
        
        XCTAssertNotNil(sut.route.modal?.alert)
    }
    
    func test_tapQr_notOnlyCorporateCards_shouldSetModalToQrScanner() {
        
        let (sut, model) = makeSUT()
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.modal)
        
        sut.fastPayment?.tapFastPaymentButtonAndWait(type: .byQr)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(sut.route.modal?.case, .qrScanner)
    }
    
    func test_tapByPhone_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(scheduler: .immediate)
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.modal)
        
        sut.fastPayment?.tapFastPaymentButton(type: .byPhone)
        
        XCTAssertNotNil(sut.route.modal?.alert)
    }
    
    func test_tapByPhone_notOnlyCorporateCards_shouldSetModalToByPhone() {
        
        let (sut, model) = makeSUT(scheduler: .immediate)
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.modal)
        
        sut.fastPayment?.tapFastPaymentButton(type: .byPhone)
        
        XCTAssertNoDiff(sut.route.modal?.case, .byPhone)
    }
    
    func test_tapByZKU_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT()
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.modal)
        
        sut.fastPayment?.tapFastPaymentButtonAndWait(type: .utility)
        
        XCTAssertNotNil(sut.route.modal?.alert)
    }
    
    func test_tapOpenCard_onlyCorporateCards_shouldNotChangeDestination() {
        
        let (sut, model) = makeSUT()
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.openProductSection?.tapOpenProductButtonAndWait(type: .card)
        
        XCTAssertNil(sut.route.destination)
    }
    
    func test_tapOpenCard_notOnlyCorporateCards_shouldSetRouteToOpenCard() {
        
        let (sut, model) = makeSUT()
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.openProductSection?.tapOpenProductButtonAndWait(type: .card)
        
        XCTAssertNoDiff(sut.route.case, .openCard)
    }
    
    func test_tapOpenAccount_accountProductsListWithOutValue_shouldNotChangeDestination() {
        
        let (sut, model) = makeSUT()
        model.accountProductsList.value = .init()
        XCTAssertNil(sut.route.destination)
        
        sut.openProductSection?.tapOpenProductButtonAndWait(type: .account)
        
        XCTAssertNil(sut.route.destination)
    }
    
    func test_tapOpenAccount_accountProductsListNotNil_shouldSetModalToOpenAccount() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        model.accountProductsList.value = [.test]
        XCTAssertNil(sut.route.destination)
        
        sut.openProductSection?.tapOpenProductButton(type: .account)
        
        XCTAssertNoDiff(sut.route.modal?.case, .openAccount)
    }
    
    func test_tapOpenDeposit_shouldSetRouteToOpenDepositsList() {
        
        let (sut, _) = makeSUT()
        XCTAssertNil(sut.route.destination)
        
        sut.openProductSection?.tapOpenProductButtonAndWait(type: .deposit)
        
        XCTAssertNoDiff(sut.route.case, .openDepositsList)
    }
    
    func test_openProducts_tapOpenSticker_shouldSetRouteToLanding() {
        
        let (sut, _) = makeSUT()
        XCTAssertNil(sut.route.destination)
        
        sut.openProductSection?.tapOpenProductButtonAndWait(type: .sticker)
        
        XCTAssertNoDiff(sut.route.case, .landing)
    }

    // MARK: TODO - fix next two tests. Fail on CI
//    func test_shouldCallMakeCollateralLoanLandingViewModelOnOpenCollateralLoanLandingProductEvent() throws {
//        
//        let showcase = makeCollateralLoanLandingViewModel()
//        let showcaseSpy = ShowcaseSpy(stubs: .init(repeating: showcase, count: 100))
//        let (sut, _) = makeSUT(showcaseSpy: showcaseSpy, scheduler: .immediate)
//        XCTAssertEqual(showcaseSpy.callCount, 0)
//        
//        try sut.tapOpenCollateralLoanLandingButton()
//
//        XCTAssertEqual(showcaseSpy.callCount, 1)
//    }
//    
//    func test_shouldSetDestinationOnOpenCollateralLoanLandingProductEvent() throws {
//        
//        let showcase = makeCollateralLoanLandingViewModel()
//        let showcaseSpy = ShowcaseSpy(stubs: .init(repeating: showcase, count: 100))
//        let (sut, _) = makeSUT(showcaseSpy: showcaseSpy, scheduler: .immediate)
//        XCTAssertNil(sut.route.destination)
//        
//        try sut.tapOpenCollateralLoanLandingButton()
//        
//        try XCTAssert(XCTUnwrap(sut.getShowcaseDomainViewModel) === showcase)
//    }
    
    func test_productsSection_tapOpenSticker_shouldSetRouteToLanding() {
        
        let (sut, _) = makeSUT(scheduler: .immediate)
        XCTAssertNil(sut.route.destination)
        
        sut.mainSection?.showPromoProduct(.sticker)
        
        XCTAssertNoDiff(sut.route.case, .landing)
    }
    
    func test_productsSection_tapMoreProduct_shouldSetRouteToMyProducts() {
        
        let (sut, _) = makeSUT(scheduler: .immediate)
        XCTAssertNil(sut.route.destination)
        
        sut.mainSection?.openMoreProduct()
        
        XCTAssertNoDiff(sut.route.case, .myProducts)
    }
    
    func test_productsSection_tapProductProfile_shouldSetRouteToProductProfile() {
        
        let (sut, model) = makeSUT(scheduler: .immediate)
        let productID = 1
        model.products.value[.card] = [makeCardProduct(id: productID, cardType: .main, isMain: true)]
        XCTAssertNil(sut.route.destination)
        
        sut.mainSection?.openProductProfile(productId: productID)
        
        XCTAssertNoDiff(sut.route.case, .productProfile)
    }
    
    func test_tapCurrencyWallet_buy_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.currencyWalletSection?.tapCurrencyWalletButton(currency: .rub, actionType: .buy)
        
        XCTAssertNoDiff(sut.route.modal?.case, .alert)
    }
    
    func test_tapCurrencyWallet_buy_notOnlyCorporateCards_shouldSetRouteToCurrencyWallet() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.currencyWalletSection?.tapCurrencyWalletButton(currency: .rub, actionType: .buy)
        
        XCTAssertNoDiff(sut.route.case, .currencyWallet)
    }
    
    func test_tapCurrencyWallet_item_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
        ]
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.currencyWalletSection?.tapCurrencyWalletButton(currency: .rub, actionType: .item)
        
        XCTAssertNoDiff(sut.route.modal?.case, .alert)
    }
    
    func test_tapCurrencyWallet_item_notOnlyCorporateCards_shouldSetRouteToCurrencyWallet() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.currencyWalletSection?.tapCurrencyWalletButton(currency: .rub, actionType: .item)
        
        XCTAssertNoDiff(sut.route.case, .currencyWallet)
    }
    
    func test_tapCurrencyWallet_sell_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.currencyWalletSection?.tapCurrencyWalletButton(currency: .rub, actionType: .sell)
        
        XCTAssertNoDiff(sut.route.modal?.case, .alert)
    }
    
    func test_tapCurrencyWallet_sell_notOnlyCorporateCards_shouldSetRouteToCurrencyWallet() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.currencyWalletSection?.tapCurrencyWalletButton(currency: .rub, actionType: .sell)
        
        XCTAssertNoDiff(sut.route.case, .currencyWallet)
    }
    
    func test_openMigTransfer_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.openMigTransfer(.init(countryId: "810"))
        
        XCTAssertNoDiff(sut.route.modal?.case, .alert)
    }
    
    func test_openMigTransfer_notOnlyCorporateCards_shouldSetRouteToPayments() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.openMigTransfer(.init(countryId: "810"))
        
        XCTAssertNoDiff(sut.route.case, .payments)
    }
    
    func test_openContactTransfer_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.openContactTransfer(.init(countryId: "810"))
        
        XCTAssertNoDiff(sut.route.modal?.case, .alert)
    }
    
    func test_openContactTransfer_notOnlyCorporateCards_shouldSetRouteToPayments() {
        
        let (sut, model) = makeSUT(
            currencyList: [.rub],
            currencyWalletList: [.rub],
            scheduler: .immediate
        )
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.openContactTransfer(.init(countryId: "810"))
        
        XCTAssertNoDiff(sut.route.case, .payments)
    }
    
    // TODO: вернуть после оптимизации запросов UpdateInfo.swift:10
    
    /*func test_updateSections_updateInfoFullPath_updateInfoStatusFlagActive_shouldAddUpdateSections()  {
     
     let (sut, model) = makeSUT(updateInfoStatusFlag: .active)
     _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
     
     assert(sections: sut.sections, count: 6, type: .products)
     
     model.updateInfo.value.setValue(false, for: .card)
     _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
     
     assert(sections: sut.sections, count: 7, type: .updateInfo)
     
     model.updateInfo.value.setValue(false, for: .loan)
     _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
     
     assert(sections: sut.sections, count: 7, type: .updateInfo)
     
     model.updateInfo.value.setValue(false, for: .deposit)
     _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
     
     assert(sections: sut.sections, count: 7, type: .updateInfo)
     
     model.updateInfo.value.setValue(false, for: .account)
     _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
     
     assert(sections: sut.sections, count: 7, type: .updateInfo)
     
     model.updateInfo.value.setValue(true, for: .card)
     _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
     
     assert(sections: sut.sections, count: 7, type: .updateInfo)
     
     model.updateInfo.value.setValue(true, for: .loan)
     _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
     
     assert(sections: sut.sections, count: 7, type: .updateInfo)
     
     model.updateInfo.value.setValue(true, for: .deposit)
     _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
     
     assert(sections: sut.sections, count: 7, type: .updateInfo)
     
     model.updateInfo.value.setValue(true, for: .account)
     _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
     
     assert(sections: sut.sections, count: 6, type: .products)
     }
     */
    func test_updateSections_updateInfoFullPath_updateInfoStatusFlagInActive_shouldAddUpdateSections()  {
        
        let (sut, model) = makeSUT(updateInfoStatusFlag: .inactive, scheduler: .immediate)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(false, for: .card)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(false, for: .loan)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(false, for: .deposit)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(false, for: .account)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(true, for: .card)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(true, for: .loan)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(true, for: .deposit)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(true, for: .account)
        
        assert(sections: sut.sections, count: 6, type: .products)
    }
    
    // MARK: - handleLandingAction
    
    func test_handleLandingAction_shouldSetDestinationToLanding() {
        
        let (sut, _) = makeSUT(scheduler: .immediate)
        let type = anyMessage()
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.handleLandingAction(type)
        
        XCTAssertNoDiff(sut.route.case, .landing)
        XCTAssertNil(sut.route.modal)
    }
    
    func test_landingAction_tapGoToBack_shouldSetDestinationToNil() {
        
        let (sut, _) = makeSUT(scheduler: .immediate)
        let type = anyMessage()
        
        let destinationSpy = ValueSpy(sut.$route.map(\.case))
        
        sut.handleLandingAction(type)
        
        sut.landingWrapperViewModel?.action(.goToBack)
        
        XCTAssertNoDiff(destinationSpy.values, [nil, .landing, nil])
    }
    
    // MARK: - Helpers
    fileprivate typealias SberQRError = MappingRemoteServiceError<MappingError>
    private typealias GetSberQRDataResult = SberQRServices.GetSberQRDataResult
    private typealias ShowcaseSpy = CallSpy<Void, GetShowcaseDomain.Binder>
    private typealias CollateralLandingSpy = CallSpy<Void, GetCollateralLandingDomain.Binder>

    private func makeSUT(
        createSberQRPaymentStub: CreateSberQRPaymentResult = .success(.empty()),
        getSberQRDataResultStub: GetSberQRDataResult = .success(.empty()),
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag = .inactive,
        buttons: [NewProductButton.ViewModel] = [],
        showcaseSpy: ShowcaseSpy = .init(),
        collateralLandingSpy: CollateralLandingSpy = .init(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sberQRServices = SberQRServices.preview(
            createSberQRPaymentResultStub: createSberQRPaymentStub,
            getSberQRDataResultStub: getSberQRDataResultStub
        )
        
        let qrViewModelFactory = QRViewModelFactory.preview()
        
        let viewModelsFactory: MainViewModelsFactory = .init(
            makeAuthFactory: { ModelAuthLoginViewModelFactory(model: $0, rootActions: $1)},
            makeProductProfileViewModel: { _,_,_,_ in .sample },
            makePromoProductViewModel: { $0.mapper(md5Hash: $0.md5hash, onTap: $1.show, onHide: $1.hide)},
            qrViewModelFactory: qrViewModelFactory
        )
        
        let sut = MainViewModel(
            model,
            navigationStateManager: .preview,
            sberQRServices: sberQRServices,
           // qrViewModelFactory: qrViewModelFactory,
            landingServices: .empty(),
            paymentsTransfersFactory: .preview,
            updateInfoStatusFlag: updateInfoStatusFlag,
            onRegister: {},
            sections: makeSections(),
            bindersFactory: .init(
                bannersBinder: .preview,
                makeCollateralLoanShowcaseBinder: { .preview },
                makeCollateralLoanLandingBinder: { _ in
                    collateralLandingSpy.call()
                },
                makeCreateDraftCollateralLoanApplicationBinder: { _ in .preview },
                makeSavingsAccountBinder: { fatalError() }
            ),
            viewModelsFactory: viewModelsFactory,
            makeOpenNewProductButtons: { _ in buttons },
            scheduler: scheduler
        )
        
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(sut, file: file, line: line)
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
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
        
    private func makeSUT(
        currencyList: [CurrencyData],
        currencyWalletList: [CurrencyWalletData],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        buttons: [NewProductButton.ViewModel] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        model.currencyWalletList.value = currencyWalletList
        model.currencyList.value = currencyList
        
        let sberQRServices = SberQRServices.preview(
            createSberQRPaymentResultStub: .success(.empty()),
            getSberQRDataResultStub: .success(.empty())
        )
        
        let viewModelsFactory: MainViewModelsFactory = .init(
            makeAuthFactory: { ModelAuthLoginViewModelFactory(model: $0, rootActions: $1)},
            makeProductProfileViewModel: { _,_,_,_ in nil },
            makePromoProductViewModel: { $0.mapper(md5Hash: $0.md5hash, onTap: $1.show, onHide: $1.hide)},
            qrViewModelFactory: .preview()
        )

        let sut = MainViewModel(
            model,
            navigationStateManager: .preview,
            sberQRServices: sberQRServices,
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
                makeSavingsAccountBinder: { fatalError() }
            ),
            viewModelsFactory: viewModelsFactory,
            makeOpenNewProductButtons: { _ in buttons },
            scheduler: scheduler
        )
        
        // trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    typealias MainSectionViewVM = MainSectionProductsView.ViewModel
    typealias StickerViewModel = AdditionalProductViewModel
    
    private func makeSUTWithSpy(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainSectionViewVM,
        promoSpy: ValueSpy<ProductCarouselViewModelAction.Products.PromoDidTapped>
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = MainSectionViewVM(model, promoProducts: nil)
        
        let spy = ValueSpy(
            sut.productCarouselViewModel.action.compactMap { $0 as? ProductCarouselViewModelAction.Products.PromoDidTapped })

        // trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }

    private func makeSUTWithMainSectionProductsViewVM(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainSectionViewVM,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = MainSectionViewVM(model, promoProducts: nil)
        
        // trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, model)
    }
    
    private func makeModelWithServerAgentStub(
        getC2bResponseStub: [ServerAgentTestStub.Stub],
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        buttons: [NewProductButton.ViewModel] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainViewModel,
        model: Model
    ) {
        
        let sessionAgent = ActiveSessionAgentStub()
        let serverAgent = ServerAgentTestStub(getC2bResponseStub)
        
        let model: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent
        )
        model.clientInfo.value = makeClientInfoDummy()
        
        let sut = MainViewModel(
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
                makeSavingsAccountBinder: { fatalError() }
            ),
            viewModelsFactory: .preview,
            makeOpenNewProductButtons: { _ in buttons },
            scheduler: scheduler
        )
        
        // trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    private func getC2bResponseStub() -> [ServerAgentTestStub.Stub] {
        
        [
            .getC2bSubscriptions(.success(.init(
                statusCode: .ok,
                errorMessage: nil,
                data: .init(
                    title: "title",
                    subscriptionType: .control,
                    emptySearch: nil,
                    emptyList: nil,
                    list: nil
                ))
            ))
        ]
    }
    
    private func makeClientInfoDummy() -> ClientInfoData {
        
        .init(
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
    
    private func makeLocalAgentForSticker(
        md5hash: String = "md5hash"
    ) throws -> LocalAgent {
        
        let localAgent = LocalAgent(context: LocalAgentTests.context)
        let stickerData: StickerBannersMyProductList = .init(
            productName: "productName",
            link: "link",
            md5hash: md5hash,
            action: nil)
        
        try localAgent.store([stickerData])
        try localAgent.store([md5hash: ImageData.tiny()])
        return localAgent
    }
    
    private func assert(
        sections: [MainSectionViewModel],
        count: Int,
        type: MainSectionType,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        XCTAssertNoDiff(
            sections.count,
            count,
            "\nExpected \(count), but got \(sections.count) instead.",
            file: file, line: line
        )
        
        XCTAssertNoDiff(
            sections.first?.type,
            type,
            "\nExpected \(type), but got \(sections.first?.type) instead.",
            file: file, line: line
        )
    }
    
    // MARK: Helpers
        
    var previewAsyncImage: UIPrimitives.AsyncImage { AsyncImage(
        image: .init(systemName: "car"),
        publisher: Just(.init(systemName: "house"))
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    )}
}

private func anySberQRError() -> MainViewModelTests.SberQRError {
    
    .createRequest(anyError("SberQRPayment Failure"))
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
    
    static let preview: GetShowcaseDomain.Content = .init(
        initialState: .init(),
        reduce: { state,_ in (state, nil) },
        handleEffect: { _,_ in }
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

private extension MainViewModel {
    
    var fastPayment: MainSectionFastOperationView.ViewModel? {
        
        sections.compactMap {
            
            $0 as? MainSectionFastOperationView.ViewModel
        }
        .first
    }
    
    var templatesListViewModel: TemplatesListViewModel? {
        
        switch route.destination {
        case let .templates(node):
            return node.model.state.content
            
        default:
            return nil
        }
    }
    
    var openProductSection: MainSectionOpenProductView.ViewModel? {
        
        sections.compactMap {
            
            $0 as? MainSectionOpenProductView.ViewModel
        }
        .first
    }
    
    var authProductsViewModel: AuthProductsViewModel? {
        
        switch route.destination {
        case let .openCard(authProductsViewModel):
            return authProductsViewModel
            
        default:
            return nil
        }
    }
    
    var landingWrapperViewModel: LandingWrapperViewModel? {
        
        switch route.destination {
        case let .landing(landingViewModel, _):
            return landingViewModel
            
        default:
            return nil
        }
    }

    var currencyWalletSection: MainSectionCurrencyMetallView.ViewModel? {
        
        sections.compactMap {
            
            $0 as? MainSectionCurrencyMetallView.ViewModel
        }
        .first
    }
    
    var mainSection: MainSectionProductsView.ViewModel? {
        
        sections.compactMap {
            
            $0 as? MainSectionProductsView.ViewModel
        }
        .first
    }
}

private extension MainViewModel.Route {
    
    var `case`: Case? {
        
        switch destination {
        case .none:
            return .none
        case .currencyWallet:
            return .currencyWallet
        case .landing:
            return .landing
        case .myProducts:
            return .myProducts
        case .openCard:
            return .openCard
        case .openDepositsList:
            return .openDepositsList
        case .payments:
            return .payments
        case .paymentSticker:
            return .paymentSticker
        case .productProfile:
            return .productProfile
        case .templates:
            return .templates
            
        default:
            return .other
        }
    }
    
    enum Case: Equatable {
        
        case currencyWallet
        case landing
        case myProducts
        case openCard
        case openDepositsList
        case other
        case payments
        case paymentSticker
        case productProfile
        case templates
    }
}

private extension MainViewModel.Modal {
    
    var `case`: Case? {
        
        switch self {
        case let .fullScreenSheet(fullScreenSheet):
            switch fullScreenSheet.type {
            case .qrScanner: return .qrScanner
            case .success: return .success
            }
        case let .sheet(sheet):
            switch sheet.type {
            case .byPhone: return .byPhone
            default: return .other
            }
        case .alert:
            return .alert
        case let .bottomSheet(bottomSheet):
            switch bottomSheet.type {
            case .openAccount: return .openAccount
            case .clientInform: return .clientInform
            }
        }
    }
    
    enum Case: Equatable {
        
        case alert
        case byPhone
        case clientInform
        case openAccount
        case other
        case qrScanner
        case success
    }
}

private extension MainViewModel {
    
    func tapOpenCollateralLoanLandingButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let section = sections.compactMap {
            
            $0 as? MainSectionOpenProductView.ViewModel
        }.first
        
        let openProductSection = try XCTUnwrap(section, file: file, line: line)

        let openCollateralLoanLandingAction =
        MainSectionViewModelAction.OpenProduct.ButtonTapped(productType: .loan)
        openProductSection.action.send(openCollateralLoanLandingAction)
    }
}

private extension MainSectionFastOperationView.ViewModel {
    
    func tapFastPaymentButton(type: FastOperations) {
        
        let fastPaymentAction = MainSectionViewModelAction.FastPayment.ButtonTapped.init(operationType: type)
        action.send(fastPaymentAction)
    }
    
    func tapFastPaymentButtonAndWait(type: FastOperations, timeout: TimeInterval = 0.1) {
        
        tapFastPaymentButton(type: type)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainSectionOpenProductView.ViewModel {
    
    func tapOpenProductButton(type: OpenProductType) {
        
        let openProductAction = MainSectionViewModelAction.OpenProduct.ButtonTapped.init(productType: type)
        action.send(openProductAction)
    }
    
    func tapOpenProductButtonAndWait(type: OpenProductType, timeout: TimeInterval = 0.05) {
        
        tapOpenProductButton(type: type)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainSectionCurrencyMetallView.ViewModel {
    
    enum ActionType {
        case buy, item, sell
    }
    
    func tapCurrencyWalletButton(
        currency: Currency,
        actionType: ActionType
    ) {
        let currencyAction: Action = {
            switch actionType {
            case .buy:
                return MainSectionViewModelAction.CurrencyMetall.DidTapped.Buy(code: currency)
                
            case .item:
                return MainSectionViewModelAction.CurrencyMetall.DidTapped.Item(code: currency)
                
            case .sell:
                return MainSectionViewModelAction.CurrencyMetall.DidTapped.Sell(code: currency)
            }
        }()
        action.send(currencyAction)
    }
    
    func tapCurrencyWalletButtonAndWait(
        currency: Currency,
        actionType: ActionType,
        timeout: TimeInterval = 0.05
    ) {
        tapCurrencyWalletButton(currency: currency, actionType: actionType)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension TemplatesListViewModel {
    
    func closeAndWait(timeout: TimeInterval = 0.1) {
        
        action.send(TemplatesListViewModelAction.CloseAction())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainViewModel {
    
    func tapUserAccount(timeout: TimeInterval = 0.05) {
        
        action.send(MainViewModelAction.ButtonTapped.UserAccount())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainViewModel {
    
    func closeAndWait(timeout: TimeInterval = 0.05) {
        
        action.send(MainViewModelAction.Close.Link())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainSectionOpenProductView.ViewModel {
    
    func tapPromoProductAndWait(
        _ promo: PromoProduct,
        timeout: TimeInterval = 0.05
    ) {
        let stickerAction = MainSectionViewModelAction.Products.PromoDidTapped(promo: promo)
        action.send(stickerAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension ProductCarouselView.ViewModel {
    
    func showPromoProductAndWait(
        _ promo: PromoProduct,
        timeout: TimeInterval = 0.05
    ) {
        
        let promoAction = ProductCarouselViewModelAction.Products.PromoDidTapped(promo: promo)
        action.send(promoAction)

        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainSectionProductsView.ViewModel {
    
    func showPromoProduct(
        _ promo: PromoProduct
    ) {
        
        let promoAction = MainSectionViewModelAction.Products.PromoDidTapped(promo: promo)
        action.send(promoAction)
    }
    
    func showPromoProductAndWait(
        _ promo: PromoProduct,
        timeout: TimeInterval = 0.05
    ) {
        
        showPromoProduct(promo)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func openMoreProduct() {
        
        let moreAction = MainSectionViewModelAction.Products.MoreButtonTapped()
        action.send(moreAction)
    }
    
    func openMoreProductAndWait(timeout: TimeInterval = 0.05) {
        
        openMoreProduct()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func openProductProfile(productId: Int) {
        
        let productProfileAction = MainSectionViewModelAction.Products.ProductDidTapped(productId: productId)
        action.send(productProfileAction)
    }
    
    func openProductProfileAndWait(productId: Int, timeout: TimeInterval = 0.1) {
        
        openProductProfile(productId: productId)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension ProductCardData {
    
    convenience init(id: Int, currency: Currency, ownerId: Int = 0, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .active, loanBaseParam: ProductCardData.LoanBaseParamInfoData? = nil, statusPc: ProductData.StatusPC = .active, isMain: Bool = true) {
        
        self.init(id: id, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: ownerId, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "", validThru: Date(), status: status, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: loanBaseParam, statusPc: statusPc, isMain: isMain, externalId: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}

private extension MainViewModelTests {
    
    static let cardActiveMainDebitOnlyMain = ProductCardData(id: 11, currency: .rub, allowCredit: false)
    static let cardBlockedMainRub = ProductCardData(id: 12, currency: .rub, status: .blocked, statusPc: .blockedByBank)
    
    static let cardActiveAddUsdIsMainFalse = ProductCardData(id: 22, currency: .usd, isMain: false)
    static let cardActiveAddUsdIsMainTrue = ProductCardData(id: 21, currency: .usd)
}

private extension MainViewModelTests {
    
    static let cardProducts = [cardActiveAddUsdIsMainFalse,
                               cardActiveAddUsdIsMainTrue]
}

private extension CurrencyWalletData {
    
    static let rub: Self = .init(
        code: "RUB",
        rateBuy: 100,
        rateBuyDelta: nil,
        rateSell: 100,
        rateSellDelta: nil,
        md5hash: "",
        currAmount: 1,
        nameCw: ""
    )
}

private extension OpenAccountProductData {
    
    static let test: Self = .init(currencyAccount: "", open: true, breakdownAccount: "", accountType: "", currencyCode: 810, currency: .rub, designMd5hash: "", designSmallMd5hash: "", detailedConditionUrl: "", detailedRatesUrl: nil, txtConditionList: [.init(name: "", description: "", type: .green)])
}
