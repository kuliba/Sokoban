//
//  RootViewModelFactory+getQRNavigationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.11.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_getQRNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - outside
    
    func test_outside_shouldDeliverChatOnChat() {
        
        expect(with: .outside(.chat), toDeliver: .outside(.chat))
    }
    
    func test_outside_shouldDeliverMainOnMain() {
        
        expect(with: .outside(.main), toDeliver: .outside(.main))
    }
    
    func test_outside_shouldDeliverPaymentsOnPayments() {
        
        expect(with: .outside(.payments), toDeliver: .outside(.payments))
    }
    
    // MARK: - qrResult: c2bSubscribe
    
    func test_c2bSubscribe_shouldDeliverPayments() {
        
        expect(with: .qrResult(.c2bSubscribeURL(anyURL())), toDeliver: .payments)
    }
    
    func test_c2bSubscribe_shouldNotifyWithDismissOnClose() {
        
        expect(with: .c2bSubscribeURL(anyURL()), notifiesWith: .dismiss) {
            
            switch $0 {
            case let .payments(payments):
                payments.close()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_c2bSubscribe_shouldNotifyWithDismissOnScanQR() {
        
        expect(with: .c2bSubscribeURL(anyURL()), notifiesWith: .dismiss) {
            
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
        
        expect(with: .qrResult(.c2bURL(anyURL())), toDeliver: .payments)
    }
    
    func test_c2b_shouldNotifyWithDismissOnClose() {
        
        expect(with: .c2bURL(anyURL()), notifiesWith: .dismiss) {
            
            switch $0 {
            case let .payments(payments):
                payments.close()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_c2b_shouldNotifyWithDismissOnScanQR() {
        
        expect(with: .c2bURL(anyURL()), notifiesWith: .dismiss) {
            
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
        
        expect(with: .qrResult(.failure(anyQRCode())), toDeliver: .failure)
    }
    
    // MARK: - qrResult: missingINN
    
    func test_missingINN_shouldDeliverQRFailure() {
        
        expect(with: .qrResult(.mapped(.missingINN(anyQRCode()))), toDeliver: .failure)
    }
    
    // MARK: - qrResult: mixed
    
    func test_mixed_shouldDeliverProviderPicker() {
        
        expect(with: .qrResult(.mapped(.mixed(makeMixedQRResult()))), toDeliver: .providerPicker)
    }
    
    func test_mixed_shouldNotifyWithDismissOnDismiss() {
        
        expect(
            with: .mapped(.mixed(makeMixedQRResult())),
            notifiesWith: .dismiss,
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
            with: .mapped(.mixed(makeMixedQRResult())),
            notifiesWith: .select(.outside(.chat)),
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
            with: .mapped(.mixed(makeMixedQRResult())),
            notifiesWith: .select(.outside(.main)),
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
            with: .mapped(.mixed(makeMixedQRResult())),
            notifiesWith: .select(.outside(.payments)),
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
            with: .mapped(.mixed(makeMixedQRResult())),
            notifiesWith: .dismiss,
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
    
    // MARK: - qrResult: multiple
    
    func test_multiple_shouldDeliverProviderPicker() {
        
        expect(with: .qrResult(.mapped(.multiple(makeMultipleQRResult()))), toDeliver: .operatorSearch)
    }
    
    func test_multiple_shouldNotifyWithChatOnOperatorSearchAddCompany() {
        
        expect(
            with: .mapped(.multiple(makeMultipleQRResult())),
            notifiesWith: .select(.outside(.chat))
        ) {
            switch $0 {
            case let .operatorSearch(operatorSearch):
                try? operatorSearch.tapAddCompanyButton()
                
            default:
                XCTFail("Expected OperatorSearch, but got \($0) instead.")
            }
        }
        
        expect(with: .qrResult(.mapped(.multiple(makeMultipleQRResult()))), toDeliver: .operatorSearch)
    }
    
    func test_multiple_shouldNotifyWithDismissOnOperatorSearchClose() {
        
        expect(
            with: .mapped(.multiple(makeMultipleQRResult())),
            notifiesWith: .dismiss
        ) {
            switch $0 {
            case let .operatorSearch(operatorSearch):
                try? operatorSearch.tapBackButton()
                
            default:
                XCTFail("Expected OperatorSearch, but got \($0) instead.")
            }
        }
        
        expect(with: .qrResult(.mapped(.multiple(makeMultipleQRResult()))), toDeliver: .operatorSearch)
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
    
    // MARK: - qrResult: none
    
    func test_none_shouldDeliverPayments() {
        
        expect(with: .qrResult(.mapped(.none(makeQR()))), toDeliver: .payments)
    }
    
    func test_none_shouldNotifyWithDismissOnClose() {
        
        expect(with: .mapped(.none(makeQR())), notifiesWith: .dismiss) {
            
            switch $0 {
            case let .payments(payments):
                payments.close()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    func test_none_shouldNotifyWithDismissOnScanQR() {
        
        expect(with: .mapped(.none(makeQR())), notifiesWith: .dismiss) {
            
            switch $0 {
            case let .payments(payments):
                payments.scanQR()
                
            default:
                XCTFail("Expected Payments, but got \($0) instead.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private typealias NotifySpy = CallSpy<QRScannerDomain.NotifyEvent, Void>
    private typealias NavigationSpy = Spy<Void, QRScannerDomain.Navigation, Never>
    
    private func expect(
        _ sut: SUT? = nil,
        with select: QRScannerDomain.Select,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? super.makeSUT().sut
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
            
        case let .outside(outside):
            return .outside(outside)
            
        case .payments:
            return .payments
            
        case .providerPicker:
            return .providerPicker
        }
    }
    
    private enum EquatableNavigation: Equatable {
        
        case failure
        case outside(QRScannerDomain.Outside)
        case payments
        case providerPicker
        case operatorSearch
    }
    
    private func makePayments(
        payload: PaymentsViewModel.Payload = .category(.fast),
        model: Model = .mockWithEmptyExcept(),
        closeAction: @escaping () -> Void = {}
    ) -> PaymentsViewModel {
        
        return .init(payload: payload, model: model, closeAction: closeAction)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with qrResult: QRModelResult,
        notifiesWith expectedNotifyEvent: QRScannerDomain.NotifyEvent,
        expectedFulfillmentCount: Int = 2,
        on action: @escaping (QRScannerDomain.Navigation) -> Void,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? super.makeSUT().sut
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
        
        return navigationBar.leftItems
            .compactMap(\.asBackButton)
            .first
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

private extension NavigationBarView.ViewModel.ItemViewModel {
    
    var asBackButton: NavigationBarView.ViewModel.BackButtonItemViewModel? {
        
        self as? NavigationBarView.ViewModel.BackButtonItemViewModel
    }
}
