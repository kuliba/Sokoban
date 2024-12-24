//
//  MainViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 19.09.2023.
//

@testable import Vortex
import LandingUIComponent
import SberQR
import XCTest

final class MainViewModelTests: XCTestCase {
    
    func test_init_cacheNotContainsSticker_shouldSetStickerToNil()  {
        
        let (sut, _) = makeSUT()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNil(sut.sections.stickerViewModel)
    }
    
    func test_init_cacheContainsSticker_shouldSetSticker() throws {
        
        let (sut, _) = makeSUTWithLocalAgent(localAgent: try makeLocalAgentForSticker())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNotNil(sut.sections.stickerViewModel)
    }
    
    func test_updateImages_imageNotSticker_shouldNotUpdateSticker() {
        
        let (sut, model) = makeSUT()
        let stickerSpy = ValueSpy(sut.$sections.map(\.stickerViewModel?.backgroundImage))
        XCTAssertNoDiff(stickerSpy.values, [nil])
        
        model.images.value = ["1": .tiny()]
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(stickerSpy.values, [nil, nil])
    }
    
    func test_tapTemplates_shouldSetLinkToTemplates() {
        
        let (sut, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$route.map(\.case))
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.fastPayment?.tapFastPaymentButtonAndWait(type: .templates)
        
        XCTAssertNoDiff(linkSpy.values, [nil, .templates])
    }
    
