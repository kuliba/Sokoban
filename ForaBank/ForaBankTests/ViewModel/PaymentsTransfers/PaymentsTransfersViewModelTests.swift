//
//  PaymentsTransfersViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 04.07.2023.
//

@testable import ForaBank
import SberQR
import XCTest

final class PaymentsTransfersViewModelTests: XCTestCase {
    
    func test_shouldFailOnEmptyProducts() throws {
        
        let (sut, model, _) = makeSUT()
        
        sut.sendBetweenSelf()
        
        XCTAssertNil(sut.meToMe)
        XCTAssertTrue(model.products.value.isEmpty)
    }
    
    func test_meToMe_shouldDeliverActionOnMeToMeSendSuccess() throws {
        
        let (product1, product2) = makeTwoProducts()
        let (sut, model, _) = makeSUT(products: [product1, product2])
        
        sut.sendBetweenSelf()
        
        XCTAssertNoDiff(try sut.selectedMeToMeProductTitles(), ["Откуда"])
        
        try sut.selectMeToMeProductTo(product2, model: model)
        let spy = ValueSpy(model.action)
        
        XCTAssertNoDiff(try sut.selectedMeToMeProductTitles(), ["Откуда", "WhereTo"])
        
        XCTAssertEqual(spy.values.count, 0)
        
        sut.meToMeSendSuccess(model: model)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertEqual(spy.values.count, 4)
    }
    
    #warning("fix and restore")
//    func test_meToMe_shouldNotDeliverActionsAfterBottomSheetClosed() throws {
//        
//        let (product1, product2) = makeTwoProducts()
//        let (sut, model, _) = makeSUT(products: [product1, product2])
//        
//        sut.sendBetweenSelf()
//        
//        XCTAssertNoDiff(try sut.selectedMeToMeProductTitles(), ["Откуда"])
//        
//        try sut.selectMeToMeProductTo(product2, model: model)
//        let spy = ValueSpy(model.action)
//        
//        XCTAssertNoDiff(try sut.selectedMeToMeProductTitles(), ["Откуда", "WhereTo"])
//        
//        XCTAssertEqual(spy.values.count, 0)
//        
//        sut.meToMeSendSuccess(model: model)
//        XCTAssertEqual(spy.values.count, 0)
//        sut.closeBottomSheet()
//        
//        XCTAssertEqual(spy.values.count, 0)
//        XCTAssertNil(sut.meToMe)
//    }
    
    func test_tapTemplates_shouldSetLinkToTemplates() {
         
         let (sut, _,_) = makeSUT()
        let linkSpy = ValueSpy(sut.$route.map(\.case))
         XCTAssertNoDiff(linkSpy.values, [.other])
         
         sut.section?.tapTemplatesAndWait()
         
         XCTAssertNoDiff(linkSpy.values, [.other, .template])
     }
    
