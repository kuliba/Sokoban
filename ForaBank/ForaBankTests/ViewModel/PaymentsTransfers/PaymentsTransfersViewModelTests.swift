//
//  PaymentsTransfersViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 04.07.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsTransfersViewModelTests: XCTestCase {
    
    func test_shouldFailOnEmptyProducts() throws {
        
        let (sut, model) = makeSUT()
        
        sut.sendBetweenSelf()
        
        XCTAssertNil(sut.meToMe)
        XCTAssertTrue(model.products.value.isEmpty)
    }
    
    func test_meToMe_shouldDeliverActionOnMeToMeSendSuccess() throws {
        
        let (product1, product2) = makeTwoProducts()
        let (sut, model) = makeSUT(products: [product1, product2])
        
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
    
    func test_meToMe_shouldNotDeliverActionsAfterBottomSheetDeallocated() throws {
        
        let (product1, product2) = makeTwoProducts()
        let (sut, model) = makeSUT(products: [product1, product2])
        
        sut.sendBetweenSelf()
        
        XCTAssertNoDiff(try sut.selectedMeToMeProductTitles(), ["Откуда"])
        
        try sut.selectMeToMeProductTo(product2, model: model)
        let spy = ValueSpy(model.action)
        
        XCTAssertNoDiff(try sut.selectedMeToMeProductTitles(), ["Откуда", "WhereTo"])
        
        XCTAssertEqual(spy.values.count, 0)
        
        sut.meToMeSendSuccess(model: model)
        sut.closeBottomSheet()
        
        XCTAssertEqual(spy.values.count, 0)
        XCTAssertNil(sut.meToMe)
    }
    
    func test_tapTemplates_shouldSetLinkToTemplates() {
        
        let (sut, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        XCTAssertNoDiff(linkSpy.values, [nil])
        
        sut.section?.tapTemplatesAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .template])
    }
    
    func test_tapTemplates_shouldNotSetLinkToNilOnTemplatesCloseUntilDelay() {
        
        let (sut, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        sut.section?.tapTemplatesAndWait()
        
        sut.templatesListViewModel?.closeAndWait()
        
        XCTAssertNoDiff(linkSpy.values, [nil, .template])
    }
    
    func test_tapTemplates_shouldSetLinkToNilOnTemplatesClose() {
        
        let (sut, _) = makeSUT()
        let linkSpy = ValueSpy(sut.$link.map(\.?.case))
        sut.section?.tapTemplatesAndWait()
        
        sut.templatesListViewModel?.closeAndWait(timeout: 0.9)
        
        XCTAssertNoDiff(linkSpy.values, [nil, .template, nil])
    }
    
    // MARK: - Helpers
    
    private func makeTwoProducts() -> (ProductData, ProductData) {
        let product1 = anyProduct(id: 1, productType: .card, currency: "RUB")
        let product2 = anyProduct(id: 2, productType: .card, currency: "USD")
        
        return (product1, product2)
    }
    
    private func makeSUT(
        products: [ProductData] = [],
        cvvPINServicesClient: CVVPINServicesClient = HappyCVVPINServicesClient(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: PaymentsTransfersViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        if !products.isEmpty {
            model.products.value = [.card: products]
        }
                
        let sut = PaymentsTransfersViewModel(
            model: model,
            makeProductProfileViewModel: { product, rootView, dismissAction in
                
                ProductProfileViewModel(
                    model,
                    cvvPINServicesClient: cvvPINServicesClient,
                    product: product,
                    rootView: rootView,
                    dismissAction: dismissAction
                )
            }
        )
        
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, model)
    }
}

// MARK: - DSL

extension PaymentsTransfersViewModel {
    
    var meToMe: PaymentsMeToMeViewModel? {
        
        guard case let .meToMe(viewModel) = bottomSheet?.type
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
        
        bottomSheet = nil
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
    }
    
    var section: PaymentsTransfersSectionViewModel? {
        
        sections.first
    }
    
    var templatesListViewModel: TemplatesListViewModel? {
        
        switch link {
        case let .template(templatesListViewModel):
            return templatesListViewModel
            
        default:
            return nil
        }
    }
}

extension ProductSelectorView.ViewModel {
    
    var product: ProductViewModel? {
        
        guard case let .product(viewModel) = content
        else { return nil }
        
        return viewModel
    }
}

private extension PaymentsTransfersViewModel.Link {
    
    var `case`: Case? {
        
        switch self {
        case .template: return .template
        default:         return .other
        }
    }
    
    enum Case: Equatable {
        
        case template
        case other
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
