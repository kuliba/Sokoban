//
//  SelectedCategoryNavigationMicroServicesComposerNeverTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.10.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class SelectedCategoryNavigationMicroServicesComposerNeverTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makeQRNavigation, makeList) = makeSUT()
        
        XCTAssertEqual(makeQRNavigation.callCount, 0)
        XCTAssertEqual(makeList.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - getNavigation
    
    func test_getNavigation_shouldDeliverMobileOnMobile() {
        
        getNavigation(flow: .mobile) {
            
            switch $0 {
            case .paymentFlow(.mobile):
                break
                
            default:
                XCTFail("Expected mobile, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverQROnQR() {
        
        getNavigation(flow: .qr) {
            
            switch $0 {
            case .paymentFlow(.qr):
                break
                
            default:
                XCTFail("Expected QR, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverQRWithNotifyOnCancel() {
        
        var notifications = [SUT.FlowDomain.Event]()
        
        getNavigation(flow: .qr, notify: { notifications.append($0) }) {
            
            switch $0 {
            case let .paymentFlow(.qr(qr)):
                qr.model.event(.cancel)
                
                XCTAssertEqual(notifications.count, 1)
                switch notifications.first {
                case .dismiss:
                    break
                    
                default:
                    XCTFail("Expected dismiss event, got \(String(describing: notifications.first)) instead.")
                }
                
            default:
                XCTFail("Expected QR, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldCallMakeQRNavigationWithPayloadOnQRResult() {
        
        let qrResult: QRModelResult = .c2bURL(anyURL())
        let (sut, makeQRNavigation, _) = makeSUT()
        
        getNavigation(sut, flow: .qr) {
            
            switch $0 {
            case let .paymentFlow(.qr(qr)):
                qr.model.event(.qrResult(qrResult))
                XCTAssertNoDiff(makeQRNavigation.payloads.map(\.0), [qrResult])
                
            default:
                XCTFail("Expected QR, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverQRNavigationOnQRResult() {
        
        var notifications = [SUT.FlowDomain.Event]()
        let complete = makePaymentComplete()
        let (sut, makeQRNavigation, _) = makeSUT()
        
        getNavigation(sut, flow: .qr, notify: { notifications.append($0) }) {
            
            switch $0 {
            case let .paymentFlow(.qr(qr)):
                qr.model.event(.qrResult(.c2bURL(anyURL())))
                makeQRNavigation.complete(with: .paymentComplete(.success(complete)))
                
                XCTAssertEqual(notifications.count, 1)
                
                switch notifications.first {
                case let .receive(.qrNavigation(.paymentComplete(.success(receivedComplete)))):
                    XCTAssert(receivedComplete === complete)
                    
                default:
                    XCTFail("Expected complete, got \(String(describing: notifications.first)) instead.")
                }
                
            default:
                XCTFail("Expected QR, got \($0) instead.")
            }
        }
    }
    
    private func makePaymentComplete(
        model: Model = .mockWithEmptyExcept(),
        sections: [PaymentsSectionViewModel] = []
    ) -> QRNavigation.PaymentComplete {
        
        return .init(model: model, sections: sections)
    }
    
    func test_getNavigation_shouldDeliverStandardFailureOnStandardFailure() {
        
        let sut = makeSUT(standard: .failure(.init())).sut
        
        getNavigation(sut, flow: .standard) {
            
            switch $0 {
            case .paymentFlow(.standard(.failure)):
                break
                
            default:
                XCTFail("Expected standard failure, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverStandardOnStandard() {
        
        let sut = makeSUT(standard: .success(makeStandard())).sut
        
        getNavigation(sut, flow: .standard) {
            
            switch $0 {
            case .paymentFlow(.standard(.success)):
                break
                
            default:
                XCTFail("Expected standard, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverTaxAndStateServicesOnTaxAndStateServices() {
        
        getNavigation(flow: .taxAndStateServices) {
            
            switch $0 {
            case .paymentFlow(.taxAndStateServices):
                break
                
            default:
                XCTFail("Expected taxAndStateServices, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverFailureOnTransportFailure() {
        
        let sut = makeSUT(transport: nil).sut
        
        getNavigation(sut, flow: .transport) {
            
            switch $0 {
            case let .failure(failure):
                XCTAssertNoDiff(failure.message, "Ошибка создания транспортных платежей")
                
            default:
                XCTFail("Expected failure, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverTransportOnTransportSuccess() {
        
        let sut = makeSUT(transport: makeTransport()).sut
        
        getNavigation(sut, flow: .transport) {
            
            switch $0 {
            case .paymentFlow(.transport):
                break
                
            default:
                XCTFail("Expected transport, got \($0) instead.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SelectedCategoryNavigationMicroServicesComposer<Never, Void>
    private typealias MakeQRNavigationSpy = Spy<(QRModelResult, SUT.NanoServices.Notify), QRNavigation, Never>
    private typealias MakeListSpy = CallSpy<[ServiceCategory], Void>
    
    private func makeSUT(
        qrResult: QRModelResult = .unknown,
        standard: StandardSelectedCategoryDestination = .failure(.init()),
        transport: TransportPaymentsViewModel? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeQRNavigation: MakeQRNavigationSpy,
        makeList: MakeListSpy
    ) {
        let makeQRNavigation = MakeQRNavigationSpy()
        let makeList = MakeListSpy()
        let sut = SUT(
            nanoServices: .init(
                makeList: makeList.call(payload:),
                makeMobile: makeMobile,
                makeQR: {
                    
                    return .init(
                        mapScanResult: { _, completion in completion(qrResult) },
                        makeQRModel: QRViewModel.preview,
                        scheduler: .immediate
                    )
                },
                makeQRNavigation: makeQRNavigation.process(_:_:completion:),
                makeStandard: { $1(standard) },
                makeTax: makeTax,
                makeTransport: { transport }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeQRNavigation, file: file, line: line)
        trackForMemoryLeaks(makeList, file: file, line: line)
        
        return (sut, makeQRNavigation, makeList)
    }
    
    private func getNavigation(
        _ sut: SUT? = nil,
        flow: ServiceCategory.PaymentFlow,
        notify: @escaping (SUT.FlowDomain.Event) -> Void = { _ in },
        completion: @escaping (SUT.Navigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        getNavigation(
            sut, 
            with: .pickerSelect(makeCategorySelect(flow: flow)),
            notify: notify,
            completion: completion,
            file: file, line: line
        )
    }
    
    private func getNavigation(
        _ sut: SUT? = nil,
        with select: SUT.Select,
        notify: @escaping (SUT.FlowDomain.Event) -> Void = { _ in },
        completion: @escaping (SUT.Navigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line).sut
        let microServices = sut.compose()
        let exp = expectation(description: "wait for completion")
        
        microServices.getNavigation(select, notify) {
            
            completion($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func makeMobile() -> ClosePaymentsViewModelWrapper {
        
        return makeClosePaymentsViewModelWrapper()
    }
    
    private func makeTax() -> ClosePaymentsViewModelWrapper {
        
        return makeClosePaymentsViewModelWrapper()
    }
    
    private func makeClosePaymentsViewModelWrapper(
        model: Model = .mockWithEmptyExcept(),
        category: Payments.Category = .fast,
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) -> ClosePaymentsViewModelWrapper {
        
        return .init(model: model, category: category, scheduler: scheduler)
    }
    
    private func makeStandard(
    ) -> PaymentProviderPicker.Binder {
        
        return .init(
            content: .init(
                operationPicker: (),
                providerList: .init(
                    initialState: .init(
                        lastPayments: [],
                        operators: [],
                        searchText: ""
                    ),
                    reduce: { state, _ in return (state, nil) },
                    handleEffect: { _,_ in }
                ),
                search: .none,
                cancellables: []
            ),
            flow: .init(
                initialState: .init(),
                reduce: { state, _ in return (state, nil) },
                handleEffect: { _,_ in }
            ),
            bind: { _,_ in [] }
        )
    }
    
    private func makeTransport(
    ) -> TransportPaymentsViewModel {
        
        return .init(
            operators: [],
            latestPayments: .sample,
            makePaymentsViewModel: { _ in .sample }
        )
    }
    
    private func makeCategorySelect(
        flow: ServiceCategory.PaymentFlow
    ) -> SUT.Select.PickerSelect {
        
        return .category(makeServiceCategory(flow: flow))
    }
    
    private func makeCategorySelect(
        _ serviceCategory: ServiceCategory? = nil
    ) -> SUT.Select.PickerSelect {
        
        return .category(serviceCategory ?? makeServiceCategory())
    }
    
    private func makeServiceCategory(
        latestPaymentsCategory: ServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = .random(in: 1...100),
        flow paymentFlow: ServiceCategory.PaymentFlow = .mobile,
        hasSearch: Bool = false,
        type: ServiceCategory.CategoryType = .networkMarketing
    ) -> ServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            hasSearch: hasSearch,
            type: type
        )
    }
}
