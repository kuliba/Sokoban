//
//  RootViewModelFactory+getQRNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 24.11.2024.
//

@testable import Vortex
import SberQR
import XCTest

final class RootViewModelFactory_getQRNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - outside
    
    func test_outside_shouldDeliverChatOnChat() {
        
        expect(.outside(.chat), toDeliver: .outside(.chat))
    }
    
    func test_outside_shouldDeliverMainOnMain() {
        
        expect(.outside(.main), toDeliver: .outside(.main))
    }
    
    func test_outside_shouldDeliverPaymentsOnPayments() {
        
        expect(.outside(.payments), toDeliver: .outside(.payments))
    }
    
    // MARK: - qrResult: c2bSubscribe
    
    func test_c2bSubscribe_shouldDeliverPayments() {
        
        expect(.qrResult(.c2bSubscribeURL(anyURL())), toDeliver: .payments)
    }
    
    func test_c2bSubscribe_shouldNotifyWithDismissOnClose() {
        
        expect(.dismiss, for: .c2bSubscribeURL(anyURL())) {
            
            switch $0 {
            case let .payments(payments):
                payments.close()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_c2bSubscribe_shouldNotifyWithDismissOnScanQR() {
        
        expect(.dismiss, for: .c2bSubscribeURL(anyURL())) {
            
            switch $0 {
            case let .payments(payments):
                payments.scanQR()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    // MARK: - qrResult: c2b
    
    func test_c2b_shouldDeliverPayments() {
        
        expect(.qrResult(.c2bURL(anyURL())), toDeliver: .payments)
    }
    
    func test_c2b_shouldNotifyWithDismissOnClose() {
        
        expect(.dismiss, for: .c2bURL(anyURL())) {
            
            switch $0 {
            case let .payments(payments):
                payments.close()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_c2b_shouldNotifyWithDismissOnScanQR() {
        
        expect(.dismiss, for: .c2bURL(anyURL())) {
            
            switch $0 {
            case let .payments(payments):
                payments.scanQR()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    // MARK: - qrResult: failure
    
    func test_failure_shouldDeliverQRFailure() {
        
        expect(.qrResult(.failure(anyQRCode())), toDeliver: .failure)
    }
    
    // MARK: - qrResult: missingINN
    
    func test_missingINN_shouldDeliverQRFailure() {
        
        expect(.qrResult(.mapped(.missingINN(anyQRCode()))), toDeliver: .failure)
    }
    
    // MARK: - qrResult: mapped: mixed
    
    func test_mixed_shouldDeliverProviderPicker() {
        
        expect(.qrResult(.mapped(.mixed(makeMixedQRResult()))), toDeliver: .providerPicker)
    }
    
    func test_mixed_shouldNotifyWithDismissOnDismiss() {
        
        expect(
            .dismiss,
            for: .mapped(.mixed(makeMixedQRResult())),
            expectedFulfillmentCount: 1
        ) {
            switch $0 {
            case let .providerPicker(node):
                node.model.event(.dismiss)
                
            default:
                XCTFail("Expected providerPicker, got \($0) instead.")
            }
        }
    }
    
    func test_mixed_shouldNotifyWithChatOnGoToAddCompany() {
        
        expect(
            .select(.outside(.chat)),
            for: .mapped(.mixed(makeMixedQRResult())),
            expectedFulfillmentCount: 3
        ) {
            switch $0 {
            case let .providerPicker(node):
                node.model.event(.goTo(.addCompany))
                
            default:
                XCTFail("Expected providerPicker, got \($0) instead.")
            }
        }
    }
    
    func test_mixed_shouldNotifyWithMainOnGoToMain() {
        
        expect(
            .select(.outside(.main)),
            for: .mapped(.mixed(makeMixedQRResult())),
            expectedFulfillmentCount: 3
        ) {
            switch $0 {
            case let .providerPicker(node):
                node.model.event(.goTo(.main))
                
            default:
                XCTFail("Expected providerPicker, got \($0) instead.")
            }
        }
    }
    
    func test_mixed_shouldNotifyWithPaymentsOnGoToPayments() {
        
        expect(
            .select(.outside(.payments)),
            for: .mapped(.mixed(makeMixedQRResult())),
            expectedFulfillmentCount: 3
        ) {
            switch $0 {
            case let .providerPicker(node):
                node.model.event(.goTo(.payments))
                
            default:
                XCTFail("Expected providerPicker, got \($0) instead.")
            }
        }
    }
    
    func test_mixed_shouldNotifyWithDismissOnGoToScanQR() {
        
        expect(
            .dismiss,
            for: .mapped(.mixed(makeMixedQRResult())),
            expectedFulfillmentCount: 3
        ) {
            switch $0 {
            case let .providerPicker(node):
                node.model.event(.goTo(.scanQR))
                
            default:
                XCTFail("Expected providerPicker, got \($0) instead.")
            }
        }
    }
    
    // MARK: - qrResult: mapped: multiple
    
    func test_multiple_shouldDeliverProviderPicker() {
        
        expect(.qrResult(.mapped(.multiple(makeMultipleQRResult()))), toDeliver: .operatorSearch)
    }
    
    func test_multiple_shouldNotifyWithChatOnOperatorSearchAddCompany() {
        
        expect(
            .select(.outside(.chat)),
            for: .mapped(.multiple(makeMultipleQRResult()))
        ) {
            switch $0 {
            case let .operatorSearch(operatorSearch):
                try? operatorSearch.tapAddCompanyButton()
                
            default:
                XCTFail("Expected OperatorSearch, but got \($0) instead.")
            }
        }
        
        expect(.qrResult(.mapped(.multiple(makeMultipleQRResult()))), toDeliver: .operatorSearch)
    }
    
    func test_multiple_shouldNotifyWithDismissOnOperatorSearchClose() {
        
        expect(.dismiss, for: .mapped(.multiple(makeMultipleQRResult()))) {
            
            switch $0 {
            case let .operatorSearch(operatorSearch):
                try? operatorSearch.tapBackButton()
                
            default:
                XCTFail("Expected OperatorSearch, but got \($0) instead.")
            }
        }
        
        expect(.qrResult(.mapped(.multiple(makeMultipleQRResult()))), toDeliver: .operatorSearch)
    }
    
    // TODO: - finish this
    //    func test_multiple_shouldNotifyWith_???_sOnOperatorSearchPayWithDetail() {
    //
    //        expect(
    //            with: .mapped(.multiple(makeMultipleQRResult())),
    //            notifiesWith: .dismiss
    //        ) {
    //            switch $0 {
    //            case let .operatorSearch(operatorSearch):
    //                try? operatorSearch.tapPayWithDetailsButton()
    //
    //            default:
    //                XCTFail("Expected OperatorSearch, but got \($0) instead.")
    //            }
    //        }
    //
    //        expect(with: .qrResult(.mapped(.multiple(makeMultipleQRResult()))), toDeliver: .operatorSearch)
    //    }
    
    // MARK: - qrResult: mapped: none
    
    func test_none_shouldDeliverPayments() {
        
        expect(.qrResult(.mapped(.none(makeQR()))), toDeliver: .payments)
    }
    
    func test_none_shouldNotifyWithDismissOnClose() {
        
        expect(.dismiss, for: .mapped(.none(makeQR()))) {
            
            switch $0 {
            case let .payments(payments):
                payments.close()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_none_shouldNotifyWithDismissOnScanQR() {
        
        expect(.dismiss, for: .mapped(.none(makeQR()))) {
            
            switch $0 {
            case let .payments(payments):
                payments.scanQR()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    // MARK: - mapped: provider
    
    func test_provider_shouldDeliverServicePicker() {
        
        expect(.qrResult(.mapped(.provider(makeProviderPayload()))), toDeliver: .providerServicePicker)
    }
    
    // MARK: - mapped: single
    
    func test_single_shouldDeliverServicePicker() {
        
        expect(.qrResult(.mapped(.single(makeSinglePayload()))), toDeliver: .operatorView)
    }
    
    // MARK: - mapped: source
    
    func test_source_shouldDeliverServicePicker() {
        
        expect(.qrResult(.mapped(.source(.avtodor))), toDeliver: .payments)
    }
    
    func test_source_shouldNotifyWithDismissOnClose() {
        
        expect(.dismiss, for: .mapped(.source(.avtodor))) {
            
            switch $0 {
            case let .payments(payments):
                payments.close()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_source_shouldNotifyWithDismissOnScanQR() {
        
        expect(.dismiss, for: .mapped(.source(.avtodor))) {
            
            switch $0 {
            case let .payments(payments):
                payments.scanQR()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    // MARK: - sberQR
    
    func test_sberQR_shouldDeliverAlertOnSberQRConfirmFailure() throws {
        
        let (sut, httpClient, _) = makeSUT()
        
        expect(
            sut: sut,
            .qrResult(.sberQR(anyURL())),
            toDeliver: .sberQRFailure
        ) {
            XCTAssertNoDiff(
                httpClient.requests.map(\.url?.lastPathComponent),
                ["getSberQRData"]
            )
            httpClient.complete(with: anyError())
        }
    }
    
    func test_sberQR_shouldDeliverSberQRConfirmOnSuccess() throws {
        
        let response = try getSberQRDataSuccessResponse()
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        
        expect(
            sut: sut,
            .qrResult(.sberQR(anyURL())),
            toDeliver: .sberQR
        ) {
            XCTAssertNoDiff(
                httpClient.requests.map(\.url?.lastPathComponent),
                ["getSberQRData"]
            )
            httpClient.complete(with: response)
        }
    }
    
    // MARK: - url
    
    func test_url_shouldDeliverQRFailure() {
        
        expect(.qrResult(.url(anyURL())), toDeliver: .failure)
    }
    
    // MARK: - unknown
    
    func test_unknown_shouldDeliverQRFailure() {
        
        expect(.qrResult(.unknown), toDeliver: .failure)
    }
        
    // MARK: - Helpers
    
    private typealias NotifySpy = CallSpy<QRScannerDomain.NotifyEvent, Void>
    private typealias NavigationSpy = Spy<Void, QRScannerDomain.Navigation, Never>
    
    private func expect(
        sut: SUT? = nil,
        _ select: QRScannerDomain.Select,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.getQRNavigation(select: select, notify: { _ in }) { [self] in
            
            XCTAssertNoDiff(equatable($0), expectedNavigation, "Expected \(expectedNavigation), got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func equatable(
        _ navigation: QRScannerDomain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .failure:
            return .failure
            
        case .operatorSearch:
            return .operatorSearch
            
        case .operatorView:
            return .operatorView
            
        case let .outside(outside):
            return .outside(outside)
            
        case .payments:
            return .payments
            
        case .providerPicker:
            return .providerPicker
            
        case .providerServicePicker:
            return .providerServicePicker
            
        case .sberQR(nil):
            return .sberQRFailure
            
        case .sberQR(.some(_)):
            return .sberQR
            
        case .sberQRComplete:
            return .sberQRComplete

        case .searchByUIN:
            return .searchByUIN
        }
    }
    
    private enum EquatableNavigation: Equatable {
        
        case failure
        case operatorSearch
        case operatorView
        case outside(QRScannerDomain.Outside)
        case payments
        case providerPicker
        case providerServicePicker
        case sberQR
        case sberQRFailure
        case sberQRComplete
        case searchByUIN
    }
    
    private func makePayments(
        payload: PaymentsViewModel.Payload = .category(.fast),
        model: Model = .mockWithEmptyExcept(),
        closeAction: @escaping () -> Void = {}
    ) -> PaymentsViewModel {
        
        return .init(payload: payload, model: model, closeAction: closeAction)
    }
    
    private func getSberQRDataSuccessResponse() throws -> Data {
        
        try getJSON(from: "getSberQRData_fix_sum")
    }
    
    private func expect(
        sut: SUT? = nil,
        _ expectedNotifyEvent: QRScannerDomain.NotifyEvent,
        for qrResult: QRModelResult,
        expectedFulfillmentCount: Int = 2,
        on action: @escaping (QRScannerDomain.Navigation) -> Void,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedFulfillmentCount
        
        sut.getQRNavigation(
            select: .qrResult(qrResult),
            notify: {
                
                XCTAssertNoDiff($0, expectedNotifyEvent, "Expected \(expectedNotifyEvent), got \($0) instead.", file: file, line: line)
                exp.fulfill()
            },
            completion: {
                
                action($0)
                exp.fulfill()
            }
        )
        
        wait(for: [exp], timeout: timeout)
    }
}

func anyQRCode(
    original: String = anyMessage(),
    rawData: [String : String] = [anyMessage(): anyMessage()]
) -> QRCode {
    
    return .init(original: original, rawData: rawData)
}

// MARK: - DSL

extension QRSearchOperatorViewModel {
    
    func tapAddCompanyButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let addCompanyButton = try XCTUnwrap(addCompanyButton, "Expected to have back addCompanyButton, but got nil instead.", file: file, line: line)
        addCompanyButton.action()
    }
    
    private var addCompanyButton: ButtonSimpleView.ViewModel? {
        
        noCompanyInListViewModel.buttons
            .first { $0.title == "Добавить организацию" }
    }
    
    func tapBackButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let backButton = try XCTUnwrap(backButton, "Expected to have back button in left (leading) navBar items, but got nil instead.", file: file, line: line)
        backButton.action()
    }
    
    private var backButton: NavigationBarView.ViewModel.BackButtonItemViewModel? {
        
        return navigationBar.backButton
    }
    
    func tapPayWithDetailsButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let payWithDetailsButton = try XCTUnwrap(payWithDetailsButton, "Expected to have back payWithDetailsButton, but got nil instead.", file: file, line: line)
        payWithDetailsButton.action()
    }
    
    private var payWithDetailsButton: ButtonSimpleView.ViewModel? {
        
        noCompanyInListViewModel.buttons
            .first { $0.title == "Оплатить по реквизитам" }
    }
}

extension Model {
    
    func addSberProduct(
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let count = products.value.count
        products.value.append(element: .cardActiveMainDebitOnlyRub, toValueOfKey: .card)
        
        XCTAssertEqual(products.value.count, count + 1, "Expected to add sberQRProducts, but failed.", file: file, line: line)
    }
}