    func test_tapTemplates_shouldNotSetLinkToNilOnTemplatesCloseUntilDelay() {
        
        let (sut, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$route.map(\.case))
        sut.fastPayment?.tapFastPaymentButtonAndWait(type: .templates)
        
        sut.templatesListViewModel?.closeAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .templates])
    }
    
    func test_tapUserAccount_shouldSendGetSubscriptionRequest() {
        
        let (sut, model) = makeModelWithServerAgentStub(
            getC2bResponseStub: getC2bResponseStub()
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
        
        let (sut, _) = makeSUTWithMainSectionProductsViewVM()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        let sutActionSpy = ValueSpy(
            sut.productCarouselViewModel.action.compactMap { $0 as? ProductCarouselViewModelAction.Products.StickerDidTapped })
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertNoDiff(sutActionSpy.values.count, 0)
        
        sut.productCarouselViewModel.action.send(ProductCarouselViewModelAction.Products.StickerDidTapped())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertNoDiff(sutActionSpy.values.count, 1)
        
        XCTAssertNotNil(sutActionSpy.values.first)
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
            makeProductProfileViewModel: {
                _,_,_,_   in nil
            },
            navigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            landingServices: .empty(),
            paymentsTransfersFactory: .preview,
            updateInfoStatusFlag: .inactive,
            onRegister: {},
            sections: makeSections(),
            bannersBinder: .preview,
            makeCollateralLoanLandingViewModel: { _ in .init(
                initialState: .init(),
                reduce: CollateralLoanLandingDomain.Reducer().reduce(_:_:),
                handleEffect: { _,_ in }
            ) },
            makeOpenNewProductButtons: { [weak self] _ in
                guard let self else { return [] }
                return self.makeOpenNewProductButtons()
            }
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
        
        let (sut, model) = makeSUT()
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.modal)
        
        sut.fastPayment?.tapFastPaymentButtonAndWait(type: .byPhone)
        
        XCTAssertNotNil(sut.route.modal?.alert)
    }
    
    func test_tapByPhone_notOnlyCorporateCards_shouldSetModalToByPhone() {
        
        let (sut, model) = makeSUT()
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.modal)
        
        sut.fastPayment?.tapFastPaymentButtonAndWait(type: .byPhone)
        
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
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        model.accountProductsList.value = [.test]
        XCTAssertNil(sut.route.destination)
        
        sut.openProductSection?.tapOpenProductButtonAndWait(type: .account)
        
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
        
        sut.openProductSection?.tapOpenProductButtonAndWait(type: .loan)
        
        XCTAssertNoDiff(sut.route.case, .landing)
    }
    
    func test_productsSection_tapOpenSticker_shouldSetRouteToLanding() {
        
        let (sut, _) = makeSUT()
        XCTAssertNil(sut.route.destination)
        
        sut.mainSection?.showStickerAndWait()
        
        XCTAssertNoDiff(sut.route.case, .landing)
    }
    
    func test_productsSection_tapMoreProduct_shouldSetRouteToMyProducts() {
        
        let (sut, _) = makeSUT()
        XCTAssertNil(sut.route.destination)
        
        sut.mainSection?.openMoreProductAndWait()
        
        XCTAssertNoDiff(sut.route.case, .myProducts)
    }
    
    func test_productsSection_tapProductProfile_shouldSetRouteToProductProfile() {
        
        let (sut, model) = makeSUT()
        let productID = 1
        model.products.value[.card] = [makeCardProduct(id: productID, cardType: .main, isMain: true)]
        XCTAssertNil(sut.route.destination)
        
        sut.mainSection?.openProductProfileAndWait(productId: productID)
        
        XCTAssertNoDiff(sut.route.case, .productProfile)
    }
    
    func test_tapCurrencyWallet_buy_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.currencyWalletSection?.tapCurrencyWalletButtonAndWait(currency: .rub, actionType: .buy)
        
        XCTAssertNoDiff(sut.route.modal?.case, .alert)
    }
    
    func test_tapCurrencyWallet_buy_notOnlyCorporateCards_shouldSetRouteToCurrencyWallet() {
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.currencyWalletSection?.tapCurrencyWalletButtonAndWait(currency: .rub, actionType: .buy)
        
        XCTAssertNoDiff(sut.route.case, .currencyWallet)
    }
    
    func test_tapCurrencyWallet_item_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.currencyWalletSection?.tapCurrencyWalletButtonAndWait(currency: .rub, actionType: .item)
        
        XCTAssertNoDiff(sut.route.modal?.case, .alert)
    }
    
    func test_tapCurrencyWallet_item_notOnlyCorporateCards_shouldSetRouteToCurrencyWallet() {
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.currencyWalletSection?.tapCurrencyWalletButtonAndWait(currency: .rub, actionType: .item)
        
        XCTAssertNoDiff(sut.route.case, .currencyWallet)
    }
    
    func test_tapCurrencyWallet_sell_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate)
        ]
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.currencyWalletSection?.tapCurrencyWalletButtonAndWait(currency: .rub, actionType: .sell)
        
        XCTAssertNoDiff(sut.route.modal?.case, .alert)
    }
    
    func test_tapCurrencyWallet_sell_notOnlyCorporateCards_shouldSetRouteToCurrencyWallet() {
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.currencyWalletSection?.tapCurrencyWalletButtonAndWait(currency: .rub, actionType: .sell)
        
        XCTAssertNoDiff(sut.route.case, .currencyWallet)
    }
    
    func test_openMigTransfer_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
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
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.openMigTransfer(.init(countryId: "810"))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertNoDiff(sut.route.case, .payments)
    }
    
    func test_openContactTransfer_onlyCorporateCards_shouldShowAlert() {
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
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
        
        let (sut, model) = makeSUT(currencyList: [.rub], currencyWalletList: [.rub])
        
        model.products.value[.card] = [
            makeCardProduct(id: 1, cardType: .individualBusinessman),
            makeCardProduct(id: 2, cardType: .corporate),
            makeCardProduct(id: 3, cardType: .main, isMain: true),
        ]
        
        XCTAssertNil(sut.route.destination)
        
        sut.openContactTransfer(.init(countryId: "810"))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
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
        
        let (sut, model) = makeSUT(updateInfoStatusFlag: .inactive)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(false, for: .card)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(false, for: .loan)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(false, for: .deposit)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(false, for: .account)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(true, for: .card)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(true, for: .loan)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(true, for: .deposit)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 6, type: .products)
        
        model.updateInfo.value.setValue(true, for: .account)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        assert(sections: sut.sections, count: 6, type: .products)
    }
    
    // MARK: - handleLandingAction
    
    func test_handleLandingAction_shouldSetDestinationToLanding() {
        
        let (sut, _) = makeSUT()
        let type = anyMessage()
        
        XCTAssertNil(sut.route.destination)
        XCTAssertNil(sut.route.modal)
        
        sut.handleLandingAction(type)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(sut.route.case, .landing)
        XCTAssertNil(sut.route.modal)
    }
    
    func test_landingAction_tapGoToBack_shouldSetDestinationToNil() {
        
        let (sut, _) = makeSUT()
        let type = anyMessage()
        
        let destinationSpy = ValueSpy(sut.$route.map(\.case))
        
        sut.handleLandingAction(type)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        sut.landingWrapperViewModel?.action(.goToBack)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(destinationSpy.values, [nil, .landing, nil])
    }
    
    // MARK: - Helpers
    fileprivate typealias SberQRError = MappingRemoteServiceError<MappingError>
    private typealias GetSberQRDataResult = SberQRServices.GetSberQRDataResult
    
    private func makeSUT(
        createSberQRPaymentStub: CreateSberQRPaymentResult = .success(.empty()),
        getSberQRDataResultStub: GetSberQRDataResult = .success(.empty()),
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag = .inactive,
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
        
        let sut = MainViewModel(
            model,
            makeProductProfileViewModel: { _,_,_,_ in .sample },
            navigationStateManager: .preview,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            landingServices: .empty(),
            paymentsTransfersFactory: .preview,
            updateInfoStatusFlag: updateInfoStatusFlag,
            onRegister: {},
            sections: makeSections(),
            bannersBinder: .preview,
            makeCollateralLoanLandingViewModel: { _ in .init(
                initialState: .init(),
                reduce: CollateralLoanLandingDomain.Reducer().reduce(_:_:),
                handleEffect: { _,_ in }
            ) },
            makeOpenNewProductButtons: { [weak self] _ in
                guard let self else { return [] }
                return self.makeOpenNewProductButtons()
            }
        )
        
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(sut, file: file, line: line)
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    private func makeOpenNewProductButtons() -> [NewProductButton.ViewModel] {
        
        let displayButtonsTypes: [ProductType] = [.card, .deposit, .account, .loan]
        
        let displayButtons: [String] = {
            
            var items = (displayButtonsTypes.map { $0.rawValue } + ["INSURANCE", "MORTGAGE"])
            items.insert(contentsOf: ["STICKER"], at: 3)
            return items
        }()
        
        var viewModels: [NewProductButton.ViewModel] = []
        
        for typeStr in displayButtons {
            
            if let type = ProductType(rawValue: typeStr) {
                
                let id = type.rawValue
                let icon = type.openButtonIcon
                let title = type.openButtonTitle
                let subTitle = description(for: type)
                
                switch type {
                case .loan:
                        viewModels.append(.init(
                            id: id,
                            icon: icon,
                            title: title,
                            subTitle: subTitle,
                            action: {}
                        ))
                    
                default:
                    viewModels.append(
                        NewProductButton.ViewModel(
                            id: id,
                            icon: icon,
                            title: title,
                            subTitle: subTitle,
                            action: {}
                        ))
                }
                
                } else { //no ProductType
                   
                    switch typeStr {
                    case "INSURANCE":
                        viewModels.append(NewProductButton.ViewModel(id: typeStr, icon: .ic24InsuranceColor, title: "Страховку", subTitle: "Надежно", url: URL(string: "www.home.com")!))
                        
                    case "MORTGAGE":
                        viewModels.append(NewProductButton.ViewModel(id: typeStr, icon: .ic24Mortgage, title: "Ипотеку", subTitle: "Удобно", url: URL(string: "www.home.com")!))
                    
                    case "STICKER":
                        viewModels.append(NewProductButton.ViewModel(
                            id: typeStr,
                            icon: .ic24Sticker,
                            title: "Стикер",
                            subTitle: "Быстро",
                            action: {}
                        ))
                    default: break
                    }
                }
        }
        
        return viewModels   
    }
    
    func description(for type: ProductType) -> String {
        
        switch type {
        case .card: return "С кешбэком"
        case .account: return "Бесплатно"
        case .deposit: return "22,5%"
        case .loan: return "Выгодно"
        }
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
    
    private func makeSUTWithLocalAgent(
        localAgent: LocalAgent,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainViewModel,
        model: Model
    ) {
        let model: Model = Model.mockWithEmptyExcept(localAgent: localAgent)
        let sberQRServices = SberQRServices.preview(
            createSberQRPaymentResultStub: .success(.empty()),
            getSberQRDataResultStub: .success(.empty())
        )
        
        let sut = MainViewModel(
            model,
            makeProductProfileViewModel: { _,_,_,_   in nil },
            navigationStateManager: .preview,
            sberQRServices: sberQRServices,
            qrViewModelFactory: .preview(),
            landingServices: .empty(),
            paymentsTransfersFactory: .preview,
            updateInfoStatusFlag: .inactive,
            onRegister: {},
            sections: makeSections(),
            bannersBinder: .preview,
            makeCollateralLoanLandingViewModel: { _ in .init(
                initialState: .init(),
                reduce: CollateralLoanLandingDomain.Reducer().reduce(_:_:),
                handleEffect: { _,_ in }
            ) },
            makeOpenNewProductButtons: { [weak self] _ in
                guard let self else { return [] }
                return self.makeOpenNewProductButtons()
            }
        )
        
        // trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    private func makeSUT(
        currencyList: [CurrencyData],
        currencyWalletList: [CurrencyWalletData],
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
        
        let sut = MainViewModel(
            model,
            makeProductProfileViewModel: { _,_,_,_   in nil },
            navigationStateManager: .preview,
            sberQRServices: sberQRServices,
            qrViewModelFactory: .preview(),
            landingServices: .empty(),
            paymentsTransfersFactory: .preview,
            updateInfoStatusFlag: .inactive,
            onRegister: {},
            sections: makeSections(),
            bannersBinder: .preview,
            makeCollateralLoanLandingViewModel: { _ in .init(
                initialState: .init(),
                reduce: CollateralLoanLandingDomain.Reducer().reduce(_:_:),
                handleEffect: { _,_ in }
            ) },
            makeOpenNewProductButtons: { [weak self] _ in
                guard let self else { return [] }
                return self.makeOpenNewProductButtons()
            }
        )
        
        // trackForMemoryLeaks(sut, file: file, line: line)
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    typealias MainSectionViewVM = MainSectionProductsView.ViewModel
    typealias StickerViewModel = ProductCarouselView.StickerViewModel
    
    private func makeSUTWithMainSectionProductsViewVM(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: MainSectionViewVM,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = MainSectionViewVM(model, stickerViewModel: nil)
        
        // trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, model)
    }
    
    private func makeModelWithServerAgentStub(
        getC2bResponseStub: [ServerAgentTestStub.Stub],
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
            makeProductProfileViewModel: { _,_,_,_   in nil },
            navigationStateManager: .preview,
            sberQRServices: .empty(),
            qrViewModelFactory: .preview(),
            landingServices: .empty(),
            paymentsTransfersFactory: .preview,
            updateInfoStatusFlag: .inactive,
            onRegister: {},
            sections: makeSections(),
            bannersBinder: .preview,
            makeCollateralLoanLandingViewModel: { _ in .init(
                initialState: .init(),
                reduce: CollateralLoanLandingDomain.Reducer().reduce(_:_:),
                handleEffect: { _,_ in }
            ) },
            makeOpenNewProductButtons: { [weak self] _ in
                guard let self else { return [] }
                return self.makeOpenNewProductButtons()
            }
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
}

private func anySberQRError() -> MainViewModelTests.SberQRError {
    
    .createRequest(anyError("SberQRPayment Failure"))
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

private extension MainSectionFastOperationView.ViewModel {
    
    func tapFastPaymentButtonAndWait(type: FastOperations, timeout: TimeInterval = 0.1) {
        
        let fastPaymentAction = MainSectionViewModelAction.FastPayment.ButtonTapped.init(operationType: type)
        action.send(fastPaymentAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainSectionOpenProductView.ViewModel {
    
    func tapOpenProductButtonAndWait(type: ProductType, timeout: TimeInterval = 0.05) {
        
        let openProductAction = MainSectionViewModelAction.OpenProduct.ButtonTapped.init(productType: type)
        action.send(openProductAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainSectionCurrencyMetallView.ViewModel {
    
    enum ActionType {
        case buy, item, sell
    }
    
    func tapCurrencyWalletButtonAndWait(
        currency: Currency,
        actionType: ActionType,
        timeout: TimeInterval = 0.05) {
            
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
    
    func tapStickerAndWait(timeout: TimeInterval = 0.05) {
        let stickerAction = MainSectionViewModelAction.Products.StickerDidTapped()
        action.send(stickerAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension MainSectionProductsView.ViewModel {
    
    func showStickerAndWait(timeout: TimeInterval = 0.05) {
        
        let stickerAction = MainSectionViewModelAction.Products.StickerDidTapped()
        action.send(stickerAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func openMoreProductAndWait(timeout: TimeInterval = 0.05) {
        
        let moreAction = MainSectionViewModelAction.Products.MoreButtonTapped()
        action.send(moreAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func openProductProfileAndWait(productId: Int, timeout: TimeInterval = 0.1) {
        
        let productProfileAction = MainSectionViewModelAction.Products.ProductDidTapped(productId: productId)
        action.send(productProfileAction)
        
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

extension MainSectionViewModelAction.Products.StickerDidTapped: Equatable {
    public static func == (lhs: MainSectionViewModelAction.Products.StickerDidTapped, rhs: MainSectionViewModelAction.Products.StickerDidTapped) -> Bool { return true }
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