    func test_tapTemplates_shouldNotSetLinkToNilOnTemplatesCloseUntilDelay() {
        
        let (sut, _,_) = makeSUT()
        let linkSpy = ValueSpy(sut.$route.map(\.case))
        sut.section?.tapTemplatesAndWait()
        
        sut.templatesListViewModel?.closeAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [.other, .template])
    }
    
    func test_tapTemplates_shouldSetLinkToNilOnTemplatesClose() {
        
        let (sut, _,_) = makeSUT()
        let linkSpy = ValueSpy(sut.$route.map(\.case))
        sut.section?.tapTemplatesAndWait()
        
        sut.templatesListViewModel?.closeAndWait(timeout: 0.9)
        
        XCTAssertNoDiff(linkSpy.values, [.other, .template, .other])
    }
    
    // MARK: - event(_:)
    
    func test_init_shouldNotSetDestination() {
        
        let (sut, _,_) = makeSUT()
        let spy = ValueSpy(sut.$route.map(\.destination?.id))
        
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    func test_addCompany_shouldNotChangeDestination() {
        
        let (sut, _,_) = makeSUT()
        let spy = ValueSpy(sut.$route.map(\.destination?.id))
        
        sut.event(.addCompany)
        
        XCTAssertNoDiff(spy.values, [nil, nil])
    }
    
    func test_addCompany_shouldNotDeliverEffect() {
        
        let (sut, _, effectSpy) = makeSUT()
        
        sut.event(.addCompany)
        
        XCTAssertNoDiff(effectSpy.messages.map(\.effect), [])
    }
    
    func test_latestPaymentTapped_shouldNotChangeDestination() {
        
        let (sut, _,_) = makeSUT()
        let spy = ValueSpy(sut.$route.map(\.destination?.id))
        
        sut.event(.latestPaymentTapped(.init()))
        
        XCTAssertNoDiff(spy.values, [nil, nil])
    }
    
    func test_latestPaymentTapped_shouldDeliverEffect() {
        
        let latestPayment = UtilitiesViewModel.LatestPayment()
        let (sut, _, effectSpy) = makeSUT()
        
        sut.event(.latestPaymentTapped(latestPayment))

        XCTAssertNoDiff(effectSpy.messages.map(\.effect), [
            .startPayment(.latestPayment(latestPayment))
        ])
    }
    
    // MARK: SBER QR
    
    func test_sberQR_shouldPresentErrorAlertOnGetSberQRDataInvalidFailure() throws {
        
        let (sut, _,_) = makeSUT(
            getSberQRDataResultStub: .failure(.mapResponse(
                .invalid(statusCode: 200, data: anyData())
            ))
        )
        let alertMessageSpy = ValueSpy(sut.$route.map(\.modal?.alert?.message))
        XCTAssertNoDiff(alertMessageSpy.values, [nil])
        
        try sut.scanAndWait()
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            nil,
            nil,
            "Возникла техническая ошибка"
        ])
    }
    
    func test_sberQR_shouldPresentErrorAlertWithPrimaryButtonThatDismissesAlertOnGetSberQRDataInvalidFailure() throws {
        
        let (sut, _,_) = makeSUT(
            getSberQRDataResultStub: .failure(.mapResponse(
                .invalid(statusCode: 200, data: anyData())
            ))
        )
        let alertMessageSpy = ValueSpy(sut.$route.map(\.message))

        try sut.scanAndWait()
        try sut.tapPrimaryAlertButton()
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            nil,
            nil,
            "Возникла техническая ошибка",
            nil
        ])
    }
    
    func test_sberQR_shouldPresentErrorAlertOnGetSberQRDataServerFailure() throws {
        
        let (sut, _,_) = makeSUT(
            getSberQRDataResultStub: .failure(.mapResponse(
                .server(statusCode: 200, errorMessage: UUID().uuidString)
            ))
        )
        let alertMessageSpy = ValueSpy(sut.$route.map(\.message))
        XCTAssertNoDiff(alertMessageSpy.values, [nil])
        
        try sut.scanAndWait()
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            nil,
            nil,
            "Возникла техническая ошибка"
        ])
    }
    
    func test_sberQR_shouldPresentErrorAlertWithPrimaryButtonThatDismissesAlertOnGetSberQRDataServerFailure() throws {
        
        let (sut, _,_) = makeSUT(
            getSberQRDataResultStub: .failure(.mapResponse(
                .server(statusCode: 200, errorMessage: UUID().uuidString)
            ))
        )
        let alertMessageSpy = ValueSpy(sut.$route.map(\.message))
        
        try sut.scanAndWait()
        try sut.tapPrimaryAlertButton()
        
        XCTAssertNoDiff(alertMessageSpy.values, [
            nil,
            nil,
            nil,
            "Возникла техническая ошибка",
            nil
        ])
    }
    
    func test_sberQR_shouldNotSetAlertOnSuccess() throws {
        
        let (sut, _,_) = makeSUT()
        let alertMessageSpy = ValueSpy(sut.$route.map(\.message))
        
        try sut.scanAndWait()
        
        XCTAssertNoDiff(alertMessageSpy.values, [nil, nil, nil, nil])
    }
    
    func test_sberQR_shouldNavigateToSberQRPaymentWithURLAndData() throws {
        
        let sberQRURL = anyURL()
        let sberQRData = anyGetSberQRDataResponse()
        let (sut, _,_) = makeSUT(
            getSberQRDataResultStub: .success(sberQRData)
        )
        let navigationSpy = ValueSpy(sut.$route.map(\.case))
        XCTAssertNoDiff(navigationSpy.values, [.other])
        
        try sut.scanAndWait(sberQRURL)
        
        XCTAssertNoDiff(navigationSpy.values, [
            .other,
            .other,
            .other,
            .sberQRPayment
        ])
    }
    
