//
//  SelectedCategoryNavigationMicroServicesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 30.09.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class SelectedCategoryNavigationMicroServicesComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makeQRNavigation) = makeSUT()
        
        XCTAssertEqual(makeQRNavigation.callCount, 0)
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
        
        var notifyEvents = [SUT.FlowDomain.NotifyEvent]()
        
        getNavigation(flow: .qr, notify: { notifyEvents.append($0) }) {
            
            switch $0 {
            case let .paymentFlow(.qr(qr)):
                qr.model.event(.cancel)
                
                XCTAssertEqual(notifyEvents.count, 1)
                switch notifyEvents.first {
                case .dismiss:
                    break
                    
                default:
                    XCTFail("Expected dismiss event, got \(String(describing: notifyEvents.first)) instead.")
                }
                
            default:
                XCTFail("Expected QR, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldCallMakeQRNavigationWithPayloadOnQRResult() {
        
        let qrResult: QRModelResult = .c2bURL(anyURL())
        let (sut, makeQRNavigation) = makeSUT()
        
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
        
        var notifyEvents = [SUT.FlowDomain.NotifyEvent]()
        let complete = makePaymentComplete()
        let (sut, makeQRNavigation) = makeSUT()
        
        getNavigation(sut, flow: .qr, notify: { notifyEvents.append($0) }) {
            
            switch $0 {
            case let .paymentFlow(.qr(qr)):
                qr.model.event(.qrResult(.c2bURL(anyURL())))
                makeQRNavigation.complete(with: .paymentComplete(.success(complete)))
                
                XCTAssertEqual(notifyEvents.count, 1)
                
                switch notifyEvents.first {
                case let .select(.qrSelect(.qrNavigation(.paymentComplete(.success(receivedComplete))))):
                    XCTAssert(receivedComplete === complete)
                    
                default:
                    XCTFail("Expected complete, got \(String(describing: notifyEvents.first)) instead.")
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
    
    // MARK: - qrSelect: contactAbroad
    
    func test_getNavigation_qrSelect_contactAbroad_shouldDeliverPayments() {
        
        getNavigation(with: .qrSelect(.contactAbroad(.avtodor))) {
            
            switch $0 {
            case .qrNavigation(.payments):
                break
                
            default:
                XCTFail("Expected payments, got \($0) instead.")
            }
        }
    }
    
    // MARK: - qrSelect: detailPayment
    
    func test_getNavigation_qrSelect_detailPayment_shouldDeliverPayments_nil() {
        
        getNavigation(with: .qrSelect(.detailPayment(nil))) {
            
            switch $0 {
            case .qrNavigation(.payments):
                break
                
            default:
                XCTFail("Expected payments, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_qrSelect_detailPayment_shouldDeliverPayments() {
        
        getNavigation(with: .qrSelect(.detailPayment(.some(.init(original: "", rawData: [:]))))) {
            
            switch $0 {
            case .qrNavigation(.payments):
                break
                
            default:
                XCTFail("Expected payments, got \($0) instead.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SelectedCategoryNavigationMicroServicesComposer
    private typealias MakeQRNavigationSpy = Spy<(QRModelResult, SUT.NanoServices.Notify), QRNavigation, Never>
    
    private func makeSUT(
        qrResult: QRModelResult = .unknown,
        standard: StandardSelectedCategoryDestination = .failure(.init()),
        transport: TransportPaymentsViewModel? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeQRNavigation: MakeQRNavigationSpy
    ) {
        let makeQRNavigation = MakeQRNavigationSpy()
        let sut = SUT(
            model: .mockWithEmptyExcept(),
            nanoServices: .init(
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
            ),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeQRNavigation, file: file, line: line)
        
        return (sut, makeQRNavigation)
    }
    
    private func getNavigation(
        _ sut: SUT? = nil,
        flow: ServiceCategory.PaymentFlow,
        notify: @escaping (SUT.FlowDomain.NotifyEvent) -> Void = { _ in },
        completion: @escaping (SUT.Navigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        getNavigation(
            sut,
            with: .category(makeServiceCategory(flow: flow)),
            notify: notify,
            completion: completion,
            file: file, line: line
        )
    }
    
    private func getNavigation(
        _ sut: SUT? = nil,
        with select: SUT.Select,
        notify: @escaping (SUT.FlowDomain.NotifyEvent) -> Void = { _ in },
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
}