//    func test_sberQR_shouldResetNavigationLinkOnSberQRPaymentFailure() throws {
//
//        let sberQRURL = anyURL()
//        let sberQRData = anyGetSberQRDataResponse()
//        let sberQRError = anySberQRError()
//        let (sut, _,_) = makeSUT(
//            getSberQRDataResultStub: .success(sberQRData)
//        )
//        let navigationSpy = ValueSpy(sut.$link.map(\.?.case))
//
//        try sut.scanAndWait(sberQRURL)
//        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
//
//        XCTAssertNoDiff(navigationSpy.values, [
//            nil,
//            .sberQRPayment,
//            nil
//        ])
//    }
    
//    func test_sberQR_shouldPresentErrorAlertOnSberQRPaymentFailure() throws {
//
//        let (sut, _,_) = makeSUT(
//            createSberQRPaymentResultStub: .failure(anySberQRError())
//        )
//        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
//
//        try sut.scanAndWait(anyURL())
//        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
//
//        XCTAssertNoDiff(alertMessageSpy.values, [
//            nil,
//            "Возникла техническая ошибка"
//        ])
//    }
    
//    func test_sberQR_shouldPresentErrorAlertWithPrimaryButtonThatDismissesAlertOnSberQRPaymentFailure() throws {
//
//        let (sut, _,_) = makeSUT(
//            createSberQRPaymentResultStub: .failure(anySberQRError())
//        )
//        let alertMessageSpy = ValueSpy(sut.$alert.map(\.?.message))
//
//        try sut.scanAndWait(anyURL())
//        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
//        try sut.tapPrimaryAlertButton()
//
//        XCTAssertNoDiff(alertMessageSpy.values, [
//            nil,
//            "Возникла техническая ошибка",
//            nil
//        ])
//    }
    
    // MARK: - Helpers
    
    fileprivate typealias SberQRError = MappingRemoteServiceError<MappingError>
    private typealias GetSberQRDataResult = SberQRServices.GetSberQRDataResult
    
    private typealias EffectSpy = EffectHandlerSpy<Event, Effect>
    private typealias State = PaymentsTransfersViewModel.Route
    private typealias Event = PaymentsTransfersEvent
    private typealias Effect = PaymentsTransfersEffect

    private func makeTwoProducts() -> (ProductData, ProductData) {
        let product1 = anyProduct(id: 1, productType: .card, currency: "RUB")
        let product2 = anyProduct(id: 2, productType: .card, currency: "USD")
        
        return (product1, product2)
    }
    
    private func makeSUT(
        createSberQRPaymentResultStub: CreateSberQRPaymentResult = .success(.empty()),
        getSberQRDataResultStub: GetSberQRDataResult = .success(.empty()),
        products: [ProductData] = [],
        cvvPINServicesClient: CVVPINServicesClient = HappyCVVPINServicesClient(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: PaymentsTransfersViewModel,
        model: Model,
        effectSpy: EffectSpy
    ) {
        let model: Model = .mockWithEmptyExcept()
        if !products.isEmpty {
            model.products.value = [.card: products]
        }
        
        let sberQRServices = SberQRServices.preview(
            createSberQRPaymentResultStub: createSberQRPaymentResultStub,
            getSberQRDataResultStub: getSberQRDataResultStub
        )
        
        let qrViewModelFactory = QRViewModelFactory.preview()
        
        let effectSpy = EffectSpy()
        let navigationStateManager = PaymentsTransfersNavigationStateManager(
            reduce: { _,_ in fatalError() },
            handleEffect: effectSpy.handleEffect(_:_:)
        )
        
        let productProfileViewModel = ProductProfileViewModel.make(
            with: model,
            fastPaymentsFactory: .legacy, 
            makeUtilitiesViewModel: { _,_ in },
            paymentsTransfersNavigationStateManager: navigationStateManager,
            userAccountNavigationStateManager: .preview,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            cvvPINServicesClient: cvvPINServicesClient
        )
        
        let paymentsTransfersFactory = PaymentsTransfersFactory(
            makeUtilitiesViewModel: { _,_ in },
            makeProductProfileViewModel: productProfileViewModel,
            makeTemplatesListViewModel: { _ in .sampleComplete }
        )

        let sut = PaymentsTransfersViewModel(
            model: model,
            navigationStateManager: navigationStateManager,
            userAccountNavigationStateManager: .preview,
            sberQRServices: sberQRServices,
            qrViewModelFactory: qrViewModelFactory,
            paymentsTransfersFactory: paymentsTransfersFactory,
            scheduler: .immediate
        )
        
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(effectSpy, file: file, line: line)
        
        return (sut, model, effectSpy)
    }
}

private func anySberQRError() -> PaymentsTransfersViewModelTests.SberQRError {
    
    .createRequest(anyError("SberQRPayment Failure"))
}

// MARK: - DSL

extension PaymentsTransfersViewModel {
    
    var meToMe: PaymentsMeToMeViewModel? {
        
        guard case let .meToMe(viewModel) = route.modal?.bottomSheet?.type
        else { return nil }
        
        return viewModel
    }
    
    func sendBetweenSelf() {
        
        let betweenSelf = PTSectionTransfersViewAction.ButtonTapped.Transfer(type: .betweenSelf)
        
        sections[1].action.send(betweenSelf)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
    }
    
    func selectMeToMeProductTo(
        _ product: ProductData,
        model: Model
    ) throws {
        
        let swapViewModel = try XCTUnwrap(meToMe?.swapViewModel)
        
        swapViewModel.items[1].content = .product(
            .init(
                model,
                productData: product,
                context: .init(
                    title: "WhereTo",
                    direction: .to,
                    style: .me2me,
                    filter: .generalTo
                )
            )
        )
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
    }
    
    func selectedMeToMeProductTitles() throws -> [String] {
        
        let swapViewModel = try XCTUnwrap(meToMe?.swapViewModel)
        return swapViewModel.items.compactMap(\.product?.title)
    }
    
    func meToMeSendSuccess(model: Model) {
        
        meToMe?.action.send(PaymentsMeToMeAction.Response.Success(viewModel: .init(sections: [], adapter: .init(model: model), operation: nil)))
    }
    
    func closeBottomSheet() {
        
        route.modal = nil
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
    }
    
    var section: PaymentsTransfersSectionViewModel? {
        
        sections.first
    }
    
    var templatesListViewModel: TemplatesListViewModel? {
        
        switch route.destination {
        case let .template(templatesListViewModel):
            return templatesListViewModel
            
        default:
            return nil
        }
    }
    
    var qrScanner: QRViewModel? {
        
        guard case let .qrScanner(qrScanner) = route.modal?.fullScreenSheet?.type
        else { return nil }
        
        return qrScanner
    }
    
    func tapQRButtonAndWait(
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let qrPaymentButton = try XCTUnwrap(
            sections
                .compactMap { $0 as? PTSectionPaymentsView.ViewModel }
                .first?
                .paymentButtons
                .first { $0.type == .qrPayment },
            "Expected to have QR BUtton but got nil.",
            file: file, line: line
        )
        
        qrPaymentButton.action()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func scanAndWait(
        _ url: URL = anyURL(),
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try tapQRButtonAndWait(timeout: timeout, file: file, line: line)
        
        let qrScanner = try XCTUnwrap(qrScanner, "Expected to have a QR Scanner but got nil.", file: file, line: line)
        let result = QRViewModelAction.Result(result: .sberQR(url))
        qrScanner.action.send(result)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func tapPrimaryAlertButton(
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let alert = try XCTUnwrap(self.route.modal?.alert, "Expected to have alert but got nil.", file: file, line: line)
        alert.primary.action()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

extension ProductSelectorView.ViewModel {
    
    var product: ProductViewModel? {
        
        guard case let .product(viewModel) = content
        else { return nil }
        
        return viewModel
    }
}

private extension PaymentsTransfersViewModel.Route {
    
    var `case`: Case? {
        
        switch self.destination?.id {
        case .template:
            return .template
            
        case .sberQRPayment:
            return .sberQRPayment
            
        default:
            return .other
        }
    }
    
    enum Case: Equatable {
        
        case template
        case sberQRPayment
        case other
    }
    
    var message: String? {
        
        self.modal?.alert?.message
    }
}

private extension PaymentsTransfersSectionViewModel {
    
    func tapTemplatesAndWait(timeout: TimeInterval = 0.05) {
        
        let templatesAction = LatestPaymentsViewModelAction.ButtonTapped.Templates()
        action.send(templatesAction)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}

private extension TemplatesListViewModel {
    
    func closeAndWait(timeout: TimeInterval = 0.05) {
        
        action.send(TemplatesListViewModelAction.CloseAction())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
}
